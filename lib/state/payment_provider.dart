import 'package:flutter/foundation.dart';
import '../models/payment_method.dart';
import '../services/payment_service.dart';

enum PaymentProcessingStatus { idle, processing, success, failed }

class PaymentProvider extends ChangeNotifier {
  final PaymentService _paymentService;

  PaymentProvider(this._paymentService);

  PaymentMethod _selectedMethod = PaymentMethod.defaultMethods.first;
  PaymentMethod get selectedMethod => _selectedMethod;

  PaymentProcessingStatus _status = PaymentProcessingStatus.idle;
  PaymentProcessingStatus get status => _status;

  String? _transactionId;
  String? get transactionId => _transactionId;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void selectPaymentMethod(PaymentMethod method) {
    _selectedMethod = method;
    notifyListeners();
  }

  Future<PaymentResult> processPayment(double totalAmount, {bool simulateFailure = false}) async {
    _status = PaymentProcessingStatus.processing;
    notifyListeners();

    final result = await _paymentService.processPayment(
      method: _selectedMethod,
      totalAmount: totalAmount,
      shouldFail: simulateFailure,
    );

    if (result.isSuccess) {
      _status = PaymentProcessingStatus.success;
      _transactionId = result.transactionId;
      _errorMessage = null;
    } else {
      _status = PaymentProcessingStatus.failed;
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
    return result;
  }

  void reset() {
    _status = PaymentProcessingStatus.idle;
    _transactionId = null;
    _errorMessage = null;
    notifyListeners();
  }
}
