import 'product.dart';

class CartItem {
  final dynamic cartItemId;
  final Product product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String detectedBy;

  const CartItem({
    this.cartItemId,
    required this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.detectedBy = 'AI',
  });

  CartItem copyWith({
    dynamic cartItemId,
    Product? product,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? detectedBy,
  }) {
    final int newQty = quantity ?? this.quantity;
    final double newPrice = unitPrice ?? this.unitPrice;
    return CartItem(
      cartItemId: cartItemId ?? this.cartItemId,
      product: product ?? this.product,
      quantity: newQty,
      unitPrice: newPrice,
      totalPrice: totalPrice ?? (newQty * newPrice),
      detectedBy: detectedBy ?? this.detectedBy,
    );
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final int qty = (json['quantity'] is num)
        ? (json['quantity'] as num).toInt()
        : int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;

    final double price = (json['unitPrice'] is num)
        ? (json['unitPrice'] as num).toDouble()
        : (json['price'] is num)
            ? (json['price'] as num).toDouble()
            : double.tryParse(json['unitPrice']?.toString() ?? '0') ?? 0.0;

    final double total = (json['totalPrice'] is num)
        ? (json['totalPrice'] as num).toDouble()
        : (qty * price);

    // Product can be nested or flat
    final Product prod = json['product'] != null
        ? Product.fromJson(Map<String, dynamic>.from(json['product'] as Map))
        : Product.fromJson(json);

    return CartItem(
      cartItemId: json['cartItemId'] ?? json['id'],
      product: prod,
      quantity: qty,
      unitPrice: price,
      totalPrice: total,
      detectedBy: json['detectedBy']?.toString() ?? 'AI',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartItemId': cartItemId,
      'product': product.toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'detectedBy': detectedBy,
    };
  }
}
