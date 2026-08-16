import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../../core/network/api_client.dart';

class StorageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick an image from gallery or camera
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
    }
    return null;
  }

  /// Upload file via multipart request through backend S3 gateway
  static Future<String?> uploadFile({
    required String bucket,
    required File file,
    required String remotePath,
  }) async {
    try {
      final fileName = p.basename(file.path);
      final formData = FormData.fromMap({
        'bucket': bucket,
        'path': remotePath,
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await ApiClient.post('/files/upload', data: formData);
      if (response.statusCode == 200) {
        final resData = response.data;
        if (resData is Map && resData.containsKey('data')) {
          return resData['data']?['fileUrl']?.toString();
        }
        if (resData is Map) {
          return resData['fileUrl']?.toString() ?? resData['url']?.toString();
        }
      }
    } catch (e) {
      print('Error uploading file: $e');
    }
    return null;
  }

  /// Upload profile picture helper
  static Future<String?> uploadProfilePhoto(String userId, File file) async {
    final extension = p.extension(file.path);
    final remotePath = '$userId/avatar$extension';
    return await uploadFile(bucket: 'avatars', file: file, remotePath: remotePath);
  }

  /// Upload cover photo helper
  static Future<String?> uploadCoverPhoto(String userId, File file) async {
    final extension = p.extension(file.path);
    final remotePath = '$userId/cover$extension';
    return await uploadFile(bucket: 'covers', file: file, remotePath: remotePath);
  }

  /// Upload post image helper
  static Future<String?> uploadPostImage(String userId, File file) async {
    final extension = p.extension(file.path);
    final uniqueId = DateTime.now().millisecondsSinceEpoch.toString();
    final remotePath = '$userId/$uniqueId$extension';
    return await uploadFile(bucket: 'post-images', file: file, remotePath: remotePath);
  }
}
