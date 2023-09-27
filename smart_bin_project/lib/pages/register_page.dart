import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController passControllerConfirm = TextEditingController();

  Future createUser(String name, String email, String password) async {
    // Retrieve the current value of the counter
    var counterDoc = await FirebaseFirestore.instance
        .collection("Counters")
        .doc("userIDCounter")
        .get();

    int currentCount = 0;

    if (counterDoc.exists) {
      currentCount = counterDoc.data()!['count'] as int;
    }

    // Increment the counter and use it as the userID
    int nextCount = currentCount + 1;
    String userID = (20 + nextCount).toString();

    // Create the user with the generated userID
    var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passController.text,
    );

    // Set the user data with the generated userID
    await FirebaseFirestore.instance.collection("Users").doc(user.user!.uid).set({
      'userName': name,
      'email': email,
      'roleID': '1',
      'hasMedicalRole': true,
      'userID': userID,
    });

    // Update the counter with the new value
    await FirebaseFirestore.instance
        .collection("Counters")
        .doc("userIDCounter")
        .set({'count': nextCount});

    return user.user;
  }

  @override
  void dispose(){
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    passControllerConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffaddfad), //a7df92
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Icon(
                //logo
                Icons.recycling,
                size: 145,
                color: Color(0xff295346),
              ),
              const SizedBox(height: 30),
              Padding(
                //email
                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    hintText: 'User Name',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.person,
                      color: Color(0xff295346),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                    prefixIcon: const Icon(
                      Icons.mail,
                      color: Color(0xff295346),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                    prefixIcon: const Icon(
                      Icons.key,
                      color: Color(0xff295346),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                //password confirmation
                padding: const EdgeInsets.symmetric(horizontal: 55.0),
                child: TextField(
                  obscureText: true,
                  controller: passControllerConfirm,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.green),
                    ),
                    hintText: 'Confirm Password',
                    fillColor: Colors.white,
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.key,
                      color: Color(0xff295346),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Padding(
                //Sign in button
                padding: const EdgeInsets.symmetric(horizontal: 65.0),
                child: MaterialButton(
                  onPressed: () {
                    if(passController.text == passControllerConfirm.text){
                      createUser(
                          nameController.text,
                          emailController.text,
                          passController.text,).then((value) {
                        return Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const LoginPage()));
                      });
                    }else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please Enter the Same Password!')
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xff295346),
                    ),
                    child: const Center(
                      child: Text(
                        'Sign Up',
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
              const SizedBox(height: 8),

              Row( //return login page button
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => const LoginPage()));},
                      child: const Text('Return Login Page',
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