import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/models/login_check.dart';
import 'package:fluxstore/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  List<dynamic> orders = [];
  @override
  void initState() {
    fetchOrders();
    super.initState();
  }

  Future<void> fetchOrders() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    final storage = FlutterSecureStorage();
    final id = await storage.read(key: 'id');
    final String url = "${baseUrl}orders?customer=$id";
    final credentials = "$consumerKey:$customerSecret";
    final utf = utf8.encode(credentials);
    final base64Str = base64.encode(utf);
    final headers = {
      "Authorization": "Basic $base64Str",
      "Content-Type": "application/json"
    };
    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      setState(() {
        final data = jsonDecode(response.body) as List;
        orders.addAll(data);
      });
    } else {
      throw Exception('Failed to fetch orders');
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<LoginCheck>(context);
    return log.isLoggedIn == false
        ? Scaffold(
            body: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text("Login to View Orders"),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: GlobalColors().primaryDarkColor),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen())),
                    child: const Text("Login"),
                  )
                ],
              ),
            ),
          )
        : Scaffold(
            body: orders.isNotEmpty
                ? Column(children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Text(
                      "Order History",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: GlobalColors().primaryDarkColor,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.028,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return ListTile(
                              title: Text("Order Id : ${order['id']}"),
                              //contentPadding: const EdgeInsets.all(10),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Order Date : ${order['date_created']}",
                                    style: TextStyle(
                                        color: GlobalColors().primaryDarkColor),
                                  ),
                                  Text(
                                    "Billing Address : ${order['billing']['address_1']}",
                                    style: TextStyle(
                                        color: GlobalColors().primaryDarkColor),
                                  ),
                                  Text(
                                    "Order Status : ${order['status']}",
                                    style: TextStyle(
                                        color: GlobalColors().primaryDarkColor),
                                  )
                                ],
                              ),
                              trailing: Text(
                                "Total : ${order['total']}",
                                style: TextStyle(
                                    color: GlobalColors().itemPrice,
                                    fontWeight: FontWeight.bold),
                              ));
                        },
                      ),
                    )
                  ])
                : SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [Text("No Orders to Display")]),
                  ),
          );
  }
}
