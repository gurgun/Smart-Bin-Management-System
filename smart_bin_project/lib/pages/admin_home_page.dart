
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_project/pages/binInfo.dart';
import 'package:smart_bin_project/pages/editBinInfo.dart';
import 'package:smart_bin_project/pages/editUser.dart';
import 'package:smart_bin_project/pages/request.dart';
import 'package:smart_bin_project/pages/requestTOTP.dart';
import 'package:smart_bin_project/pages/testDataApp/wasteBin.dart';
import 'fullnessLevel.dart';
import 'package:smart_bin_project/pages/mapView.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final mapPageKey = GlobalKey<_HomePageState>();
  @override
  Widget build(BuildContext context) {
    //print(ModalRoute.of(context)!.settings.name);
    return Scaffold(
      backgroundColor: Color(0xffaddfad),
      appBar: AppBar(
        backgroundColor: const Color(0xff295346),
        centerTitle: true,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("MENU"),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.location_solid,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){

                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapViewHomePage2()));
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Map View and Route Option")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.chart_bar_alt_fill,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FullnessLevelHomePage (title: "Fullness Level")),
                      );}, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Fullness Level List")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.trash_fill,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BinInfoHomePage (title: "Bin Info")),
                        );
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Bin Info")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.doc_on_clipboard_fill,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditBinInfoHomePage (title: "Edit Bin Info")),
                        );
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Edit Bin Info")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.search_circle,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RequestTOTP (title: "Request Password")),
                        );
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Request One Time Password")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(CupertinoIcons.person_fill,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditUserHomePage (title: "Edit User Page")),
                        );
                      }, style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff295346)),
                          child: const Text("Edit User Info")),),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout,
                        color: Color(0xff295346)),
                    SizedBox(width: 250,
                      child:
                      ElevatedButton(onPressed: (){
                        FirebaseAuth.instance.signOut();
                        Navigator.pop(context);
                      }, style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff295346),
                      ),child: const Text("Logout")),),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.recycling, size: 145,
                    color: Color(0xff295346)),
              )

            ],
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
