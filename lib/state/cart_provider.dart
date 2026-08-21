import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/cv_event.dart';
import '../models/product.dart';
import '../services/computer_vision_service.dart';

class CartProvider extends ChangeNotifier {
  final ComputerVisionService _cvService;
  StreamSubscription<CvEvent>? _cvSubscription;

  final Map<String, CartItem> _items = {};

  CartProvider(this._cvService) {
    _subscribeToCvEvents();
  }

  void _subscribeToCvEvents() {
    _cvSubscription = _cvService.eventStream.listen((event) {
      switch (event.type) {
        case CvEventType.productDetected:
          if (event.product != null) {
            _addProductFromCv(event.product!);
          }
          break;
        case CvEventType.productRemoved:
          if (event.productId != null) {
            _removeProductFromCv(event.productId!);
          }
          break;
        case CvEventType.cartCleared:
          _clearCart();
          break;
      }
    });
  }

  List<CartItem> get items => _items.values.toList();

  int get totalItemCount {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => _items.isEmpty;

  double get subtotal {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get tax => subtotal * AppConstants.taxRate;

  double get total => subtotal + tax;

  void _addProductFromCv(Product product) {
    if (_items.containsKey(product.id)) {
      final current = _items[product.id]!;
      _items[product.id] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _items[product.id] = CartItem(product: product, quantity: 1);
    }
    notifyListeners();
  }

  void _removeProductFromCv(String productId) {
    if (_items.containsKey(productId)) {
      final current = _items[productId]!;
      if (current.quantity > 1) {
        _items[productId] = current.copyWith(quantity: current.quantity - 1);
      } else {
        _items.remove(productId);
      }
      notifyListeners();
    }
  }

  // Remove completely regardless of quantity
  void removeProductCompletely(String productId) {
    if (_items.containsKey(productId)) {
      _items.remove(productId);
      notifyListeners();
    }
  }

  void _clearCart() {
    _items.clear();
    notifyListeners();
  }

  void clearCart() {
    _clearCart();
  }

  @override
  void dispose() {
    _cvSubscription?.cancel();
    super.dispose();
  }
}
