import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluxstore/screens/register_screen.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../colors/colors.dart';
import '../models/login_check.dart';
import 'navigate.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final storage = const FlutterSecureStorage();
  final _formkey = GlobalKey<FormState>();
  bool passView = true;
  bool changeButton = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final log = Provider.of<LoginCheck>(context);
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
                    "Sign in to your account",
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
                      "Sign in to your account",
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
                      vertical: MediaQuery.of(context).size.height * 0.05,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Column(children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                          hintText: "Email",
                          labelText: "email ",
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Username Field cann not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      obscureText: passView,
                      controller: passController,
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.key),
                          suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  passView = !passView;
                                });
                              },
                              child: Icon(passView == true
                                  ? Icons.visibility_off
                                  : Icons.visibility)),
                          hintText: "Enter Password",
                          labelText: "Password",
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password field can not be empty";
                        } else if (value.length < 6) {
                          return "Password length can not be less than 6 ";
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    InkWell(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          login(emailController.text, passController.text, log);
                        }
                      },
                      child: AnimatedContainer(
                        alignment: Alignment.center,
                        duration: const Duration(seconds: 1),
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
                                "Login",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                      ),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.12,
                child: isLoading == true
                    ? Center(
                        child: SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              color: GlobalColors().primaryDarkColor,
                            )))
                    : const Text(
                        ".",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Register(),
                    )),
                child: RichText(
                  text: TextSpan(
                      text: "Don't have an account ? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                            text: " Register",
                            style:
                                TextStyle(color: GlobalColors().primaryColor))
                      ]),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<String> login(String email, String password, LoginCheck log) async {
    String? base = dotenv.env['BASE'];
    String? auth = dotenv.env['AUTH_URL'];
    String? consumerKey = dotenv.env['CONSUMER_KEY'];
    String? customerSecret = dotenv.env['CUSTOMER_SECRET'];
    final client = http.Client();
    final credentials = '$consumerKey:$customerSecret';
    final bytes = utf8.encode(credentials);
    final base64Str = base64.encode(bytes);
    final headers = {
      'Authorization': 'Basic $base64Str',
      'Content-Type': 'application/x-www-form-urlencoded'
    };
    final url = Uri.parse('$base$auth');
    final response = await client.post(
      url,
      headers: headers,
      body: {
        'username': email,
        'password': password,
      },
    );
    if (response.statusCode == 200) {
      print(response.statusCode);
      final data = jsonDecode(response.body);
      print(response.body);
      await storage.write(key: 'token', value: data['data']['token']);
      await storage.write(key: 'id', value: data['data']['id'].toString());
      await storage.write(key: 'fname', value: data['data']['firstName']);
      await storage.write(key: 'lname', value: data['data']['lastName']);
      await storage.write(key: 'email', value: data['data']['email']);
      log.changeLog();
      print("LOGGED IN : ${log.isLoggedIn}");
      print(data['data']['token']);
      print("Authentication Successful");
      setState(() {
        isLoading = false;
        changeButton = true;
      });
      await Future.delayed(const Duration(seconds: 1));
      await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Navigate(
                    index: 0,
                  )));

      return data['message'];
    } else if (response.statusCode == 403) {
      setState(() {
        isLoading = false;
      });
      final data = jsonDecode(response.body);
      print(email);
      print(data['message']);
      print(jsonDecode(response.body));
      print(response.statusCode);
      print("Login Failed");
      throw Exception('Failed to log in');
    } else {
      setState(() {
        isLoading = false;
      });

      throw Exception('Failed to log in');
    }
  }
}
