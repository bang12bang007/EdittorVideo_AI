import 'dart:typed_data';

class VideoSegment {
  final int times;
  final Uint8List thumbnail;

  VideoSegment({
    required this.times,
    required this.thumbnail,
  });
}
