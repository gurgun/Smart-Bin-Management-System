
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_project/pages/admin_home_page.dart';
import 'editBinInfo.dart';

class EditPageHomePage extends StatefulWidget {

  const EditPageHomePage({super.key, required this.title, required this.docID});

  final String title;
  final String docID;

  @override
  State<EditPageHomePage> createState() => _EditPageHomePageState();
}

class _EditPageHomePageState extends State<EditPageHomePage> {
  bool isChecked = false;
  bool isMedicalWaste = false;

  final TextEditingController idController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController fullnessController = TextEditingController();

  Future <void> updateData(bool isMedicalWaste) async {
    CollectionReference document = FirebaseFirestore.instance.collection('WasteBin');

   await document.doc(widget.docID).update({
        'id': idController.text,
        'location': GeoPoint (double.parse(longitudeController.text),double.parse(latitudeController.text)),
        'fullness': int.parse(fullnessController.text),
        'roleID': isMedicalWaste ? '7' : '1',
     'medicalWaste': isMedicalWaste,}). // Update the 'roleID' field based on checkbox state
        then((value) => print("Updated"));
  }

  Future<void> deleteWasteBin() async {
    CollectionReference collection = FirebaseFirestore.instance.collection('WasteBin');
    await collection.doc(widget.docID).delete()
        .then((value) => print("Deleted"))
        .catchError((error) => print("Failed to delete : $error"));
  }

  void dispose(){
    idController.dispose();
    longitudeController.dispose();
    latitudeController.dispose();
    fullnessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffaddfad),
        centerTitle: true,
        title: Text(widget.title),

      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance.collection('WasteBin').get(),
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
                    ElevatedButton(
                      style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll<Color>(
                              Color(0xff295346))),
                      onPressed: () {
                        updateData(isMedicalWaste);
                        Navigator.popUntil(context, ModalRoute.withName('AdminHomePage'));

                      },
                      child: const Text("Done"),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children:  [
                    SizedBox(width: 20),
                    Text("Selected Bin: ", style: TextStyle(fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff295346)),),
                    getWasteName(documentId: widget.docID,) ],

                ),
                const SizedBox(height: 12),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(
                        labelText: "ID:",
                        labelStyle: TextStyle(fontWeight: FontWeight.w600,
                            fontSize: 16, color: Color(0xff295346)),
                        hintText: "ID",
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
                        hintText: "Longitude",
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
                        hintText: "Latitude",
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
                    decoration: const InputDecoration(
                        labelText: "Fullness Level: ",
                        labelStyle: TextStyle(fontWeight: FontWeight.w600,
                            fontSize: 16, color: Color(0xff295346)),
                        hintText: "Fullness Level",
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
                  value: isMedicalWaste,
                  onChanged: (bool? newValue) {
                    setState(() {
                      isMedicalWaste = newValue ?? false;
                    });
                  },
                ),


                Padding(padding: const EdgeInsets.all(40.0),

                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(
                            Color(0xff295346))),
                    onPressed: () {
                      deleteWasteBin();
                      Navigator.popUntil(context, ModalRoute.withName('AdminHomePage'));

                    },
                    child: const Text("Delete Waste Bin"),
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
class getWasteName extends StatelessWidget {
  final String documentId;
  const getWasteName({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference WasteBin = FirebaseFirestore.instance.collection('WasteBin');

    return FutureBuilder<DocumentSnapshot>(
      future: WasteBin.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text(data["id"], style: TextStyle(fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Color(0xff295346)),);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}


