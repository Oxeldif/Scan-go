import '../core/constants/app_constants.dart';
import '../models/product.dart';

class ProductRepository {
  static const Product doritos = Product(
    id: AppConstants.doritosId,
    name: 'Nacho Cheese Doritos',
    weight: '70g',
    price: 10.00,
    imagePath: 'assets/doritos.png',
  );

  static const Product tuna = Product(
    id: AppConstants.tunaId,
    name: 'Sunshine Tuna - Chunks',
    weight: '185g',
    price: 65.00,
    imagePath: 'assets/tuna.png',
  );

  static const Product honey = Product(
    id: AppConstants.honeyId,
    name: 'Imtenan Spring Flowers - Pure Bee Honey',
    weight: '450g',
    price: 145.00,
    imagePath: 'assets/honey.png',
  );

  static List<Product> get catalog => [doritos, tuna, honey];

  static Product? findById(String id) {
    try {
      return catalog.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
