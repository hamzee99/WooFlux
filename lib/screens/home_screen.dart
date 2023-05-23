import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/screens/singleProduct.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List products = [];
  List<Product> productss = [];
  List<Product> featuredProducts = [];
  List featureList = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    retrieveProducts();
    retrieveFeatured();
  }

  Future<void> retrieveProducts() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    print("entered the function");
    int pageNum = 1;
    bool hasMorePages = true;

    final url = Uri.parse('${baseUrl}products');
    final credentials = '$consumerKey:$customerSecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64.encode(bytes);
    final headers = {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/json'
    };
    while (hasMorePages) {
      final response =
          await http.get(Uri.parse('$url&page=$pageNum'), headers: headers);
      if (response.statusCode == 200) {
        isLoading = false;
        if (mounted) {
          setState(() {
            final data = json.decode(response.body);
            final data2 = json.decode(response.body) as List;
            productss.addAll(data2
                .map((json) => Product(
                    id: json['id'],
                    name: json['name'],
                    price: json['price'] == "0" ||
                            json['price'] == null ||
                            json['price'] == ''
                        ? 0.0
                        : double.parse(json['price']),
                    image: json['images'][0]['src']))
                .toList() as List<Product>);
            products.addAll(data);
            hasMorePages =
                (response.headers['link']?.contains('rel="next"') ?? false);
            pageNum++;
          });
        } else {
          // print("Didn't work");
        }
      }
    }
  }

  Future<void> retrieveFeatured() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    print("entered the function");
    int pageNum = 1;
    bool hasMorePages = true;

    final baseUrl1 = '${baseUrl}products';
    final credentials = '$consumerKey:$customerSecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64.encode(bytes);
    final headers = {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/json'
    };

    while (hasMorePages) {
      final url =
          Uri.parse(baseUrl1).replace(queryParameters: {'featured': 'true'});
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        isLoading = false;
        if (mounted) {
          setState(() {
            final data = json.decode(response.body);
            final data2 = json.decode(response.body) as List;
            featuredProducts.addAll(data2
                .map((json) => Product(
                    id: json['id'],
                    name: json['name'],
                    price: json['price'] == "0" ||
                            json['price'] == null ||
                            json['price'] == ''
                        ? 0.0
                        : double.parse(json['price']),
                    image: json['images'][0]['src']))
                .toList() as List<Product>);
            featureList.addAll(data);
            hasMorePages =
                (response.headers['link']?.contains('rel="next"') ?? false);
            pageNum++;
          });
        } else {
          //print("Didn't work");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    return Scaffold(
        body: ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.02,
        ),
        Text(
          "Featured Products",
          style: TextStyle(
              color: GlobalColors().primaryDarkColor,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.03,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.42,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.08,
                0,
                MediaQuery.of(context).size.width * 0.08,
                0),
            child: GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: featureList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                //crossAxisSpacing: 15,
                //mainAxisSpacing: 25,
              ),
              itemBuilder: (context, index) {
                final featured = featureList[index];
                final featuredProduct = featuredProducts[index];
                return InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SingleProduct(
                                id: featured['id'].toString(),
                                name: featured['name'],
                                price: featured['price'].toString(),
                                image: featured['images'][0]['src'],
                                quantity: featured['stock_quantity'].toString(),
                                desc: featured['short_description'],
                              ))),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.28,
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          width: MediaQuery.of(context).size.width * 0.3,
                          child: Image.network(
                            featured['images'][0]['src'],
                            fit: BoxFit.contain,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                              text: featured['name'],
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Rs  ${featured['price'].toString()}',
                          style: TextStyle(
                              color: GlobalColors().itemPrice,
                              fontWeight: FontWeight.bold),
                        ),
                        featured['stock_quantity'] != 0 &&
                                featured['stock_quantity'] != null
                            ? InkWell(
                                onTap: () {
                                  cartModel.addProductToCart(featuredProduct);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Added to cart')));
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.04,
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  decoration: BoxDecoration(
                                      color: GlobalColors().primaryColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: const [
                                        Text(
                                          "Add to cart",
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        Icon(
                                          Icons.shopping_cart,
                                          size: 18,
                                        )
                                      ]),
                                ),
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.04,
                                width: MediaQuery.of(context).size.width * 0.3,
                                decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        "Out of Stock",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ]),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    ));
  }
}
