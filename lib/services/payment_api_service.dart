import '../core/constants/app_constants.dart';
import '../models/order_receipt.dart';
import '../models/payment_method.dart';
import 'api_client.dart';

class PaymentResult {
  final bool isSuccess;
  final OrderReceipt? receipt;
  final String? errorMessage;

  const PaymentResult({
    required this.isSuccess,
    this.receipt,
    this.errorMessage,
  });

  factory PaymentResult.success(OrderReceipt receipt) => PaymentResult(
        isSuccess: true,
        receipt: receipt,
      );

  factory PaymentResult.failure(String message) => PaymentResult(
        isSuccess: false,
        errorMessage: message,
      );
}

class PaymentApiService {
  final ApiClient _apiClient;

  PaymentApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<PaymentResult> checkout({
    required PaymentMethod paymentMethod,
    String? notes,
  }) async {
    String methodString = 'INSTAPAY';
    switch (paymentMethod.type) {
      case PaymentMethodType.instaPay:
        methodString = 'INSTAPAY';
        break;
      case PaymentMethodType.vodafoneCash:
        methodString = 'VODAFONE_CASH';
        break;
      case PaymentMethodType.visaCard:
        methodString = 'VISA';
        break;
    }

    final Map<String, dynamic> body = {
      'paymentMethod': methodString,
    };
    if (notes != null) body['notes'] = notes;

    final response = await _apiClient.post(
      AppConstants.checkoutEndpoint,
      body: body,
    );

    if (response.isSuccess && response.data is Map) {
      final rootData = response.data as Map;
      final payload = rootData['data'] is Map ? rootData['data'] as Map : rootData;
      final receipt = OrderReceipt.fromJson(Map<String, dynamic>.from(payload));
      return PaymentResult.success(receipt);
    } else {
      return PaymentResult.failure(
        response.errorMessage ?? 'Payment checkout failed. Please try again.',
      );
    }
  }
}
