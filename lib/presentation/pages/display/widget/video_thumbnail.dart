import 'dart:io';
import 'package:edit_video_app/presentation/pages/music/entities/video_segment.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_thumbnail/video_thumbnail.dart'
    show ImageFormat, VideoThumbnail;
import 'package:video_player/video_player.dart';

Future<List<VideoSegment>> generateTimeLine(File file, int segment) async {
  final List<VideoSegment> videoSegments = [];

  final playerController = VideoPlayerController.file(file);
  await playerController.initialize();
  final duration = playerController.value.duration;

  // ignore: unused_local_variable
  final editorController = VideoEditorController.file(
    file,
    minDuration: const Duration(seconds: 1),
    maxDuration: duration,
  );

  final segmentDuration = duration.inMilliseconds ~/ segment;

  for (int i = 0; i < segment; i++) {
    final startTime = i * segmentDuration;

    final thumb = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG,
      quality: 75,
      timeMs: startTime,
    );

    if (thumb != null) {
      videoSegments.add(
        VideoSegment(
          times: startTime,
          thumbnail: thumb,
        ),
      );
    }
  }

  return videoSegments;
}
