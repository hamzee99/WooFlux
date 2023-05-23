import 'package:flutter/material.dart';
import 'package:fluxstore/models/product.dart';

class Cart extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  void addProduct(Product product) {
    final index = _items.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _items[index].quantity++; // increment quantity if product already exists
    } else {
      _items.add(product); // add new product to cart
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.remove(product);
  }

  void clearAllCart() {
    _items.clear();
  }

  double get totalPrice => _items.fold(
      0, (total, product) => total + product.price! * product.quantity);

  int get itemCount => _items.length;
}
