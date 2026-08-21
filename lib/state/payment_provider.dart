import 'package:flutter/foundation.dart';
import '../models/order_receipt.dart';
import '../models/payment_method.dart';
import '../services/mock_payment_service.dart';
import '../services/payment_api_service.dart';
import '../services/payment_service.dart';

enum PaymentStatus { initial, processing, success, failed }

class PaymentProvider extends ChangeNotifier {
  final PaymentService _mockService;
  final PaymentApiService _apiService;

  PaymentProvider({
    PaymentService? mockService,
    PaymentApiService? apiService,
  })  : _mockService = mockService ?? MockPaymentService(),
        _apiService = apiService ?? PaymentApiService();

  PaymentMethod _selectedMethod = PaymentMethod.defaultMethods[1]; // InstaPay by default
  PaymentStatus _status = PaymentStatus.initial;
  String? _errorMessage;
  OrderReceipt? _lastReceipt;

  PaymentMethod get selectedMethod => _selectedMethod;
  PaymentStatus get status => _status;
  String? get errorMessage => _errorMessage;
  OrderReceipt? get lastReceipt => _lastReceipt;

  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<bool> processPayment({
    required double amount,
    bool isMock = false,
  }) async {
    _status = PaymentStatus.processing;
    _errorMessage = null;
    notifyListeners();

    if (isMock) {
      final result = await _mockService.processPayment(
        method: _selectedMethod,
        totalAmount: amount,
      );
      if (result.isSuccess) {
        _status = PaymentStatus.success;
        _lastReceipt = OrderReceipt(
          orderId: result.transactionId,
          orderNumber: result.transactionId,
          totalAmount: amount,
          paymentMethod: _selectedMethod.name.toUpperCase(),
          createdAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      } else {
        _status = PaymentStatus.failed;
        _errorMessage = result.errorMessage ?? 'Payment failed.';
        notifyListeners();
        return false;
      }
    }

    // Real backend checkout API call
    final result = await _apiService.checkout(
      paymentMethod: _selectedMethod,
    );

    if (result.isSuccess && result.receipt != null) {
      _status = PaymentStatus.success;
      _lastReceipt = result.receipt;
      notifyListeners();
      return true;
    } else {
      _status = PaymentStatus.failed;
      _errorMessage = result.errorMessage ?? 'Payment failed. Please try again.';
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = PaymentStatus.initial;
    _errorMessage = null;
    notifyListeners();
  }
}
