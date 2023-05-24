import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../colors/colors.dart';
import 'login_screen.dart';

class AdditionalInfo extends StatefulWidget {
  final String fname;
  final String lname;
  final String email;
  final String number;
  final String pass;
  const AdditionalInfo(
      {super.key,
      required this.fname,
      required this.lname,
      required this.email,
      required this.number,
      required this.pass});

  @override
  State<AdditionalInfo> createState() => _AdditionalInfoState();
}

class _AdditionalInfoState extends State<AdditionalInfo> {
  final _formkey = GlobalKey<FormState>();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final addressController = TextEditingController();
  bool changeButton = false;
  bool isLoading = false;

  moveToLogin(BuildContext context) async {
    if (_formkey.currentState!.validate()) {
      final data = {
        "first_name": widget.fname,
        "last_name": widget.lname,
        "email": widget.email,
        "password": widget.pass,
        "billing": {
          "phone": widget.number,
          "first_name": widget.fname,
          "last_name": widget.lname,
          "country": countryController.text,
          "state": stateController.text,
          "city": cityController.text,
          "address_1": addressController.text
        },
        "shipping": {
          "phone": widget.number,
          "first_name": widget.fname,
          "last_name": widget.lname,
          "country": countryController.text,
          "state": stateController.text,
          "city": cityController.text,
          "address_1": addressController.text
        },
      };
      String? baseUrl = dotenv.env['BASE_URL'];
      String? consumerKey = dotenv.env['CONSUMER_KEY'];
      String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
      final credentials = "$consumerKey:$customerSecret";
      final bytes = utf8.encode(credentials);
      final base64Str = base64.encode(bytes);
      final headers = {
        'Authorization': 'Basic $base64Str',
        'Content-Type': 'application/json'
      };
      final response = await http.post(Uri.parse("${baseUrl}customers"),
          headers: headers, body: jsonEncode(data));
      if (response.statusCode == 201) {
        setState(() {
          isLoading = false;
          changeButton = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        setState(() {
          changeButton = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.05),
              alignment: Alignment.centerLeft,
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              color: GlobalColors().primaryColor,
              child: Stack(children: [
                const Text(
                  "Sign up for an account",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.bold),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      MediaQuery.of(context).size.width * 0.01,
                      MediaQuery.of(context).size.height * 0.15,
                      0,
                      0),
                  child: const Text(
                    "Sign up for an account",
                    style: TextStyle(
                        color: Color.fromARGB(255, 196, 191, 191),
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ]),
            ),
            Form(
                key: _formkey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.025,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Column(children: [
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: countryController,
                      decoration: const InputDecoration(
                          hintText: "Country",
                          labelText: "country ",
                          prefixIcon: Icon(Icons.flag),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Country Field can not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: stateController,
                      decoration: const InputDecoration(
                          hintText: "State",
                          labelText: "state ",
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "State Field can not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.text,
                      controller: cityController,
                      decoration: const InputDecoration(
                          hintText: "City",
                          labelText: "city ",
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "City Field can not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      keyboardType: TextInputType.streetAddress,
                      controller: addressController,
                      decoration: const InputDecoration(
                          hintText: "Address",
                          labelText: "address ",
                          prefixIcon: Icon(Icons.pin),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Address Field can not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.15,
                      child: isLoading == true
                          ? Center(
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: CircularProgressIndicator(
                                  color: GlobalColors().primaryDarkColor,
                                ),
                              ),
                            )
                          : const Text(''),
                    ),
                    InkWell(
                      onTap: () {
                        isLoading = true;
                        setState(() {});
                        moveToLogin(context);
                      },
                      child: AnimatedContainer(
                        alignment: Alignment.center,
                        duration: const Duration(seconds: 2),
                        width: changeButton
                            ? MediaQuery.of(context).size.height * 0.07
                            : MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                            color: GlobalColors().primaryColor,
                            borderRadius:
                                BorderRadius.circular(changeButton ? 50 : 8)),
                        child: changeButton
                            ? const Icon(
                                Icons.done,
                                color: Colors.white,
                              )
                            : const Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                      ),
                    )
                  ]),
                ))
          ]),
        ),
      )),
    );
  }
}
