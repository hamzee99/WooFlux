import 'package:flutter/material.dart';
import 'package:fluxstore/models/product.dart';
import 'cart_model.dart';

class CartProvider extends ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addProductToCart(Product product) {
    _cart.addProduct(product);
    notifyListeners();
  }

  void removeProductFromCart(Product product) {
    _cart.removeProduct(product);
    notifyListeners();
  }

  void clearCart() {
    _cart.clearAllCart();
    notifyListeners();
  }

  void decreaseProductQuantity(Product product) {
    if (product.quantity > 1) {
      product.quantity--;
    } else {
      _cart.removeProduct(product);
    }
    notifyListeners();
  }
}
