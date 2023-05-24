import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxstore/models/login_check.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKeyProfile = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _numberController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _emailController = TextEditingController();
  List<dynamic> info = [];

  @override
  void initState() {
    super.initState();
    getClientById();
  }

  Future<void> getClientById() async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    final storage = FlutterSecureStorage();
    final id = await storage.read(key: 'id');
    final url =
        '${baseUrl}customers/$id?consumer_key=$consumerKey&consumer_secret=$customerSecret';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': "application/json",
      },
    );
    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          final res = jsonDecode(response.body);
          info.add(res);
          _fnameController.text = info[0]['first_name'];
          _lnameController.text = info[0]['last_name'];
          _numberController.text = info[0]['billing']['phone'];
          _emailController.text = info[0]['email'];
          _countryController.text = info[0]['billing']['country'];
          _stateController.text = info[0]['billing']['state'];
          _cityController.text = info[0]['billing']['city'];
          _addressController.text = info[0]['billing']['address_1'];
        });
      }
    } else {
      throw Exception('Failed to get client info');
    }
  }

  Future<void> updateCustomer(
      Map<String, dynamic> data, BuildContext context) async {
    String? baseUrl = dotenv.env['BASE_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    final storage = FlutterSecureStorage();
    final customerId = await storage.read(key: 'id');
    final String url =
        '${baseUrl}customers/$customerId?consumer_key=$consumerKey&consumer_secret=$customerSecret';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: const Text("User Info has been updated Successfully"),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {});
                    },
                    child: const Text("OK"),
                  )
                ],
              ));
    } else {
      throw Exception('Failed to update customer.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<LoginCheck>(context);
    return Scaffold(
      body: log.isLoggedIn == true
          ? ListView(
              children: [
                Form(
                  key: _formKeyProfile,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.1,
                        0,
                        MediaQuery.of(context).size.width * 0.1,
                        0),
                    child: Column(children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      Text(
                        "User Profile",
                        style: TextStyle(
                            color: GlobalColors().primaryDarkColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.395,
                            height: MediaQuery.of(context).size.height * 0.078,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              controller: _fnameController,
                              decoration: const InputDecoration(
                                  hintText: "First Name",
                                  labelText: "first name ",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "First Name can not be empty";
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.395,
                            height: MediaQuery.of(context).size.height * 0.078,
                            child: TextFormField(
                              keyboardType: TextInputType.name,
                              controller: _lnameController,
                              decoration: const InputDecoration(
                                  hintText: "Last Name",
                                  labelText: "last name ",
                                  prefixIcon: Icon(Icons.person),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10)))),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Last Name can not be empty";
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        decoration: const InputDecoration(
                            hintText: "Email",
                            labelText: "email ",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Username Field can not be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        controller: _numberController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            hintText: "Phone",
                            labelText: "phone ",
                            prefixIcon: Icon(Icons.numbers),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "phone Field can not be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        controller: _countryController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.flag),
                            hintText: "Country",
                            labelText: "country",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        controller: _stateController,
                        decoration: const InputDecoration(
                            hintText: "State",
                            labelText: "State",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.location_city),
                            hintText: "City",
                            labelText: "City",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.pin_drop),
                            hintText: "Address",
                            labelText: "Address",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.04,
                      ),
                      ElevatedButton(
                          onPressed: () async {
                            if (_formKeyProfile.currentState!.validate()) {
                              final data = {
                                "email": _emailController.text,
                                "first_name": _fnameController.text,
                                "last_name": _lnameController.text,
                                "billing": {
                                  "first_name": _fnameController.text,
                                  "last_name": _lnameController.text,
                                  "address_1": _addressController.text,
                                  "city": _cityController.text,
                                  "country": _countryController.text,
                                  "state": _stateController.text,
                                  "phone": _numberController.text
                                },
                                "shipping": {
                                  "first_name": _fnameController.text,
                                  "last_name": _lnameController.text,
                                  "company": "",
                                  "address_1": _addressController.text,
                                  "address_2": "",
                                  "city": _cityController.text,
                                  "country": _countryController.text,
                                  "state": _stateController.text,
                                  "phone": _numberController.text
                                },
                              };
                              updateCustomer(data, context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalColors().primaryDarkColor),
                          child: const Text("Update Info"))
                    ]),
                  ),
                )
              ],
            )
          : Center(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("No Info to Display"),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: GlobalColors().primaryDarkColor),
                        child: const Text("Login"))
                  ]),
            ),
    );
  }
}
