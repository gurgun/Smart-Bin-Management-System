
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_bin_project/pages/request.dart';
import 'mapView.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestTOTP extends StatefulWidget {
  const RequestTOTP({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<RequestTOTP> createState() => _RequestTOTPState();
}

class _RequestTOTPState extends State<RequestTOTP> {
  final TextEditingController textController = TextEditingController();
  List<String> wasteDocumentIDs = [];
  Map<String, LatLng> wasteLocations = {};
  List<bool> wasteBinType = [];

  String? userRoleID;

  Future<void> getUserInfo() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      setState(() {
        userRoleID = snapshot.data()!['roleID'];
      });
    } else {
      print('snapshot does not exist');
    }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getWasteDocumentID() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('WasteBin')
        .orderBy('id', descending: false)
        .get();

    for (final document in snapshot.docs) {
      final documentId = document.reference.id;

      if (!wasteDocumentIDs.contains(documentId)) {
        final roleID = document.data()['roleID'];

        final isMedicalWaste =
        ['2', '3', '5', '6', '7'].contains(roleID);

        if ((userRoleID == '1' || userRoleID == '4') && isMedicalWaste) {
          continue; // Skip adding medical waste bins if userRoleID is 1 or 4
        }

        wasteDocumentIDs.add(documentId);
        final point = document.data()['location'] as GeoPoint;
        wasteLocations[documentId] =
            LatLng(point.latitude, point.longitude);
        wasteBinType.add(isMedicalWaste);
      }
    }
  }

  Widget getWasteInfo({
    required String documentId,
    required bool isMedicalWaste,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('WasteBin')
          .doc(documentId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final binId = data['id'];
            final fullness = data['fullness'];
            final roleID = data['roleID'];

            if ((userRoleID == '1' || userRoleID == '4') && isMedicalWaste) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bin ID: $binId'),
                  const SizedBox(width: 8),
                  Container(
                    width: 150, // Specify the desired width for the button
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestPage(
                              title: 'Request Password',
                              docID: documentId,
                              medicalWaste: isMedicalWaste,
                            ),
                          ),
                        );
                        print(documentId);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero, // Remove default padding
                        minimumSize: Size.zero, // Remove minimum size constraints
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0), // Add rounded corners
                        ),
                        backgroundColor: const Color(0xff295346),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Request OTP',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text('Bin ID: $binId Fullness: $fullness%'),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 160, // Specify the desired width for the button
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RequestPage(
                            title: 'Request Password',
                            docID: documentId,
                            medicalWaste: isMedicalWaste,
                          ),
                        ),
                      );
                      print(documentId);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero, // Remove default padding
                      minimumSize: Size.zero, // Remove minimum size constraints
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0), // Add rounded corners
                      ),
                      backgroundColor: const Color(0xff295346),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Request One Time Password',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Text('Invalid data');
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }




  @override
  void dispose() {
    textController.dispose();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            const SizedBox(height: 3),
            Flexible(
              child: FutureBuilder(
                future: getWasteDocumentID(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: wasteDocumentIDs.length,
                      itemBuilder: (context, index) {
                        final documentId = wasteDocumentIDs[index];
                        final isMedicalWaste = wasteBinType[index];

                        return Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: ListTile(
                            title: getWasteInfo(
                              documentId: documentId,
                              isMedicalWaste: isMedicalWaste,
                            ),
                            tileColor: const Color(0xffE8F5E9),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black26),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




