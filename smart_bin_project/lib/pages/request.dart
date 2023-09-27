
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key, required this.title, required this.docID, required this.medicalWaste});
  final String title;
  final String docID;
  final bool medicalWaste;
  @override
  State<RequestPage> createState() => RequestPageState();
}

class RequestPageState extends State<RequestPage> {

  String _data = '';
  int? id = 0;
  bool? medicalWaste = false;

  bool? hasMedicalRole = false;

  Future getUserInfo() async {

    await FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async
    {
      if(snapshot.exists)
      {
        //print('snapshot exist');
        setState(() {
          hasMedicalRole = snapshot.data()!['hasMedicalRole'];
        });
      }else{
        print('snapshot does not exist');
      }
    });
  }


  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffaddfad),
      appBar: AppBar(
        backgroundColor: const Color(0xff295346),
        centerTitle: true,
        title: Text('One Time Password'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getWasteName(documentId: widget.docID,),

            SizedBox(height: 20),
            Text(_data),
          ],
        ),
      ),
    );
  }
}


class getWasteName extends StatefulWidget {
  final String documentId;
  const getWasteName({super.key, required this.documentId});

  @override
  State<getWasteName> createState() => _getWasteNameState();
}

class _getWasteNameState extends State<getWasteName> {
  int? id = 0;
  bool? medicalWaste = false;

  bool? hasMedicalRole = false;

  Future getUserInfo() async {
    await FirebaseFirestore.instance.collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if(snapshot.exists) {
        setState(() {
          hasMedicalRole = snapshot.data()!['hasMedicalRole'];
        });
      } else {
        print('snapshot does not exist');
      }
    });
  }

  Future getWasteInfo() async {
    await FirebaseFirestore.instance.collection('WasteBin')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if(snapshot.exists) {
        setState(() {
          medicalWaste = snapshot.data()!['medicalWaste'];
        });
      } else {
        print('snapshot does not exist');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
    getWasteInfo();
  }

  String _totp = '';
  String _wasteBinID = '';

  Future<void> getDataFromAPI(int id) async {
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .get();

    if (userSnapshot.exists) {
      final userID = userSnapshot.data()?['userID'];

      if (hasMedicalRole == false && medicalWaste == true) {
        print('You do not have permission to access this bin');
      } else if (hasMedicalRole == true && (medicalWaste == true || medicalWaste == false)) {
        final response = await http.post(
          Uri.parse('http://3.66.61.122/totp'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'api_key': 'insert your API key here',
            'waste_bin_id': id,
            'user_id': userID,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body) as Map<String, dynamic>;
          final totp = responseData['totp'] as String;

          setState(() {
            _totp = 'TOTP: $totp';
            _wasteBinID = 'Waste Bin ID: $id';
          });
        } else {
          setState(() {
            _totp = 'Error: ${response.statusCode}';
            _wasteBinID = '';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference WasteBin = FirebaseFirestore.instance.collection('WasteBin');

    return FutureBuilder<DocumentSnapshot>(
      future: WasteBin.doc(widget.documentId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              Text('Selected Bin ID: ${data["id"]}',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff295346),
                ),
              ),
              ElevatedButton(
                onPressed: () => getDataFromAPI(int.parse(data["id"])),
                child: Text('Get Password'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff295346),
                ),
              ),
              Text(_totp,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xff295346),
                ),
              ),
              Text(_wasteBinID,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff295346),
                ),
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}






