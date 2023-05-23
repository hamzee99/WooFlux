import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../colors/colors.dart';
import '../models/cart_helper.dart';
import '../models/login_check.dart';
import '../models/product.dart';
import 'navigate.dart';

class Checkout extends StatefulWidget {
  const Checkout({super.key});

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  bool isLoading = false;

  Future<Map<String, dynamic>> getClientById(int id) async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    final url = '${baseUrl}customers/$id';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Basic ' +
            base64Encode(utf8.encode('$consumerKey:$customerSecret')),
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

  Future<Map<String, dynamic>> postOrder(
      List<Product> products, double total, Map<String, dynamic> data) async {
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
      isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    final log = Provider.of<LoginCheck>(context);
    final storage = FlutterSecureStorage();
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
      body: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
          child: Text(
            "Checkout",
            style: TextStyle(
                color: GlobalColors().primaryDarkColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.31,
            width: MediaQuery.of(context).size.width * 0.75,
            decoration: BoxDecoration(
                border: Border.all(color: GlobalColors().primaryDarkColor)),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  MediaQuery.of(context).size.height * 0.02,
                  0,
                  MediaQuery.of(context).size.height * 0.02,
                  0),
              child: Column(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total : ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: GlobalColors().primaryDarkColor),
                    ),
                    Text('${cartModel.cart.totalPrice}',
                        style: TextStyle(color: GlobalColors().itemPrice))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Delivery Charges : ",
                        style: TextStyle(
                          color: GlobalColors().primaryDarkColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('0', style: TextStyle(color: GlobalColors().itemPrice))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Discount : ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: GlobalColors().primaryDarkColor)),
                    const Text(
                      '- 0',
                      style: TextStyle(color: Colors.green),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Grand Total : ",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: GlobalColors().itemPrice)),
                    Text('${cartModel.cart.totalPrice}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: GlobalColors().itemPrice)),
                  ],
                ),
              ]),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.36,
          child: isLoading == true
              ? Center(
                  child: SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    color: GlobalColors().primaryDarkColor,
                  ),
                ))
              : const Text(''),
        ),
        InkWell(
          onTap: () async {
            if (log.isLoggedIn == true) {
              isLoading = true;
              setState(() {});
              final customer = await storage.read(key: 'id');
              final List<Map<String, dynamic>> lineItems =
                  cartModel.cart.items.map((product) {
                return {
                  "product_id": product.id,
                  "quantity": product.quantity,
                  // Add any other required fields for the line item
                };
              }).toList();

              final client = await getClientById(int.parse(customer!));
              print(client['first_name']);
              final Map<String, dynamic> orderData = {
                "customer_id": int.parse(customer),
                "line_items": lineItems,
                "total": cartModel.cart.totalPrice,
                "billing": {
                  "first_name": client['first_name'],
                  "address_1": client['billing']['address_1'],
                  "city": client['billing']['city'],
                  "state": client['billing']['state'],
                  "country": client['billing']['country'],
                  "phone": client['billing']['phone']
                },
                "shipping": {
                  "first_name": client['first_name'],
                  "address_1": client['billing']['address_1'],
                  "city": client['billing']['city'],
                  "state": client['billing']['state'],
                  "country": client['billing']['country'],
                  "phone": client['billing']['phone']
                },
              };
              print(orderData);

              final order = await postOrder(
                  cartModel.cart.items, cartModel.cart.totalPrice, orderData);
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        content: Text("Order has been pLaced successfully "),
                        title: Text("SUCCESS"),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                cartModel.clearCart();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Navigate(index: 1)));
                              },
                              child: Text("OK"))
                        ],
                      ));
            }
          },
          child: Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height * 0.065,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: GlobalColors().primaryDarkColor),
            child: const Text(
              "Place Order",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ]),
    );
  }
}
