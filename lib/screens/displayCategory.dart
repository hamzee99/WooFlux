import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/screens/singleProduct.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../widgets/myAppBar.dart';

class DisplayByCategory extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  const DisplayByCategory(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  State<DisplayByCategory> createState() => _DisplayByCategoryState();
}

class _DisplayByCategoryState extends State<DisplayByCategory> {
  List products = [];
  List<Product> productss = [];
  List<Product> searchResults = [];
  final searchController = TextEditingController();

  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    retrieveProductsByCategory();
  }

  Future<void> retrieveProductsByCategory() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    print("entered the function");
    int pageNum = 1;
    bool hasMorePages = true;

    final url = Uri.parse(
        '${baseUrl}products?category=${int.parse(widget.categoryId)}');
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
          print("Didn't work");
        }
      }
    }
  }

  void onSearch(List<Product> results) {
    setState(() {
      searchResults = results;
    });
  }

  void _filterSearchResults(String searchText) {
    List<Product> searchResult = [];
    if (searchText.isNotEmpty) {
      searchResult = productss
          .where((product) =>
              product.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    onSearch(searchResult);
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    return Scaffold(
        appBar: myAppBar(context),
        body: ListView(children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.06,
                MediaQuery.of(context).size.height * 0.02,
                MediaQuery.of(context).size.width * 0.06,
                MediaQuery.of(context).size.height * 0.01),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
              child: TextField(
                controller: searchController,
                onChanged: _filterSearchResults,
                decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: InkWell(
                        onTap: () {
                          searchController.clear();
                          setState(() {});
                        },
                        child: const Icon(Icons.cancel)),
                    labelText: "search",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    )),
              ),
            ),
          ),
          Text(
            widget.categoryName,
            style: TextStyle(
                color: GlobalColors().primaryDarkColor,
                fontSize: 20,
                fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          searchResults.isEmpty || searchController.text.isEmpty
              ? SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final product2 = productss[index];
                      return InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SingleProduct(
                                    id: product['id'].toString(),
                                    name: product['name'],
                                    price: product['price'],
                                    image: product['images'][0]['src'],
                                    quantity:
                                        product['stock_quantity'].toString(),
                                    desc: product['short_description']))),
                        child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.28,
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Column(
                              children: [
                                SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                    child: Image.network(
                                      product['images'][0]['src'],
                                      fit: BoxFit.contain,
                                    )),
                                SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.01),
                                RichText(
                                  text: TextSpan(
                                      text: product['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Rs ' + product['price'].toString(),
                                  style: TextStyle(
                                      color: GlobalColors().itemPrice,
                                      fontWeight: FontWeight.bold),
                                ),
                                product['stock_quantity'] != '0' &&
                                        product['stock_quantity'] != null
                                    ? InkWell(
                                        onTap: () {
                                          cartModel.addProductToCart(product2);
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content:
                                                      Text('Added to cart')));
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.042,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.32,
                                          decoration: BoxDecoration(
                                              color:
                                                  GlobalColors().primaryColor,
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10))),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Text(
                                                  "Add to cart",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white),
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
                                            MediaQuery.of(context).size.height *
                                                0.04,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Out of Stock",
                                                style: TextStyle(fontSize: 12),
                                              ),
                                            ]),
                                      ),
                              ],
                            )),
                      );
                    },
                  ),
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final product = searchResults[index];
                      return ListTile(
                        title: Text(product.name),
                        subtitle: Text('Rs ${product.price.toString()}',
                            style: TextStyle(color: GlobalColors().itemPrice)),
                        leading: Image.network(product.image),
                      );
                    },
                  ),
                )
        ]));
  }
}
