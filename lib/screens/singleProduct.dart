import 'package:flutter/material.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/widgets/myAppBar.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';

class SingleProduct extends StatefulWidget {
  final String id;
  final String name;
  final String price;
  final String image;
  final String? quantity;
  final String desc;
  const SingleProduct(
      {super.key,
      required this.id,
      required this.name,
      required this.price,
      required this.image,
      required this.quantity,
      required this.desc});

  @override
  State<SingleProduct> createState() => _SingleProductState();
}

class _SingleProductState extends State<SingleProduct> {
  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: myAppBar(context),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Image.network(
              widget.image,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            'Rs ${widget.price}',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: GlobalColors().itemPrice),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              MediaQuery.of(context).size.width * 0.1,
              MediaQuery.of(context).size.height * 0.015,
              MediaQuery.of(context).size.width * 0.1,
              MediaQuery.of(context).size.height * 0.02,
            ),
            child: Text(
              widget.desc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          widget.quantity != '0' &&
                  widget.quantity != 'null' &&
                  widget.quantity != ''
              ? Center(
                  child: InkWell(
                    onTap: () {
                      Product product = Product(
                          id: int.parse(widget.id),
                          name: widget.name,
                          price: double.parse(widget.price),
                          image: widget.image);
                      cartModel.addProductToCart(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to cart')));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.045,
                      width: MediaQuery.of(context).size.width * 0.35,
                      decoration: BoxDecoration(
                          color: GlobalColors().primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                  ),
                )
              : Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.045,
                    width: MediaQuery.of(context).size.width * 0.35,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text(
                            "Out of Stock",
                            style: TextStyle(fontSize: 12),
                          ),
                        ]),
                  ),
                ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          Text(
            "${widget.quantity} left in stock",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: GlobalColors().itemPrice,
                fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
