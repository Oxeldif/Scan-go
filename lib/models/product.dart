class Product {
  final dynamic id;
  final String name;
  final String? nameAr;
  final String? nameEn;
  final String? barcode;
  final double price;
  final String imageUrl;
  final String? category;
  final double weightGrams;

  const Product({
    required this.id,
    required this.name,
    this.nameAr,
    this.nameEn,
    this.barcode,
    required this.price,
    required this.imageUrl,
    this.category,
    this.weightGrams = 0.0,
  });

  String get weight => weightGrams > 0 ? '${weightGrams.toInt()}g' : '95g';

  factory Product.fromJson(Map<String, dynamic> json) {
    final double parsedPrice = (json['price'] is num)
        ? (json['price'] as num).toDouble()
        : double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    final double parsedWeight = (json['weightGrams'] is num)
        ? (json['weightGrams'] as num).toDouble()
        : double.tryParse(json['weightGrams']?.toString() ?? '0') ?? 0.0;

    final String nameEnVal = json['nameEn']?.toString() ?? '';
    final String nameArVal = json['nameAr']?.toString() ?? '';
    final String defaultName = json['name']?.toString() ??
        (nameEnVal.isNotEmpty ? nameEnVal : (nameArVal.isNotEmpty ? nameArVal : 'Product'));

    return Product(
      id: json['id'] ?? json['productId'] ?? '',
      name: defaultName,
      nameAr: nameArVal.isNotEmpty ? nameArVal : null,
      nameEn: nameEnVal.isNotEmpty ? nameEnVal : null,
      barcode: json['barcode']?.toString(),
      price: parsedPrice,
      imageUrl: json['imageUrl']?.toString() ?? '',
      category: json['category']?.toString(),
      weightGrams: parsedWeight,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'barcode': barcode,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'weightGrams': weightGrams,
    };
  }
}
