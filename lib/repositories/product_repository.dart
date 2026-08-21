import '../models/product.dart';

class ProductRepository {
  static const Product doritos = Product(
    id: 1,
    name: 'Nacho Cheese Doritos',
    nameAr: 'دوريتوس فلفل حلو',
    nameEn: 'Doritos Sweet Chili 95g',
    barcode: '6221001004',
    weightGrams: 70,
    price: 10.00,
    imageUrl: 'assets/doritos.png',
    category: 'Snacks',
  );

  static const Product tuna = Product(
    id: 2,
    name: 'Sunshine Tuna - Chunks',
    nameAr: 'تونة صن شاين قطع',
    nameEn: 'Sunshine Tuna Chunks 185g',
    barcode: '6221001010',
    weightGrams: 185,
    price: 65.00,
    imageUrl: 'assets/tuna.png',
    category: 'Canned Food',
  );

  static const Product honey = Product(
    id: 3,
    name: 'Imtenan Spring Flowers - Pure Bee Honey',
    nameAr: 'عسل نحل امتنان زهور برية',
    nameEn: 'Imtenan Bee Honey 450g',
    barcode: '6221001011',
    weightGrams: 450,
    price: 145.00,
    imageUrl: 'assets/honey.png',
    category: 'Honey',
  );

  static List<Product> get catalog => [doritos, tuna, honey];

  static Product? findById(dynamic id) {
    try {
      return catalog.firstWhere((p) => p.id.toString() == id.toString());
    } catch (_) {
      return null;
    }
  }
}
