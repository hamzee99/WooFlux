import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/models/login_check.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../colors/colors.dart';
import '../models/product.dart';
import 'checkout.dart';
import 'login_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

Future<Map<String, dynamic>> getClientById(int id) async {
  String? baseUrl = dotenv.env['BASE_URL'];
  String? consumerKey = dotenv.env['CONSUMER_KEY'];
  String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
  final url = '${baseUrl}customers/$id';
  final response = await http.get(
    Uri.parse(url),
    headers: {
      'Authorization':
          'Basic ' + base64Encode(utf8.encode('$consumerKey:$customerSecret')),
    },
  );
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data;
  } else {
    print(response.statusCode);
    throw Exception('Failed to get client info');
  }
}

Future<Map<String, dynamic>> getProduct(int productId) async {
  String? baseUrl = dotenv.env['BASE_URL'];
  String? consumerKey = dotenv.env['CONSUMER_KEY'];
  String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
  final response = await http.get(
    Uri.parse('${baseUrl}products/$productId'),
    headers: {
      'Authorization':
          'Basic ' + base64Encode(utf8.encode('$consumerKey:$customerSecret')),
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final decoded = json.decode(response.body);
    return decoded;
  } else {
    throw Exception('Failed to load product');
  }
}

Future<Map<String, dynamic>> postOrder(int customerId, List<Product> products,
    double total, Map<String, dynamic> data) async {
  String? baseUrl = dotenv.env['BASE_URL'];
  String? consumerKey = dotenv.env['CONSUMER_KEY'];
  String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
  final String url =
      "${baseUrl}orders?consumer_key=$consumerKey&consumer_secret=$customerSecret";
  final response = await http.post(
    Uri.parse(url),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(data),
  );

  if (response.statusCode == 201) {
    // Update stock quantity for each product
    for (Product product in products) {
      final String productUrl =
          "${baseUrl}products/${product.id}?consumer_key=$consumerKey&consumer_secret=$customerSecret";
      final productResponse = await http.get(Uri.parse(productUrl));
      if (productResponse.statusCode == 200) {
        final Map<String, dynamic> productData =
            jsonDecode(productResponse.body);
        final int originalStockQuantity = productData["stock_quantity"];
        final int orderedQuantity = product.quantity;
        final int remainingStockQuantity =
            originalStockQuantity - orderedQuantity;
        final Map<String, dynamic> productUpdateData = {
          "stock_quantity": remainingStockQuantity
        };
        await http.put(Uri.parse(productUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(productUpdateData));
      } else {
        print(productResponse.statusCode);
        print(productResponse.body);
        throw Exception('Failed to get product data');
      }
    }
    return jsonDecode(response.body);
  } else {
    print(response.statusCode);
    print(response.body);
    throw Exception('Failed to post order');
  }
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? paymentIntent;
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    final log = Provider.of<LoginCheck>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: GlobalColors().primaryColor,
        title: SizedBox(
          height: MediaQuery.of(context).size.height * 0.18,
          child: Image.asset(
            "asset/images/logo.png",
            fit: BoxFit.cover,
          ),
        ),
        centerTitle: true,
      ),
      body: cartModel.cart.itemCount == 0
          ? const Center(child: Text('Your cart is empty'))
          : ListView.builder(
              itemCount: cartModel.cart.itemCount,
              itemBuilder: (context, index) {
                final product = cartModel.cart.items[index];

                return Dismissible(
                  key: Key(cartModel.cart.items.toString()),
                  onDismissed: (direction) {
                    setState(() {
                      cartModel.removeProductFromCart(product);
                    });
                  },
                  background: Container(
                    color: GlobalColors().itemPrice,
                  ),
                  child: ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                      '\Rs ${product.price}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    leading: Image.network(product.image),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            cartModel.decreaseProductQuantity(product);
                          },
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.035,
                          width: MediaQuery.of(context).size.width * 0.07,
                          child: Text(
                            product.quantity.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(border: Border.all()),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                          onPressed: () async {
                            final check = await getProduct(product.id);
                            if (check['stock_quantity'] != null) {
                              if (product.quantity < check['stock_quantity']) {
                                cartModel.addProductToCart(product);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Item quantity exceeds available quantity')));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cartModel.cart.itemCount == 0
          ? null
          : BottomAppBar(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:  Rs ${cartModel.cart.totalPrice.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: GlobalColors().itemPrice,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: GlobalColors().primaryDarkColor),
                      onPressed: () {
                        log.isLoggedIn == true
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Checkout()))
                            : showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      content: const Text(
                                          "Please Login to Continue"),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: GlobalColors()
                                                  .primaryDarkColor),
                                          onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const LoginScreen())),
                                          child: const Text("OK"),
                                        )
                                      ],
                                    ));
                      },
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
