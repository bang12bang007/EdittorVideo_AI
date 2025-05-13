// // lib/presentation/pages/service/service_media_picker.dart

// import 'package:image_picker/image_picker.dart';
// import 'dart:io';

// class MediaPickerService {
//   final ImagePicker _picker = ImagePicker();
//   static const int maxFiles = 5;

//   Future<List<Map<String, dynamic>>?> pickMultipleMedia({
//     required bool isVideo,
//   }) async {
//     try {
//       List<XFile>? pickedFiles;
      
//       if (isVideo) {
//         pickedFiles = await _picker.pickMultiVideo(
//           maxDuration: const Duration(minutes: 10),
//         );
//       } else {
//         pickedFiles = await _picker.pickMultiImage(
//           imageQuality: 80,
//         );
//       }

//       if (pickedFiles == null || pickedFiles.isEmpty) return null;

//       // Giới hạn số lượng file
//       if (pickedFiles.length > maxFiles) {
//         pickedFiles = pickedFiles.sublist(0, maxFiles);
//       }

//       List<Map<String, dynamic>> result = [];
//       for (var file in pickedFiles) {
//         result.add({
//           'file': File(file.path),
//           'type': isVideo ? 'video' : 'image',
//           'name': file.name,
//           'size': await file.length(),
//         });
//       }

//       return result;
//     } catch (e) {
//       print('Lỗi khi chọn media: $e');
//       return null;
//     }
//   }
// }