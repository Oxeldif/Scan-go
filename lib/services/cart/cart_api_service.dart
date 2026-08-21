import '../../core/constants/app_constants.dart';
import '../../models/shopping_session.dart';
import '../api_client.dart';

class CartApiService {
  final ApiClient _apiClient;

  CartApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<ShoppingSession?> pairCart({
    String? cartCode,
    bool faceVerified = false,
  }) async {
    final response = await _apiClient.post(
      AppConstants.pairCartEndpoint,
      body: {
        'cartCode': cartCode ?? AppConstants.defaultCartCode,
        'faceVerified': faceVerified,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      return ShoppingSession.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<ShoppingSession?> getActiveCart() async {
    final response = await _apiClient.get(AppConstants.activeCartEndpoint);
    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      if (rootData['data'] is Map) {
        return ShoppingSession.fromJson(Map<String, dynamic>.from(rootData['data'] as Map));
      }
    }
    return null;
  }

  Future<ShoppingSession?> addItem({
    dynamic productId,
    String? barcode,
  }) async {
    final Map<String, dynamic> body = {};
    if (productId != null) body['productId'] = productId;
    if (barcode != null) body['barcode'] = barcode;

    final response = await _apiClient.post(
      AppConstants.addCartItemEndpoint,
      body: body,
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      return ShoppingSession.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<ShoppingSession?> removeItem({
    required dynamic cartItemId,
    bool forceDelete = false,
  }) async {
    final response = await _apiClient.post(
      AppConstants.removeCartItemEndpoint,
      body: {
        'cartItemId': cartItemId,
        'forceDelete': forceDelete,
      },
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      return ShoppingSession.fromJson(Map<String, dynamic>.from(payload));
    }
    return null;
  }

  Future<bool> unpairCart() async {
    final response = await _apiClient.post(AppConstants.unpairCartEndpoint);
    return response.isSuccess;
  }

  Future<bool> sendAiDetectionWebhook({
    String? cartCode,
    dynamic productId,
    String? barcode,
    String? label,
    double confidence = 0.95,
    String action = 'added',
  }) async {
    final Map<String, dynamic> body = {
      'cart_code': cartCode ?? AppConstants.defaultCartCode,
      'confidence': confidence,
      'action': action,
    };
    if (productId != null) body['product_id'] = productId;
    if (barcode != null) body['barcode'] = barcode;
    if (label != null) body['label'] = label;

    final response = await _apiClient.post(
      AppConstants.aiDetectionEndpoint,
      body: body,
    );
    return response.isSuccess;
  }
}
