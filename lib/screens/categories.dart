import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/screens/displayCategory.dart';
import 'package:http/http.dart' as http;

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<dynamic> categories = [];
  @override
  void initState() {
    fetchCategories();
    super.initState();
  }

  void fetchCategories() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    print("Fetching Categories");
    int pageNum = 1;
    bool hasMorePages = true;
    final url = '${baseUrl}products/categories';
    final credentials = "$consumerKey:$customerSecret";
    final utf = utf8.encode(credentials);
    final base64Str = base64.encode(utf);
    final headers = {"Authorization": "Basic $base64Str"};
    while (hasMorePages) {
      final response =
          await http.get(Uri.parse('$url?page=$pageNum'), headers: headers);
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final data = json.decode(response.body);
            categories.addAll(data);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: categories.isNotEmpty
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.02,
                  ),
                  Text("Categories",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: GlobalColors().primaryDarkColor),
                      textAlign: TextAlign.center),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView.builder(
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return Column(children: [
                          InkWell(
                            onTap: () {
                              final id = category['id'].toString();
                              final name = category['name'];
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DisplayByCategory(
                                            categoryId: id,
                                            categoryName: name,
                                          )));
                            },
                            child: Container(
                              alignment: Alignment.center,
                              height: MediaQuery.of(context).size.height * 0.28,
                              width: MediaQuery.of(context).size.width * 0.99,
                              decoration: BoxDecoration(
                                  color: GlobalColors().primaryColor,
                                  borderRadius: BorderRadius.circular(
                                    10,
                                  )),
                              child: Text(
                                '${category['name']}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          )
                        ]);
                      },
                    ),
                  )
                ],
              )
            : Center(
                child: CircularProgressIndicator(
                  color: GlobalColors().primaryDarkColor,
                ),
              ));
  }
}
