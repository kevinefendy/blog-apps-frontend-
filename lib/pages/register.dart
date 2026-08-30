import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Register(),
    );
  }
}

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final username = TextEditingController();
  final email = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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

                  // EMAIL
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Masukan Email",
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
                  // EMAIL
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "Email",
                        hintText: "Masukan Email",
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
                        Navigator.pushNamed(context,
                        "/login");
                      },
                      child: const Text(
                        "Submit",  
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  
                  
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}