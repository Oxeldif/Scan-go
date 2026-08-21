import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import '../models/cart_item.dart';
import '../models/cv_event.dart';
import '../models/product.dart';
import '../models/shopping_session.dart';
import '../services/cart/cart_api_service.dart';
import '../services/computer_vision_service.dart';
import '../services/socket/socket_cart_service.dart';

class CartProvider extends ChangeNotifier {
  final ComputerVisionService? _cvService;
  final CartApiService _cartApiService;
  final SocketCartService? _socketCartService;

  StreamSubscription<CvEvent>? _cvSubscription;
  StreamSubscription<CartUpdateEvent>? _socketSubscription;

  List<CartItem> _items = [];
  CvEvent? _lastEvent;
  Product? _lastDetectedProduct;
  bool _isLoading = false;

  CartProvider({
    this._cvService,
    CartApiService? cartApiService,
    this._socketCartService,
  })  : _cartApiService = cartApiService ?? CartApiService() {
    _initListeners();
  }

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalItemCount => itemCount;
  CvEvent? get lastEvent => _lastEvent;
  Product? get lastDetectedProduct => _lastDetectedProduct;
  bool get isLoading => _isLoading;

  void removeProductCompletely(dynamic productId) {
    removeItem(productId, forceDelete: true);
  }

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get tax => subtotal * AppConstants.taxRate;

  double get total => subtotal + tax;

  void _initListeners() {
    // 1. Listen for Real-Time Socket.io Cart Updates from Backend
    if (_socketCartService != null) {
      _socketSubscription = _socketCartService.onCartUpdate.listen((event) {
        debugPrint('🛒 [CartProvider] Received Socket Cart Update: ${event.action}');

        if (event.updatedCart != null) {
          syncWithBackendCart(event.updatedCart!);
        }

        if (event.detectedProduct != null) {
          final prod = Product.fromJson(event.detectedProduct!);
          _lastDetectedProduct = prod;
          _lastEvent = event.action == 'item_removed'
              ? CvEvent.removed(prod.id.toString())
              : CvEvent.detected(prod);
        }
        notifyListeners();
      });
    }

    // 2. Listen for Local / Simulated CV Events if present
    if (_cvService != null) {
      _cvSubscription = _cvService.eventStream.listen((event) {
        _lastEvent = event;
        _lastDetectedProduct = event.product;
        _handleLocalCvEvent(event);
      });
    }
  }

  void syncWithBackendCart(ShoppingSession session) {
    _items = List.from(session.items);
    notifyListeners();
  }

  Future<void> fetchActiveCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final session = await _cartApiService.getActiveCart();
      if (session != null) {
        _items = List.from(session.items);
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Product product, {int quantity = 1}) async {
    // Optimistic local update
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      final currentItem = _items[index];
      final newQuantity = currentItem.quantity + quantity;
      _items[index] = currentItem.copyWith(
        quantity: newQuantity,
        totalPrice: newQuantity * currentItem.unitPrice,
      );
    } else {
      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
          unitPrice: product.price,
          totalPrice: product.price * quantity,
        ),
      );
    }
    notifyListeners();

    // Call backend API / AI detection webhook
    try {
      await _cartApiService.addItem(productId: product.id, barcode: product.barcode);
    } catch (_) {}
  }

  Future<void> removeItem(dynamic productId, {bool forceDelete = false}) async {
    final index = _items.indexWhere((item) => item.product.id == productId || item.cartItemId == productId);
    if (index >= 0) {
      final currentItem = _items[index];
      if (!forceDelete && currentItem.quantity > 1) {
        final newQuantity = currentItem.quantity - 1;
        _items[index] = currentItem.copyWith(
          quantity: newQuantity,
          totalPrice: newQuantity * currentItem.unitPrice,
        );
      } else {
        _items.removeAt(index);
      }
      notifyListeners();

      try {
        if (currentItem.cartItemId != null) {
          await _cartApiService.removeItem(cartItemId: currentItem.cartItemId, forceDelete: forceDelete);
        }
      } catch (_) {}
    }
  }

  void _handleLocalCvEvent(CvEvent event) {
    if (event.type == CvEventType.productDetected && event.product != null) {
      final prod = event.product!;
      final index = _items.indexWhere((item) => item.product.id == prod.id);
      if (index >= 0) {
        final current = _items[index];
        _items[index] = current.copyWith(
          quantity: current.quantity + 1,
          totalPrice: (current.quantity + 1) * current.unitPrice,
        );
      } else {
        _items.add(
          CartItem(
            product: prod,
            quantity: 1,
            unitPrice: prod.price,
            totalPrice: prod.price,
          ),
        );
      }
    } else if (event.type == CvEventType.productRemoved) {
      final targetId = event.productId?.toString() ?? event.product?.id?.toString();
      if (targetId != null) {
        final index = _items.indexWhere((item) => item.product.id.toString() == targetId);
        if (index >= 0) {
          final current = _items[index];
          if (current.quantity > 1) {
            _items[index] = current.copyWith(
              quantity: current.quantity - 1,
              totalPrice: (current.quantity - 1) * current.unitPrice,
            );
          } else {
            _items.removeAt(index);
          }
        }
      }
    } else if (event.type == CvEventType.cartCleared) {
      _items.clear();
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _lastEvent = null;
    _lastDetectedProduct = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _cvSubscription?.cancel();
    _socketSubscription?.cancel();
    super.dispose();
  }
}
