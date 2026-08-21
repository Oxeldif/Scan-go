import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'face_recognition_service.dart';
import 'token_storage_service.dart';

class ApiFaceRecognitionService implements FaceRecognitionService {
  final http.Client _client;
  final TokenStorageService _tokenStorage;

  ApiFaceRecognitionService({
    http.Client? client,
    TokenStorageService? tokenStorage,
  })  : _client = client ?? http.Client(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  @override
  Future<void> initialize() async {}

  @override
  Future<FaceEnrollResult> enrollFace({
    required String userId,
    required String imagePath,
    Uint8List? imageBytes,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.faceEnrollEndpoint);
      final request = http.MultipartRequest('POST', uri);

      // Form fields
      request.fields['userId'] = userId;
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Authorization header if available
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add face image file
      if (imageBytes != null || kIsWeb) {
        final bytes = imageBytes ?? await File(imagePath).readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'faceImage',
            bytes,
            filename: 'face_enroll_$userId.jpg',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'faceImage',
            imagePath,
            filename: 'face_enroll_$userId.jpg',
          ),
        );
      }

      final streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 20),
          );
      final response = await http.Response.fromStream(streamedResponse);

      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        jsonResponse = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return FaceEnrollResult.success(
          message: jsonResponse is Map ? jsonResponse['message']?.toString() : null,
        );
      } else {
        final errorMsg = (jsonResponse is Map && jsonResponse['message'] != null)
            ? jsonResponse['message'].toString()
            : 'Face enrollment failed (${response.statusCode})';
        return FaceEnrollResult.failure(errorMsg, statusCode: response.statusCode);
      }
    } on TimeoutException {
      return FaceEnrollResult.failure(
        'Face enrollment timed out. Please check backend connection.',
        statusCode: 408,
      );
    } catch (e) {
      return FaceEnrollResult.failure('Enrollment network error: $e');
    } finally {
      _cleanupTempFile(imagePath);
    }
  }

  @override
  Future<FaceVerificationResult> verifyFace({
    required String imagePath,
    Uint8List? imageBytes,
    String? cartCode,
  }) async {
    try {
      final uri = Uri.parse(AppConstants.faceVerifyEndpoint);
      final request = http.MultipartRequest('POST', uri);

      if (cartCode != null) {
        request.fields['cartCode'] = cartCode;
      }
      request.fields['timestamp'] = DateTime.now().toIso8601String();

      // Add face image file
      if (imageBytes != null || kIsWeb) {
        final bytes = imageBytes ?? await File(imagePath).readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'faceImage',
            bytes,
            filename: 'face_verify_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'faceImage',
            imagePath,
            filename: 'face_verify_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        );
      }

      final streamedResponse = await _client.send(request).timeout(
            const Duration(seconds: 20),
          );
      final response = await http.Response.fromStream(streamedResponse);

      dynamic jsonResponse;
      try {
        jsonResponse = jsonDecode(response.body);
      } catch (_) {
        jsonResponse = {'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (jsonResponse is Map && jsonResponse['success'] == true) {
          final userId = jsonResponse['userId']?.toString() ?? '';
          final token = jsonResponse['token']?.toString() ?? '';
          return FaceVerificationResult.success(
            userId: userId,
            token: token,
            message: jsonResponse['message']?.toString(),
          );
        } else if (jsonResponse is Map && jsonResponse['success'] == false) {
          return FaceVerificationResult.failure(
            jsonResponse['message']?.toString() ?? 'Face not recognized.',
            statusCode: response.statusCode,
          );
        }
        return FaceVerificationResult.success(
          userId: jsonResponse is Map ? jsonResponse['userId']?.toString() ?? '' : '',
          token: jsonResponse is Map ? jsonResponse['token']?.toString() ?? '' : '',
        );
      } else {
        final errorMsg = (jsonResponse is Map && jsonResponse['message'] != null)
            ? jsonResponse['message'].toString()
            : 'Face verification failed (${response.statusCode})';
        return FaceVerificationResult.failure(errorMsg, statusCode: response.statusCode);
      }
    } on TimeoutException {
      return FaceVerificationResult.failure(
        'Face verification timed out. Please check backend connection.',
        statusCode: 408,
      );
    } catch (e) {
      return FaceVerificationResult.failure('Verification network error: $e');
    } finally {
      _cleanupTempFile(imagePath);
    }
  }

  void _cleanupTempFile(String path) {
    if (!kIsWeb && path.isNotEmpty) {
      try {
        final file = File(path);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
  }

  @override
  void cancel() {}
}
