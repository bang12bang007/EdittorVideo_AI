import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
const baseUrl = 'http://localhost:8000';
Future<File?> restoreImage(File imageFile) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/restore'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );
    var response = await request.send();

    if (response.statusCode == 200) {
      final restoredImagePath = path.join(
        path.dirname(imageFile.path),
        'restored_${path.basename(imageFile.path)}',
      );
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
    var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/enhance-video/'),
      );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        videoFile.path,
      ),
    );
    var response = await request.send().timeout(
      Duration(seconds: 5000),
      onTimeout: () {
        throw TimeoutException('Kết nối đến server quá thời gian chờ');
      },
    );

    if (response.statusCode == 200) {
      final restoredVideoPath = path.join(
        path.dirname(videoFile.path),
        'restored_${path.basename(videoFile.path)}',
      );

      final restoredVideofile = File(restoredVideoPath);
      await restoredVideofile.writeAsBytes(
        await response.stream.toBytes(),
      );

      return restoredVideofile;
    } else {
      throw Exception('Lỗi server: ${response.statusCode}');
    }
  } on SocketException {
    throw Exception('Không thể kết nối đến server. Hãy kiểm tra:\n'
        '1. Server đã được khởi động\n'
        '2. IP của server đã chính xác\n'
        '3. Thiết bị đang kết nối cùng mạng WiFi với server');
  } on TimeoutException {
    throw Exception('Kết nối đến server quá thời gian chờ');
  } catch (e) {
    throw Exception('Lỗi khi xử lý video: $e');
  }
}
Future<File?> restoreImageWithFineTuned(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/fine-tune'),
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
        ),
      );
      
      var response = await request.send();

      if (response.statusCode == 200) {
        final restoredImagePath = path.join(
          path.dirname(imageFile.path),
          'finetuned_restored_${path.basename(imageFile.path)}',
        );
        
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
      print('Lỗi khi gọi API fine-tuned: $e');
      return null;
    }
  }
  Future<File?> restoreVideoWithFineTuned(File videoFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/fine-tune-video/'),
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          videoFile.path,
        ),
      );
      
      var response = await request.send().timeout(
        Duration(seconds: 5000),
        onTimeout: () {
          throw TimeoutException('Kết nối đến server quá thời gian chờ');
        },
      );

      if (response.statusCode == 200) {
        final restoredVideoPath = path.join(
          path.dirname(videoFile.path),
          'finetuned_restored_${path.basename(videoFile.path)}',
        );

        final restoredVideoFile = File(restoredVideoPath);
        await restoredVideoFile.writeAsBytes(
          await response.stream.toBytes(),
        );

        return restoredVideoFile;
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Không thể kết nối đến server. Hãy kiểm tra:\n'
          '1. Server đã được khởi động\n'
          '2. IP của server đã chính xác\n'
          '3. Thiết bị đang kết nối cùng mạng WiFi với server');
    } on TimeoutException {
      throw Exception('Kết nối đến server quá thời gian chờ');
    } catch (e) {
      throw Exception('Lỗi khi xử lý video fine-tuned: $e');
    }
  }