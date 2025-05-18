import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:edit_video_app/assets/colors.dart';
import 'package:edit_video_app/presentation/pages/service/service_flashAPI.dart';
import 'package:edit_video_app/presentation/widgets/util_loading.dart';
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
    {'icon': 'speed', 'label': 'Speed'},
    {'icon': 'volume', 'label': 'Volume'},
    {'icon': 'delete', 'label': 'Delete'},
    {'icon': 'rm_background', 'label': 'Remove Background'},
    {'icon': 'slipt', 'label': 'Split'},
    {'icon': 'trim', 'label': 'Trim'},
    {'icon': 'crop', 'label': 'Crop'},
    {'icon': 'component', 'label': 'Canvas'},
  ];
  bool isRestore = false;
  bool isLoanding = false;
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
          color: const Color.fromARGB(255, 0, 0, 0), // Thẻ có nền tối
          elevation: 8,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 1.0),
            child: ListView(
              scrollDirection: Axis.horizontal, // Để listview cuộn ngang
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
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: SvgPicture.asset(
            _getIconPath(iconName),
            width: 60,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.9),
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
