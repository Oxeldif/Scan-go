import '../models/payment_method.dart';

class PaymentResult {
  final bool isSuccess;
  final String transactionId;
  final String? errorMessage;

  const PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    this.errorMessage,
  });
}

abstract class PaymentService {
  Future<PaymentResult> processPayment({
    required PaymentMethod method,
    required double totalAmount,
    bool shouldFail = false,
  });
}
