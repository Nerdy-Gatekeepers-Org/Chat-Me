import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../helper/helper_function.dart';
import '../../widgets/widgets.dart';
import '../home_page.dart';
import './register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  bool _obscureText = true;
  bool _isLoading = false;
  AuthService auth = AuthService();

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 80,
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      const Center(
                        child: Text(
                          "Chat Me!",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        "Login now!",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          
                          decoration: textInputDecoration.copyWith(
                              labelText: "Email",
                              labelStyle: const TextStyle(
                                color: Colors.grey,
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Colors.teal,
                              )),
                          onChanged: (value) {
                            setState(() {
                              email = value;
                            });
                          },

                          // data validation
                          validator: (value) {
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(value!)
                                ? null
                                : "Enter a valid email";
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextFormField(
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          validator: (value) {
                            if (value!.length < 8) {
                              return "Password must have at least 8 characters";
                            } else {
                              return null;
                            }
                          },
                          obscureText: _obscureText,
                          decoration: textInputDecoration.copyWith(
                            labelText: "Password",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.teal,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(
                                  () {
                                    _obscureText = !_obscureText;
                                  },
                                );
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 35,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            login();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text.rich(
                        TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "Register here",
                                  style: const TextStyle(
                                    color: Colors.teal,
                                    decoration: TextDecoration.underline,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      nextScreen(context, const RegsterPage());
                                    })
                            ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await auth.login(email, password).then((value) async {
        if (value == true) {
          QuerySnapshot snapshot =
              await Database(uid: FirebaseAuth.instance.currentUser!.uid)
                  .getUser(email);

          // save to sp
          await HelperFunctions.saveUserLoggedInStatus(true);
          await HelperFunctions.saveUserEmail(email);
          await HelperFunctions.saveUserName(snapshot.docs[0]['name']);

          nextScreenReplace(context, const HomePage());
        } else {
          showSnackbar(context, Colors.red, value);
          setState(() {
            _isLoading = false;
          });
        }
      }
      );
    }
  }
}
