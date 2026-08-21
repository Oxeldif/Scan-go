class Product {
  final String id;
  final String name;
  final String weight;
  final double price;
  final String imagePath;

  const Product({
    required this.id,
    required this.name,
    required this.weight,
    required this.price,
    required this.imagePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
