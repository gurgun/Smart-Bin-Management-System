import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_project/pages/testDataApp/wasteBin.dart';

class AddBinPageHomePage extends StatefulWidget {
  const AddBinPageHomePage({super.key, required this.title});

  final String title;

  @override
  State<AddBinPageHomePage> createState() => _AddBinPageHomePageState();
}

class _AddBinPageHomePageState extends State<AddBinPageHomePage> {
  bool isChecked = false;
  bool medicalWaste = false;

  final TextEditingController idController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController fullnessController = TextEditingController();

  Future addWasteBin(String id, int fullness) async {
    double longitude = double.parse(longitudeController.text);
    double latitude = double.parse(latitudeController.text);
    GeoPoint location = GeoPoint(latitude, longitude);
    String roleID = isChecked ? '7' : '1'; // Set roleID based on the checkbox state
    Timestamp timestamp = Timestamp.now();
    String secret = _generateRandomSecret();


    await FirebaseFirestore.instance.collection("WasteBin")
        .add(
        {'id': id, 'fullness': fullness, 'location': location, 'roleID': roleID,
          'lastUpdate': timestamp,
          'secret': secret,
          'medicalWaste': medicalWaste,});
  }

  void dispose(){
    idController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();
    fullnessController.dispose();
    super.dispose();
  }

  String _generateRandomSecret() {
    final _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(10, (index) => _chars[random.nextInt(_chars.length)]).join();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffaddfad),
        centerTitle: true,
        title: Text(widget.title),

      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('WasteBin').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          return
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    children: <Widget>[
                      const SizedBox(width: 35),
                      ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Color(0xff295346))),
                        onPressed: () {
                          setState(() {
                            isChecked = false; // Reset the checkbox state to unchecked
                          });
                          idController.clear();
                          fullnessController.clear();
                          longitudeController.clear();
                          latitudeController.clear();
                        },
                        child: const Text("Cancel"),
                      ), const SizedBox(width: 180,),
                      const ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(
                                Color(0xff295346))),
                        onPressed: null,
                        child: Text("Done"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: const [
                      SizedBox(width: 20),
                      Text("Add New Bin: ", style: TextStyle(fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff295346)),),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: idController,
                      decoration: const InputDecoration(
                          labelText: "ID:",
                          labelStyle: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: Color(0xff295346)),
                          hintText: "enter ID",
                          hintStyle: (TextStyle(color: Colors.black54,
                              fontStyle: FontStyle.italic)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green,
                                width: 1,)
                          )
                      ),
                      // onChanged: (){},
                    ),
                  ),

                  const SizedBox(height: 9),
                  Row(
                    children: const [
                      SizedBox(width: 30),
                      Text("Location: ", style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff295346)),),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextFormField(
                      controller: longitudeController,
                      decoration: const InputDecoration(
                          labelText: "Longitude: ",
                          labelStyle: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: Color(0xff295346)),
                          hintText: "enter longitude",
                          hintStyle: (TextStyle(color: Colors.black54,
                              fontStyle: FontStyle.italic)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green,
                                width: 1,)
                          )
                      ),
                      // onChanged: (){},
                    ),
                  ),

                  const SizedBox(height: 9),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: TextFormField(
                      controller: latitudeController,
                      decoration: const InputDecoration(
                          labelText: "Latitude: ",
                          labelStyle: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: Color(0xff295346)),
                          hintText: "enter latitude",
                          hintStyle: (TextStyle(color: Colors.black54,
                              fontStyle: FontStyle.italic)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green,
                                width: 1,)
                          )
                      ),
                      // onChanged: (){},
                    ),
                  ),
                  const SizedBox(height: 9),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: TextFormField(
                      controller: fullnessController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: "Fullness Level: ",
                          labelStyle: TextStyle(fontWeight: FontWeight.w600,
                              fontSize: 16, color: Color(0xff295346)),
                          hintText: "enter fullness level",
                          hintStyle: (TextStyle(color: Colors.black54,
                              fontStyle: FontStyle.italic)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.green,
                                width: 1,)
                          )
                      ),
                      // onChanged: (){},
                    ),
                  ),

                  CheckboxListTile(
                    title: const Text(
                      "Medical Waste Bin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff295346),
                      ),
                    ),
                    value: isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        isChecked = value ?? false;
                        medicalWaste = isChecked; // Update the medicalWaste variable
                      });
                    },
                  ),

                  Padding(padding: const EdgeInsets.all(40.0),
                    child: ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Color(0xff295346))),
                      onPressed: () {
                        int fullness = int.parse(fullnessController.text);
                        addWasteBin(idController.text, fullness);
                        idController.text= " ";
                        fullnessController.text= " ";
                        longitudeController.text = " ";
                        latitudeController.text = " ";

                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('New Bin Added')));
                      },
                      child: const Text("Add Waste Bin"),
                    ),
                  ),
                ],
              ),
            );
        },
      ),
    );
  }
}


