import 'package:flutter/material.dart';
import 'package:fluxstore/models/cart_helper.dart';
import 'package:fluxstore/screens/cart_screen.dart';
import 'package:provider/provider.dart';

import '../colors/colors.dart';

AppBar myAppBar(BuildContext context) {
  final cartModel = Provider.of<CartProvider>(context);
  return AppBar(
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
    actions: [
      Stack(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                0,
                MediaQuery.of(context).size.height * 0.02,
                MediaQuery.of(context).size.height * 0.02,
                0),
            child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CartScreen())),
                child: const Icon(Icons.shopping_cart)),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.height * 0.02,
                MediaQuery.of(context).size.height * 0.02,
                0,
                0),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.017,
              width: MediaQuery.of(context).size.width * 0.038,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.red),
              child: Text(
                "${cartModel.cart.itemCount}",
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      )
    ],
  );
}
