import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:http/http.dart' as http;

import 'navigate.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: GlobalColors().primaryColor,
      ),
      body: SafeArea(
          child: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Text(
              "Contact Us",
              style: TextStyle(
                  color: GlobalColors().primaryDarkColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Form(
                key: _formkey,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.025,
                      horizontal: MediaQuery.of(context).size.width * 0.1),
                  child: Column(
                    children: [
                      TextFormField(
                        keyboardType: TextInputType.name,
                        controller: nameController,
                        decoration: InputDecoration(
                            hintText: "Name",
                            labelText: "name ",
                            prefixIcon: Icon(
                              Icons.person,
                              color: GlobalColors().primaryDarkColor,
                            ),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Name field can not be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        controller: emailController,
                        decoration: InputDecoration(
                            hintText: "Email",
                            labelText: "email ",
                            prefixIcon: Icon(
                              Icons.email,
                              color: GlobalColors().primaryDarkColor,
                            ),
                            border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Email field can not be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.multiline,
                        controller: messageController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                            //hintText: "Message",
                            labelText: "message ",
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Message field can not be empty";
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.008,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            if (_formkey.currentState!.validate()) {
                              _formkey.currentState!.save();
                              sendEmail(nameController.text,
                                  emailController.text, messageController.text);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: GlobalColors().primaryColor),
                          child: const Text("Submit"))
                    ],
                  ),
                ))
          ]),
        ),
      )),
    );
  }

  Future sendEmail(String name, String email, String message) async {
    String? contactUrl = dotenv.env['CONTACT_URL'];
    final url = Uri.parse('$contactUrl');
    const serviceId = 'service_bnirqzv';
    const templateId = 'template_g0rr10x';
    const userId = 'MdEyXnEOj0rpF-_nT';
    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'from_name': name,
            'from_email': email,
            'message': message
          },
          'accessToken': 'PJ4PM0K76uz6Gg60irKK5'
        }));
    if (response.statusCode == 200) {
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("Your Message was sent successfully "),
                title: Text("MESSAGE SENT"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Navigate(index: 0))),
                      child: Text("OK"))
                ],
              ));
    } else {
      print(response.body);
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text("An error occurred while sending the message "),
                title: Text("MESSAGE SENDING FAILURE"),
                actions: [
                  ElevatedButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Navigate(
                                    index: 0,
                                  ))),
                      child: Text("OK"))
                ],
              ));
    }
  }
}
