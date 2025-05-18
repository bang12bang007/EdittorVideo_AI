import 'dart:io' show File;
import 'package:edit_video_app/assets/colors.dart';
import 'package:edit_video_app/assets/image.dart';
import 'package:edit_video_app/presentation/pages/display/widget/time_line.dart';
import 'package:edit_video_app/presentation/widgets/util_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import '../music/entities/video_segment.dart';
import 'widget/video_editor.dart';

class VideoPreviewPage extends StatefulWidget {
  final VideoEditorController editorController;
  final VideoPlayerController playerController;
  final File file;
  final List<VideoSegment> timeline;
  const VideoPreviewPage({
    super.key,
    required this.file,
    required this.editorController,
    required this.playerController,
    required this.timeline,
  });

  @override
  State<VideoPreviewPage> createState() => _VideoPreviewPageState();
}

class _VideoPreviewPageState extends State<VideoPreviewPage> {
  bool isLoading = false;

  @override
  void dispose() {
    widget.editorController.dispose();
    widget.playerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const fixedAspectRatio = 4 / 6; // 4:6
    const Color colorEdittor = UtilColors.color_edittor;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: colorEdittor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Video Editor",
          style: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: colorEdittor,
          ),
        ),
        actions: [
          IconButton(
            style: ButtonStyle(iconSize: MaterialStateProperty.all(30)),
            icon: Icon(
              Icons.file_upload_outlined,
              color: colorEdittor,
            ),
            onPressed: () {
              null;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Center(
                heightFactor: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40, top: 0),
                  child: AspectRatio(
                    aspectRatio: fixedAspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(widget.playerController),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                height: 40,
                width: double.infinity,
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.undo_rounded, color: colorEdittor),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(Icons.redo_rounded, color: colorEdittor),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            final isPlaying =
                                widget.playerController.value.isPlaying;

                            if (isPlaying) {
                              await widget.playerController.pause();
                            } else {
                              await widget.playerController.play();
                            }
                            setState(() {
                              widget.playerController.value =
                                  widget.playerController.value.copyWith(
                                isPlaying: !isPlaying,
                              );
                            });
                          },
                          child: Icon(
                            widget.playerController.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: colorEdittor,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: SvgPicture.asset(
                            ImageUtils.fullScreen,
                            color: colorEdittor,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    height: 50,
                    width: 190,
                    color: Colors.red,
                  ),
                  IntrinsicWidth(
                    child: SizedBox(
                      height: 80,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, top: 16),
                        child: TimeLineThumbnail(
                          videoSegments: widget.timeline,
                          width: MediaQuery.of(context).size.width -
                              230, // 200 + 30 padding
                          height: 50,
                          duration: widget.playerController.value.duration,
                          onseek: (duration) async {
                            widget.playerController.pause();
                            await widget.playerController.seekTo(duration);
                            await Future.delayed(
                              Duration(milliseconds: 200),
                            );
                            await widget.playerController.pause();
                            setState(() {});
                          },
                          onSeek: (duration) async {
                            widget.playerController.pause();
                            await widget.playerController.seekTo(duration);
                            await Future.delayed(
                              Duration(milliseconds: 200),
                            );
                            await widget.playerController.pause();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              MainFunction(
                file: widget.file,
                videoPlayerController: widget.playerController,
                onLoadingChanged: (value) {
                  setState(() {
                    isLoading = value;
                  });
                },
              ),
            ],
          ),
          if (isLoading)
            const Positioned.fill(
              child: UtilLoading(),
            ),
        ],
      ),
    );
  }
}
