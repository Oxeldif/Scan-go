import 'cart_item.dart';

class OrderReceipt {
  final dynamic orderId;
  final String orderNumber;
  final double totalAmount;
  final double subtotal;
  final double tax;
  final int itemsCount;
  final String paymentMethod;
  final String paymentStatus;
  final String? exitQrCode;
  final String? cartCode;
  final List<CartItem> items;
  final DateTime createdAt;
  final String? notes;

  const OrderReceipt({
    required this.orderId,
    required this.orderNumber,
    required this.totalAmount,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.itemsCount = 0,
    required this.paymentMethod,
    this.paymentStatus = 'COMPLETED',
    this.exitQrCode,
    this.cartCode,
    this.items = const [],
    required this.createdAt,
    this.notes,
  });

  factory OrderReceipt.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final parsedItems = rawItems
        .map((i) => CartItem.fromJson(Map<String, dynamic>.from(i as Map)))
        .toList();

    final total = (json['totalAmount'] is num)
        ? (json['totalAmount'] as num).toDouble()
        : (json['total'] is num)
            ? (json['total'] as num).toDouble()
            : double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0;

    final sub = (json['subtotal'] is num)
        ? (json['subtotal'] as num).toDouble()
        : total;

    final tx = (json['tax'] is num)
        ? (json['tax'] as num).toDouble()
        : 0.0;

    final count = json['itemsCount'] is num
        ? (json['itemsCount'] as num).toInt()
        : parsedItems.fold(0, (acc, item) => acc + item.quantity);

    return OrderReceipt(
      orderId: json['orderId'] ?? json['id'] ?? '',
      orderNumber: json['orderNumber']?.toString() ?? 'ORD-SCAN-GO',
      totalAmount: total,
      subtotal: sub,
      tax: tx,
      itemsCount: count,
      paymentMethod: json['paymentMethod']?.toString() ?? 'INSTAPAY',
      paymentStatus: json['paymentStatus']?.toString() ?? 'COMPLETED',
      exitQrCode: json['exitQrCode']?.toString(),
      cartCode: json['cartCode']?.toString(),
      items: parsedItems,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'totalAmount': totalAmount,
      'subtotal': subtotal,
      'tax': tax,
      'itemsCount': itemsCount,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'exitQrCode': exitQrCode,
      'cartCode': cartCode,
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'notes': notes,
    };
  }
}
