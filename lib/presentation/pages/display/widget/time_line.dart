
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../music/entities/video_segment.dart';
import 'package:edit_video_app/assets/colors.dart';

class TimeLineThumbnail extends StatefulWidget {
  final List<VideoSegment> videoSegments;
  final double width;
  final double height;
  final Duration duration;
  final void Function(Duration) onSeek;

  const TimeLineThumbnail({
    super.key,
    required this.videoSegments,
    required this.width,
    required this.height,
    required this.duration,
    required this.onSeek,
    required Future<Null> Function(dynamic duration) onseek,
  });

  @override
  State<TimeLineThumbnail> createState() => _TimeLineThumbnailState();
}

class _TimeLineThumbnailState extends State<TimeLineThumbnail> {
  final ScrollController _scrollController = ScrollController();
  final double thumbWidth = 60.0;
  Duration _currentTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final center = widget.width / 2;
    final scrollOffset = _scrollController.offset;
    final absoluteOffset = scrollOffset + center;

    final totalWidth = thumbWidth * widget.videoSegments.length;
    final clamped = absoluteOffset.clamp(0, totalWidth);
    final percent = clamped / totalWidth;

    final seek = widget.duration * percent;

    setState(() {
      _currentTime = seek;
    });

    widget.onSeek(seek);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height + 25,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 00),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.videoSegments.length,
                itemBuilder: (context, index) {
                  Uint8List thumb = widget.videoSegments[index].thumbnail;
                  return Image.memory(
                    thumb,
                    width: thumbWidth,
                    height: widget.height,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            bottom: 25,
            left: widget.width / 2 - 20,
            child: Container(
              width: 3,
              color: UtilColors.primaryColor,
            ),
          ),
          Positioned(
            bottom: 0,
            left: widget.width / 2 - 42,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_currentTime),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
