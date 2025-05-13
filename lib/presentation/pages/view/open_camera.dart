import 'dart:io';
import 'package:camera/camera.dart';
import 'package:edit_video_app/assets/colors.dart';
import 'package:edit_video_app/assets/image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.camera});
  final CameraDescription? camera;

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  List<String> filters = ["Cool", "Warm", "Vintage", "B&W"];
  String selectedFilter = '';
  bool _isRecording = false;
  List<CameraDescription>? _cameras;
  int _selectedCameraIndex = 0;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras!.isNotEmpty) {
      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    }
  }

  void _switchCamera() {
    if (_cameras == null || _cameras!.isEmpty) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
      _controller = CameraController(
        _cameras![_selectedCameraIndex],
        ResolutionPreset.high,
      );
      _initializeControllerFuture = _controller!.initialize();
    });
  }

  void _startRecording() async {
    if (_isRecording || _controller == null) return;
    try {
      await _initializeControllerFuture;
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void _stopRecording() async {
    if (!_isRecording || _controller == null) return;
    try {
      final videoFile = await _controller!.stopVideoRecording();
      setState(() {
        _isRecording = false;
      });
      if (!context.mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayVideoScreen(videoPath: videoFile.path),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Camera Error')),
        body: const Center(child: Text('Camera not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  double screenWidth = constraints.maxWidth;
                  double screenHeight = constraints.maxHeight - 140;
                  return Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: CameraPreview(_controller!),
                    ),
                  );
                },
              ),

              if (_showFilters)
                Positioned(
                  bottom: 70,
                  // top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    color: Colors.black.withOpacity(0.4),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filters[index];
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedFilter == filters[index]
                                    ? Colors.blue
                                    : Colors.white,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                filters[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Nút điều khiển
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Nút filter
                    IconButton(
                      icon: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 40),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),

                    // Nút chụp/quay
                    GestureDetector(
                      onLongPress: _startRecording,
                      onLongPressEnd: (_) => _stopRecording(),
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: SvgPicture.asset(
                          _isRecording ? ImageUtils.circle : ImageUtils.circle,
                          color: UtilColors
                              .primaryColor, // Bạn có thể tùy chỉnh màu sắc
                          // Tùy chỉnh kích thước
                          height: 30,
                        ),
                        onPressed: () async {
                          if (_isRecording) return;
                          try {
                            await _initializeControllerFuture;
                            final image = await _controller!.takePicture();
                            if (!context.mounted) return;
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    DisplayPictureScreen(imagePath: image.path),
                              ),
                            );
                          } catch (e) {
                            print(e);
                          }
                        },
                      ),
                    ),

                    // Nút lật cam
                    IconButton(
                      icon: SvgPicture.asset(
                        ImageUtils.rotation,
                        height: 30,
                      ),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Image.file(File(imagePath))),
    );
  }
}

class DisplayVideoScreen extends StatefulWidget {
  final String videoPath;

  const DisplayVideoScreen({super.key, required this.videoPath});

  @override
  State<DisplayVideoScreen> createState() => _DisplayVideoScreenState();
}

class _DisplayVideoScreenState extends State<DisplayVideoScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: controller.value.isInitialized
          ? Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
