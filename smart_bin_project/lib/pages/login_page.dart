import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_project/pages/driver_home_page.dart';
import 'package:smart_bin_project/pages/user_home_page.dart';
import 'package:smart_bin_project/pages/register_page.dart';
import 'admin_home_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  String role = "guest";
  String roleID= "0";


  Future<User?> signIn(String email, String password) async {
    var user = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text,
      password: passController.text,
    );

    if (user.user != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.user!.uid)
          .get();

      setState(() {
        roleID = snapshot.data()!["roleID"];
      });
    }

    if (roleID != null) {
      return user.user;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffaddfad), //a7df92 olabilir
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 25),
              const Icon(
                //logo
                Icons.recycling,
                size: 145,
                color: Color(0xff295346),
              ),
              const SizedBox(height: 30),
              const Text(
                // title Smart Waste
                'Smart Waste',
                style: TextStyle(
                    fontSize: 40,
                    color: Color(0xff295346),
                    fontWeight: FontWeight.bold),
              ),
              const Text(
                // title System
                'System',
                style: TextStyle(
                    fontSize: 40,
                    color: Color(0xff295346),
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              Padding(
                //email
                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    hintText: 'E-mail',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                //password
                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                child: TextField(
                  obscureText: true,
                  controller: passController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    hintText: 'Password',
                    fillColor: Colors.white,
                    filled: true,
                  ),
                ),
              ),

              const SizedBox(height: 5),
              Padding(
                //forgot password
                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()));
                      },
                      child: const Text('Forgot Password ?',
                      style: TextStyle(
                        color: Color(0xff295346),
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ),
                  ],
                )
              ),

              const SizedBox(height: 5),
              Padding(
                //login button
                padding: const EdgeInsets.symmetric(horizontal: 65.0),
                child: MaterialButton(

                  onPressed: () {
                    signIn(emailController.text, passController.text).then((value) {
                      if (roleID != null) {
                        if (roleID == "7") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                              settings: RouteSettings(name: "AdminHomePage"),
                            ),
                          );
                        } else if (roleID == "1" || roleID == "2" || roleID == "3") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UserHomePage()),
                          );
                        } else if (roleID == "4" || roleID == "5" || roleID == "6") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => DriverHomePage()),
                          );
                        }
                      }
                    });
                  },

                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xff295346),
                    ),
                    child: const Center(
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffcfe6dc),
                        ),
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 20),
              ),

              Row( //signup button
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => RegisterPage()));},
                      child: const Text('Sign Up',
                        style: TextStyle(
                          color: Color(0xff295346),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
