import 'dart:async';
import 'package:camera/camera.dart';
import 'package:edit_video_app/assets/colors.dart';
import 'package:edit_video_app/assets/image.dart';
import 'package:edit_video_app/presentation/pages/display/page_preview_image.dart';
import 'package:edit_video_app/presentation/pages/display/page_preview_video.dart';
import 'package:edit_video_app/presentation/pages/display/widget/video_thumbnail.dart';
import 'package:edit_video_app/presentation/pages/view/open_camera.dart';
import 'package:edit_video_app/presentation/widgets/util_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:video_thumbnail/video_thumbnail.dart' as vt;

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});

  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<CameraDescription> cameras;
  late CameraDescription firstCamera;
  final ImagePicker _picker = ImagePicker();
  List<XFile> selectedForEdit = [];
  bool isPhotoTab = true;
  List<XFile> selectedPhotos = [];
  List<XFile> selectedVideos = [];
  List<XFile> selectedVideosForEdit = [];
  List<XFile> selectedPhotosForEdit = [];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeCamera();
    _tabController.addListener(() {
      setState(() {
        isPhotoTab = _tabController.index == 0;
      });
    });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      // firstCamera = cameras.first;
      return null;
    }
  }

  Future<void> _pickMedia() async {
    try {
      if (isPhotoTab) {
        final List<XFile> pickedImages = await _picker.pickMultiImage();
        if (pickedImages.isNotEmpty) {
          setState(() {
            for (var image in pickedImages) {
              if (!selectedPhotos
                  .any((element) => element.path == image.path)) {
                selectedPhotos.add(image);
              }
            }
          });
        }
      } else {
        final XFile? pickedVideo =
            await _picker.pickVideo(source: ImageSource.gallery);
        if (pickedVideo != null) {
          setState(() {
            // Chỉ thêm nếu chưa có trong selectedVideos (không trùng)
            if (!selectedVideos
                .any((element) => element.path == pickedVideo.path)) {
              selectedVideos.add(pickedVideo);
            }
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error picking media: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              ImageUtils.camera,
              width: 24,
              height: 24,
            ),
            onPressed: () async {
              await _initializeCamera();
              if (cameras.isNotEmpty) {
                Navigator.push(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TakePictureScreen(camera: firstCamera),
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No camera found'),
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: UtilColors.primaryColor,
          indicatorColor: UtilColors.primaryColor,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(fontFamily: ';OpenSans', fontSize: 17),
          unselectedLabelStyle: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 15,
              color: Colors.white.withOpacity(0.5)),
          tabs: const [
            Tab(text: 'Photo'),
            Tab(text: 'Video'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMediaGrid(),
          _buildVideoGrid(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickMedia,
        backgroundColor: UtilColors.primaryColor,
        child: Icon(Icons.add_photo_alternate),
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 24, 23, 23),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Selected ${selectedForEdit.length} ${isPhotoTab ? 'photos' : 'videos'}",
              style: const TextStyle(
                fontFamily: 'OpenSans',
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
            SizedBox(
                width: 90,
                height: 30,
                child: UtilButton(
                    text: "use",
                    onPressed: selectedForEdit.isEmpty
                        ? null
                        : () async {
                            File file = File(selectedForEdit.first.path);
                            if (isPhotoTab) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ImagePreviewPage(file: file),
                                ),
                              );
                            } else {
                              final playerController =
                                  VideoPlayerController.file(file);
                              await playerController.initialize();
                              final editorController =
                                  VideoEditorController.file(
                                file,
                                minDuration: const Duration(seconds: 1),
                                maxDuration: const Duration(minutes: 10),
                              );
                              final timeline = await generateTimeLine(file, 10);
                              if (!mounted) return;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VideoPreviewPage(
                                    file: file,
                                    editorController: editorController,
                                    playerController: playerController,
                                    timeline: timeline,
                                  ),
                                ),
                              );
                            }
                          })),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(3),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: selectedPhotos.length,
      itemBuilder: (context, index) {
        final media = selectedPhotos[index];
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: FileImage(File(media.path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (selectedForEdit.contains(media)) {
                      selectedForEdit.remove(media);
                    } else {
                      selectedForEdit.add(media);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selectedForEdit.contains(media)
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: Icon(
                    selectedForEdit.contains(media)
                        ? Icons.check
                        : Icons.circle_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  Widget _buildVideoGrid() {
    return GridView.builder(
        padding: EdgeInsets.all(3),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: selectedVideos.length,
        itemBuilder: (context, index) {
          final media = selectedVideos[index];

          return FutureBuilder<List<dynamic>>(
            future: Future.wait([
              _getVideoDuration(media.path),
              _getThumbnail(media.path),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final duration = snapshot.data![0] as Duration?;
              final thumbnail = snapshot.data![1] as Uint8List?;
              final formattedDuration =
                  duration != null ? _formatDuration(duration) : '--:--';

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: thumbnail != null
                          ? DecorationImage(
                              image: MemoryImage(thumbnail),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: Colors.black87,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedForEdit.contains(media)) {
                            selectedForEdit.remove(media);
                          } else {
                            selectedForEdit.add(media);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectedForEdit.contains(media)
                              ? Colors.green
                              : Colors.grey,
                        ),
                        child: Icon(
                          selectedForEdit.contains(media)
                              ? Icons.check
                              : Icons.circle_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      color: Colors.black54,
                      child: Text(
                        formattedDuration,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

Future<Duration> _getVideoDuration(String path) async {
  final controller = VideoPlayerController.file(File(path));
  await controller.initialize();
  final duration = controller.value.duration;
  await controller.dispose();
  return duration;
}

String _formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

Future<Uint8List?> _getThumbnail(String videoPath) async {
  final thumbanil = await vt.VideoThumbnail.thumbnailData(
    video: videoPath,
    imageFormat: vt.ImageFormat.JPEG,
    maxWidth: 128,
    quality: 75,
  );
  return thumbanil;
}
