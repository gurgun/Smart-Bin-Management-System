import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  final emailController = TextEditingController();

  void dispose(){
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.
      sendPasswordResetEmail(email: emailController.text.trim());
      showDialog(
          context: context,
          builder: (context){
            return const AlertDialog(
              content: Text("Password Reset Link sent! Check your email!"),
            );
          }
      );
    }on FirebaseAuthException catch(e){
      print(e);
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: Text(e.message.toString()),
            );
          }
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffaddfad),
      appBar: AppBar(
        backgroundColor: const Color(0xff295346),
        elevation: 0,
        centerTitle: true,
        title: Text('Change Password'),


      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.0),
            child: Text("Enter your email "
                "and we will send you a password reset link",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xff295346),
                  fontWeight: FontWeight.bold),),
          ),
          const SizedBox(height: 15),
          Padding(
            //email
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
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
          const SizedBox(height: 10),
          MaterialButton(
            onPressed: (){passwordReset();},
            color: const Color(0xff295346),
            child: const Text("Reset Password",
              style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}
