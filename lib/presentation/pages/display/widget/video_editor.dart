import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:edit_video_app/assets/colors.dart';
import 'package:edit_video_app/presentation/pages/service/service_flashAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../../../assets/image.dart';

class MainFunction extends StatefulWidget {
  const MainFunction({
    super.key,
    required this.file,
    required this.videoPlayerController,
    required this.onLoadingChanged,
  });
  final File file;
  final VideoPlayerController videoPlayerController;
  final Function(bool) onLoadingChanged; // Callback function
  @override
  State<MainFunction> createState() => _MainFunctionState();
}

class _MainFunctionState extends State<MainFunction> {
  final List<Map<String, String>> actions = [
    {'icon': 'filter', 'label': 'Filter'},
    {'icon': 'component', 'label': 'Canvas'},
    {'icon': 'speed', 'label': 'Speed'},
    {'icon': 'volume', 'label': 'Volume'},
    {'icon': 'delete', 'label': 'Delete'},
    {'icon': 'rm_background', 'label': 'Remove Background'},
    {'icon': 'slipt', 'label': 'Split'},
    {'icon': 'trim', 'label': 'Trim'},
    {'icon': 'crop', 'label': 'Crop'},
  ];
  bool isRestore = false;
  bool isLoanding = false;
  bool isVolumeControlVisible = false;
  bool isSpeedControlVisible = false;
  late File file;
  @override
  void initState() {
    super.initState();
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: const Color.fromARGB(255, 0, 0, 0),
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 1.0),
            child: isVolumeControlVisible
                ? _buildVolumeControl()
                : isSpeedControlVisible
                    ? _buildSpeedControl()
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: actions.map((action) {
                          return _buildActionButton(
                            action['icon']!,
                            action['label']!,
                          );
                        }).toList(),
                      ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeControl() {
    double currentVolume = widget.videoPlayerController.value.volume;
    return Row(
      children: [
        IconButton(
          icon: Icon(
            currentVolume == 0 ? Icons.volume_off : Icons.volume_up,
            color: UtilColors.color_edittor,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              currentVolume = currentVolume == 0 ? 1.0 : 0.0;
              widget.videoPlayerController.setVolume(currentVolume);
            });
          },
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: UtilColors.color_edittor,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: UtilColors.color_edittor,
              overlayColor: UtilColors.color_edittor.withOpacity(0.2),
            ),
            child: Slider(
              value: currentVolume,
              onChanged: (value) {
                setState(() {
                  currentVolume = value;
                  widget.videoPlayerController.setVolume(value);
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '${(currentVolume * 100).toInt()}%',
            style: const TextStyle(
              color: UtilColors.color_edittor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            color: UtilColors.color_edittor,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              isVolumeControlVisible = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSpeedControl() {
    double currentSpeed = widget.videoPlayerController.value.playbackSpeed;
    return Row(
      children: [
        IconButton(
          icon: const Icon(
            Icons.speed,
            color: UtilColors.color_edittor,
            size: 30,
          ),
          onPressed: () {
            setState(() {
              currentSpeed = currentSpeed == 1.0 ? 2.0 : 1.0;
              widget.videoPlayerController.setPlaybackSpeed(currentSpeed);
            });
          },
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: UtilColors.color_edittor,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              thumbColor: UtilColors.color_edittor,
              overlayColor: UtilColors.color_edittor.withOpacity(0.2),
            ),
            child: Slider(
              value: currentSpeed,
              min: 0.5,
              max: 5.0,
              divisions: 9,
              label: '${currentSpeed.toStringAsFixed(1)}x',
              onChanged: (value) {
                setState(() {
                  currentSpeed = value;
                  widget.videoPlayerController.setPlaybackSpeed(value);
                });
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            '${currentSpeed.toStringAsFixed(1)}x',
            style: const TextStyle(
              color: UtilColors.color_edittor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.close,
            color: UtilColors.color_edittor,
            size: 24,
          ),
          onPressed: () {
            setState(() {
              isSpeedControlVisible = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(String iconName, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () async {
          if (iconName == 'filter') {
            if (isLoanding || isRestore) {
              return;
            }
            setState(() {
              isLoanding = true;
            });
            widget.onLoadingChanged(true);
            try {
              File? restoredVideo = await restoreVideo(file);
              if (restoredVideo != null) {
                setState(() {
                  file = restoredVideo;
                  isRestore = true;

                  Flushbar(
                    message: "Video đã được phục hồi",
                    duration: const Duration(seconds: 3),
                    backgroundColor: UtilColors.color_edittor,
                    margin: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(8),
                  ).show(context);
                });
                widget.videoPlayerController.dispose();
              } else {
                Flushbar(
                  message: "Không thể phục hồi video",
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.redAccent,
                  margin: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(8),
                ).show(context);
              }
            } catch (e) {
              print('Lỗi chi tiết: $e');
              Flushbar(
                message: "Lỗi khi gọi API: ${e.toString()}",
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.redAccent,
                margin: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(8),
              ).show(context);
            } finally {
              setState(() {
                isLoanding = false;
              });
              widget.onLoadingChanged(false);
            }
          } else if (iconName == 'component') {
            if (isLoanding || isRestore) {
              return;
            }
            setState(() {
              isLoanding = true;
            });
            widget.onLoadingChanged(true);
            try {
              File? restoredVideo = await restoreVideoWithFineTuned(file);
              if (restoredVideo != null) {
                setState(() {
                  file = restoredVideo;
                  isRestore = true;

                  Flushbar(
                    message: "Video đã được phục hồi",
                    duration: const Duration(seconds: 3),
                    backgroundColor: UtilColors.color_edittor,
                    margin: const EdgeInsets.all(10),
                    borderRadius: BorderRadius.circular(8),
                  ).show(context);
                });
                widget.videoPlayerController.dispose();
              } else {
                Flushbar(
                  message: "Không thể phục hồi video",
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.redAccent,
                  margin: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(8),
                ).show(context);
              }
            } catch (e) {
              print('Lỗi chi tiết: $e');
              Flushbar(
                message: "Lỗi khi gọi API: ${e.toString()}",
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.redAccent,
                margin: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(8),
              ).show(context);
            } finally {
              setState(() {
                isLoanding = false;
              });
              widget.onLoadingChanged(false);
            }
          } else if (iconName == 'volume') {
            setState(() {
              isVolumeControlVisible = true;
              isSpeedControlVisible = false;
            });
          } else if (iconName == 'speed') {
            setState(() {
              isSpeedControlVisible = true;
              isVolumeControlVisible = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.asset(
            _getIconPath(iconName),
            width: 60,
            colorFilter: ColorFilter.mode(
              UtilColors.color_edittor,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  String _getIconPath(String iconName) {
    switch (iconName) {
      case 'component':
        return ImageUtils.component;
      case 'rm_background':
        return ImageUtils.rmBackground;
      case 'trim':
        return ImageUtils.trim;
      case 'slipt':
        return ImageUtils.slipt;
      case 'crop':
        return ImageUtils.crop;
      case 'filter':
        return ImageUtils.filter;
      case 'volume':
        return ImageUtils.volume;
      case 'speed':
        return ImageUtils.speed;
      case 'delete':
        return ImageUtils.delete;
      default:
        return ImageUtils.circle;
    }
  }
}
