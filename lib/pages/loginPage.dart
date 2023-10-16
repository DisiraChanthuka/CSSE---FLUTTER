import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_todo_app/pages/dashboard.dart';
import 'package:flutter_todo_app/pages/registration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import '../components/applogo.dart';
import 'package:http/http.dart' as http;
import '../config/config.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isNotValidate = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

  void loginUser() async {
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      var reqBody = {
        "email": emailController.text,
        "password": passwordController.text
      };

      var response = await http.post(Uri.parse(login),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(reqBody));

      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status']) {
        var myToken = jsonResponse['token'];
        prefs.setString('token', myToken);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => Dashboard(token: myToken)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed Check Credentials'),
          ),
        );
        print('Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 240, 221, 221),
                  Color.fromARGB(255, 66, 65, 65)
                ],
                begin: FractionalOffset.topLeft,
                end: FractionalOffset.bottomCenter,
                stops: [0.0, 0.8],
                tileMode: TileMode.mirror),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 80,
                  ),
                  //CommonLogo(),
                  HeightBox(10),
                  "Site Manager Sign In".text.size(22).white.make(),
                  SizedBox(height: 40),

                  //email field
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.email_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Email",
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),

                  //password field
                  TextField(
                    obscureText: true,
                    controller: passwordController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        suffixIcon: Icon(Icons.lock_clock_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: "Password",
                        errorText: _isNotValidate ? "Enter Proper Info" : null,
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)))),
                  ).p4().px24(),

                  SizedBox(height: 40),

                  //login button
                  GestureDetector(
                    onTap: () {
                      loginUser();
                    },
                    // child: HStack([
                    //   VxBox(child: "LogIn".text.white.makeCentered().p16())
                    //       .blue600
                    //       .roundedLg
                    //       .make(),
                    // ]),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => Registration()));
          },
          child: Container(
              height: 25,
              color: Colors.lightBlue,
              child: Center(
                  child: "New site manager? Sign Up Here"
                      .text
                      .white
                      .makeCentered())),
        ),
      ),
    );
  }
}
