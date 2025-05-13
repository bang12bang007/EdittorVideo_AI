import 'dart:io';
import 'package:another_flushbar/flushbar.dart' show Flushbar;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoPickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(BuildContext context) async {
    void showError(String message) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
    }

    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null || !await File(file.path).exists()) {
        showError("Không thể đọc file ảnh");
        return null;
      }

      return File(file.path);
    } catch (e) {
      debugPrint("Lỗi ảnh: $e");
      showError("Lỗi khi xử lý ảnh");
      return null;
    }
  }

  Future<VideoPickerResult?> pickVideo(BuildContext context) async {
    void showError(String message) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
    }

    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file == null || !await File(file.path).exists()) {
        showError("Không thể đọc file video");
        return null;
      }

      return VideoPickerResult(
        file: File(file.path),
        playerController: VideoPlayerController.file(File(file.path)),
        editorController: VideoEditorController.file(
          File(file.path),
          minDuration: const Duration(seconds: 1),
          maxDuration: const Duration(minutes: 10),
        ),
      );
    } catch (e) {
      debugPrint("Lỗi video: $e");
      showError("Lỗi khi xử lý video");
      return null;
    }
  }
}

class VideoPickerResult {
  final File file;
  final VideoPlayerController playerController;
  final VideoEditorController editorController;

  VideoPickerResult({
    required this.file,
    required this.playerController,
    required this.editorController,
  });
}
