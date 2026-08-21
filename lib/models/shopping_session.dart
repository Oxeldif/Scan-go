import 'cart_item.dart';

class ShoppingSession {
  final dynamic sessionId;
  final String cartCode;
  final dynamic userId;
  final bool faceVerified;
  final String status;
  final int itemsCount;
  final double subtotal;
  final double tax;
  final double grandTotal;
  final List<CartItem> items;
  final DateTime createdAt;

  const ShoppingSession({
    required this.sessionId,
    required this.cartCode,
    required this.userId,
    this.faceVerified = false,
    this.status = 'ACTIVE',
    this.itemsCount = 0,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.grandTotal = 0.0,
    this.items = const [],
    required this.createdAt,
  });

  bool get isActive => status.toUpperCase() == 'ACTIVE';

  factory ShoppingSession.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];
    final parsedItems = rawItems
        .map((i) => CartItem.fromJson(Map<String, dynamic>.from(i as Map)))
        .toList();

    final sub = (json['subtotal'] is num)
        ? (json['subtotal'] as num).toDouble()
        : double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0;

    final tx = (json['tax'] is num)
        ? (json['tax'] as num).toDouble()
        : double.tryParse(json['tax']?.toString() ?? '0') ?? 0.0;

    final total = (json['grandTotal'] is num)
        ? (json['grandTotal'] as num).toDouble()
        : (json['totalAmount'] is num)
            ? (json['totalAmount'] as num).toDouble()
            : (sub + tx);

    return ShoppingSession(
      sessionId: json['sessionId'] ?? json['id'] ?? '',
      cartCode: json['cartCode']?.toString() ?? json['cartId']?.toString() ?? 'CART_01',
      userId: json['userId'] ?? json['user']?['id'] ?? '',
      faceVerified: json['faceVerified'] == true,
      status: json['status']?.toString() ?? json['sessionStatus']?.toString() ?? 'ACTIVE',
      itemsCount: json['itemsCount'] is num
          ? (json['itemsCount'] as num).toInt()
          : parsedItems.fold(0, (acc, item) => acc + item.quantity),
      subtotal: sub,
      tax: tx,
      grandTotal: total,
      items: parsedItems,
      createdAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString()) ?? DateTime.now()
          : json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cartCode': cartCode,
      'userId': userId,
      'faceVerified': faceVerified,
      'status': status,
      'itemsCount': itemsCount,
      'subtotal': subtotal,
      'tax': tax,
      'grandTotal': grandTotal,
      'items': items.map((i) => i.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
