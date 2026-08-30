import 'package:flutter/material.dart';
import 'package:project_rpl5/pages/homePage.dart';
import 'package:project_rpl5/pages/register.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final username = TextEditingController();
  final password = TextEditingController();

  bool togglepass = true;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 400,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // GAMBAR
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        "assets/images/RayDalio.png",
                        width: 400,
                      ),
                    ),

                    // USERNAME
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: username,
                        decoration: InputDecoration(
                          labelText: "Username",
                          hintText: "Masukan Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // PASSWORD
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: password,
                        obscureText: togglepass,
                        keyboardType: TextInputType.text,
                        maxLength: 20,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Masukan Password",
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                togglepass = !togglepass;
                              });
                            },
                            icon: const Icon(
                              Icons.remove_red_eye,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                        onSubmitted: (value) {
                          print(username.text);
                          print(password.text);
                        },
                      ),
                    ),

                    // BUTTON
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        // SUBMIT
                        Container(
                          padding: const EdgeInsets.all(2),
                          width: 300,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.lightBlueAccent,
                              width: 2,
                            ),
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/home",
                                arguments: {
                                  "nama": "Kevin",
                                  "umur": 18
                                },
                              );
                            },
                            child: const Text(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        // REGISTER
                        Container(
                          margin: const EdgeInsets.only(top: 25),
                          child: TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                "/register",
                                arguments: {
                                  "nama": "Kevin",
                                  "umur": 18
                                },
                              );
                            },
                            child: const Text(
                              "Buat akun",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}