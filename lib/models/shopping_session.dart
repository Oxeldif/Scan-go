class ShoppingSession {
  final String sessionId;
  final String cartId;
  final String userId;
  final bool isActive;
  final DateTime createdAt;

  const ShoppingSession({
    required this.sessionId,
    required this.cartId,
    required this.userId,
    this.isActive = true,
    required this.createdAt,
  });

  factory ShoppingSession.fromJson(Map<String, dynamic> json) {
    return ShoppingSession(
      sessionId: json['sessionId']?.toString() ?? '',
      cartId: json['cartId']?.toString() ?? 'cart_default',
      userId: json['userId']?.toString() ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'cartId': cartId,
      'userId': userId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
