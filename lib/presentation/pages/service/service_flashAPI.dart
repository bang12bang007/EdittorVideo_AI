import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

Future<File?> restoreImage(File imageFile) async {
  try {
    // Tạo request multipart
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/restore'), // Thay đổi URL nếu cần
    );

    // Thêm file vào request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Tên field phải khớp với API
        imageFile.path,
      ),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      // Tạo file mới để lưu ảnh đã phục hồi
      final restoredImagePath = path.join(
        path.dirname(imageFile.path),
        'restored_${path.basename(imageFile.path)}',
      );

      // Lưu response vào file
      final restoredImageFile = File(restoredImagePath);
      await restoredImageFile.writeAsBytes(
        await response.stream.toBytes(),
      );

      return restoredImageFile;
    } else {
      print('Lỗi: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Lỗi khi gọi API: $e');
    return null;
  }
}

Future<File?> restoreVideo(File videoFile) async {
  try {
    // Tạo request multipart
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://localhost:8000/enhance-video/'), // Thay đổi URL nếu cần
    );

    // Thêm file vào request
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Tên field phải khớp với API
        videoFile.path,
      ),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      // Tạo file mới để lưu ảnh đã phục hồi
      final restoredImagePath = path.join(
        path.dirname(videoFile.path),
        'restored_${path.basename(videoFile.path)}',
      );

      // Lưu response vào file
      final restoredImageFile = File(restoredImagePath);
      await restoredImageFile.writeAsBytes(
        await response.stream.toBytes(),
      );

      return restoredImageFile;
    } else {
      print('Lỗi: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Lỗi khi gọi API: $e');
    return null;
  }
}
