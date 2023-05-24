import 'package:flutter/material.dart';
import 'package:fluxstore/colors/colors.dart';
import 'package:fluxstore/screens/additional_info.dart';
import 'package:fluxstore/screens/login_screen.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formkey = GlobalKey<FormState>();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  final emailController = TextEditingController();
  final numberController = TextEditingController();
  final passController = TextEditingController();
  final cpassController = TextEditingController();
  bool passView = true;
  bool changeButton = false;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.395,
                          height: MediaQuery.of(context).size.height * 0.078,
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            controller: fnameController,
                            decoration: const InputDecoration(
                                hintText: "First Name",
                                labelText: "first name ",
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
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
                            controller: lnameController,
                            decoration: const InputDecoration(
                                hintText: "Last Name",
                                labelText: "last name ",
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)))),
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
                          return "Username Field can not be empty";
                        }
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      controller: numberController,
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
                      height: MediaQuery.of(context).size.height * 0.008,
                    ),
                    TextFormField(
                      obscureText: passView,
                      controller: cpassController,
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
                          hintText: "Confirm Password",
                          labelText: "Confirm Password",
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)))),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password field can not be empty";
                        } else if (value != passController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    InkWell(
                      onTap: () {
                        if (_formkey.currentState!.validate()) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: ((context) => AdditionalInfo(
                                      fname: fnameController.text,
                                      lname: lnameController.text,
                                      email: emailController.text,
                                      number: numberController.text,
                                      pass: passController.text))));
                        }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.07,
                        decoration: BoxDecoration(
                            color: GlobalColors().primaryColor,
                            borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Continue      ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                            Icon(
                              Icons.arrow_forward_outlined,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => const LoginScreen()))),
                child: RichText(
                  text: TextSpan(
                      text: "Already have an account ? ",
                      style: const TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: " Login",
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
}
