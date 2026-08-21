import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/constants/app_constants.dart';
import '../../models/shopping_session.dart';

class CartUpdateEvent {
  final String action; // "item_added", "item_removed"
  final Map<String, dynamic>? detectedProduct;
  final ShoppingSession? updatedCart;

  const CartUpdateEvent({
    required this.action,
    this.detectedProduct,
    this.updatedCart,
  });
}

class SocketCartService {
  io.Socket? _socket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final _cartUpdateController = StreamController<CartUpdateEvent>.broadcast();
  Stream<CartUpdateEvent> get onCartUpdate => _cartUpdateController.stream;

  final _checkoutCompletedController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onCheckoutCompleted => _checkoutCompletedController.stream;

  String? _currentCartCode;
  dynamic _currentUserId;

  void connect({dynamic userId, String? cartCode}) {
    if (_socket != null && _isConnected) {
      joinRooms(userId: userId, cartCode: cartCode);
      return;
    }

    _currentUserId = userId;
    _currentCartCode = cartCode ?? AppConstants.defaultCartCode;

    try {
      final serverUrl = AppConstants.socketUrl;
      debugPrint('🔌 Connecting Socket.io to $serverUrl');

      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .disableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket!.onConnect((_) {
        debugPrint('✅ Socket.io Connected to backend: ${_socket?.id}');
        _isConnected = true;
        joinRooms(userId: _currentUserId, cartCode: _currentCartCode);
      });

      _socket!.onDisconnect((_) {
        debugPrint('❌ Socket.io Disconnected from backend');
        _isConnected = false;
      });

      _socket!.onConnectError((err) {
        debugPrint('⚠️ Socket.io Connection error: $err');
        _isConnected = false;
      });

      // Listen for cart:updated events
      _socket!.on('cart:updated', (data) {
        debugPrint('📦 [Socket.io] Received cart:updated event: $data');
        if (data is Map) {
          try {
            final action = data['action']?.toString() ?? 'item_added';
            final detectedProd = data['detectedProduct'] is Map
                ? Map<String, dynamic>.from(data['detectedProduct'] as Map)
                : null;
            final cartData = data['cart'] is Map
                ? Map<String, dynamic>.from(data['cart'] as Map)
                : null;

            final session = cartData != null ? ShoppingSession.fromJson(cartData) : null;

            _cartUpdateController.add(
              CartUpdateEvent(
                action: action,
                detectedProduct: detectedProd,
                updatedCart: session,
              ),
            );
          } catch (e) {
            debugPrint('Error parsing cart:updated socket event: $e');
          }
        }
      });

      // Listen for checkout:completed events
      _socket!.on('checkout:completed', (data) {
        debugPrint('💳 [Socket.io] Received checkout:completed event: $data');
        if (data is Map) {
          _checkoutCompletedController.add(Map<String, dynamic>.from(data));
        }
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('Socket initialization exception: $e');
    }
  }

  void joinRooms({dynamic userId, String? cartCode}) {
    if (_socket == null) return;

    if (userId != null) {
      _currentUserId = userId;
      _socket!.emit('join:user', userId.toString());
      debugPrint('👤 Emitted join:user -> $userId');
    }

    if (cartCode != null) {
      _currentCartCode = cartCode;
      _socket!.emit('join:cart', cartCode);
      debugPrint('🛒 Emitted join:cart -> $cartCode');
    }
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _isConnected = false;
  }

  void dispose() {
    disconnect();
    _cartUpdateController.close();
    _checkoutCompletedController.close();
  }
}
