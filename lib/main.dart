import 'package:flutter/material.dart';
import 'package:project_rpl5/pages/homePage.dart';
import 'package:project_rpl5/pages/login.dart';
import 'package:project_rpl5/pages/register.dart';


void main () {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        "/login": (context) => LoginPage(),
        "/register": (context) => RegisterPage(),
        "/home": (context) => HomePage(),
        

      },
      initialRoute: "/register",
      theme: ThemeData(
        fontFamily: "Dancing"
      ),
    );
  }
}