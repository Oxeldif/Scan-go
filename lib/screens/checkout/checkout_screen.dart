import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/payment_method.dart';
import '../../state/cart_provider.dart';
import '../../state/payment_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/scango_logo.dart';
import '../../widgets/step_progress_bar.dart';
import '../payment/payment_failed_screen.dart';
import '../payment/payment_success_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _simulateFailure = false;

  void _handlePaymentSubmit() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );

    final result = await paymentProvider.processPayment(
      cartProvider.total,
      simulateFailure: _simulateFailure,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      cartProvider.clearCart(); // Clear cart on success per requirement
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
      );
    } else {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const PaymentFailedScreen()));
    }
  }

  Widget _buildPaymentOptionTile(PaymentMethod method, PaymentMethod selected) {
    final isSelected = method.type == selected.type;

    IconData iconData = Icons.credit_card;
    Color iconColor = Colors.grey;

    if (method.type == PaymentMethodType.vodafoneCash) {
      iconData = Icons.phone_android;
      iconColor = Colors.red;
    } else if (method.type == PaymentMethodType.instaPay) {
      iconData = Icons.flash_on;
      iconColor = Colors.purple;
    } else if (method.type == PaymentMethodType.visaCard) {
      iconData = Icons.credit_card;
      iconColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        Provider.of<PaymentProvider>(
          context,
          listen: false,
        ).selectPaymentMethod(method);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderLight,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Text(
              method.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final selectedMethod = paymentProvider.selectedMethod;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const ScanGoLogo(height: 38, isDarkBackground: false),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Step Progress Indicator
              const StepProgressBar(currentStep: 2),
              const SizedBox(height: 24),

              // Order Summary Container
              const Text(
                'Order Summary',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Sub total',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(cartProvider.subtotal),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'tax(3%)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(cartProvider.tax),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.borderLight),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(cartProvider.total),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Payment Method Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'payment method',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  // Simulation Toggle for Testing
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _simulateFailure = !_simulateFailure;
                      });
                    },
                    child: Text(
                      _simulateFailure
                          ? '[Simulating: FAIL]'
                          : '[Simulating: SUCCESS]',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _simulateFailure ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              ...PaymentMethod.defaultMethods.map(
                (method) => _buildPaymentOptionTile(method, selectedMethod),
              ),

              const Spacer(),

              // Digital receipt note from screenshot
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ⓘ ',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  Expanded(
                    child: Text(
                      'Note: Your digital receipt will be sent after successful payment.',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Next Button
              PrimaryButton(
                label: 'Next',
                isLoading:
                    paymentProvider.status ==
                    PaymentProcessingStatus.processing,
                backgroundColor: AppColors.primaryGreenDark,
                onPressed:
                    paymentProvider.status == PaymentProcessingStatus.processing
                    ? null
                    : _handlePaymentSubmit,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
