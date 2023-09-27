import 'dart:collection';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'mapView.dart';

class FullnessLevelHomePage extends StatefulWidget {
  const FullnessLevelHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _FullnessLevelHomePageState createState() => _FullnessLevelHomePageState();
}

class _FullnessLevelHomePageState extends State<FullnessLevelHomePage> {
  final TextEditingController textController = TextEditingController();
  String searchQuery = '';
  List<String> wasteDocumentIDs = [];
  Map<String, LatLng> wasteLocations = {};

  Future<void> getAllWasteDocumentIDs() async {
    await FirebaseFirestore.instance
        .collection('WasteBin')
        .orderBy('fullness', descending: true)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        wasteDocumentIDs.add(document.reference.id);
        GeoPoint point = document.data()['location'];
        wasteLocations[document.reference.id] =
            LatLng(point.latitude, point.longitude);
      });
    });
  }

  Future<List<String>> getFilteredWasteDocumentIDs(String query) async {
    List<String> filteredWasteDocumentIDs = [];
    await FirebaseFirestore.instance
        .collection('WasteBin')
        .orderBy('fullness', descending: true) // Sort by fullness level
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((document) {
        String id = document.data()['id'].toString().toLowerCase();
        if (id.contains(query.toLowerCase()) &&
            document != null &&
            document.reference != null) {
          filteredWasteDocumentIDs.add(document.reference.id);
          GeoPoint point = document.data()['location'];
          wasteLocations[document.reference.id] =
              LatLng(point.latitude, point.longitude);
        }
      });
    });
    return filteredWasteDocumentIDs;
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value) {
                  if (value != searchQuery) {
                    setState(() {
                      searchQuery = value;
                    });
                    getFilteredWasteDocumentIDs(value).then((result) {
                      setState(() {
                        wasteDocumentIDs = result;
                      });
                    });
                  }
                },
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Search the waste bin..",
                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  prefixIcon: Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff295346)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Expanded(
              child: FutureBuilder<List<String>>(
                future: getFilteredWasteDocumentIDs(searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(3.0),
                            child: ListTile(
                              title: getFullnessLevel(
                                documentId: snapshot.data![index],
                              ),
                              tileColor: const Color(0xffE8F5E9),
                              shape: const RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black26),
                              ),
                              trailing: MaterialButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MapViewHomePage2(
                                        initPos:
                                        wasteLocations[snapshot.data![index]],
                                      ),
                                    ),
                                  );
                                },
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.black54,
                                  size: 25,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('No results found.'));
                    }
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class getFullnessLevel extends StatelessWidget {
  final String documentId;
  const getFullnessLevel({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference FullnessLevel =
        FirebaseFirestore.instance.collection('WasteBin');

    return FutureBuilder<DocumentSnapshot>(
      future: FullnessLevel.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
            if(data['fullness'] >= 70){
              return Row(
                children: [
                  ColoredBox(color: const Color(0xffdc143c),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                          child: Text("Bin ID: ${data['id']}" +
                              "," + " " + "Fullness Level: % ${data['fullness']}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                        ),
                        ),

                ],
              );
            }else if (data['fullness'] >= 45 && 70 > data['fullness'] ){
            return Row(
            children: [
              Container(color: const Color(0xffFFF176),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                      child: Text("Bin ID: ${data['id']}" + "," + " " + "Fullness Level: % ${data['fullness']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                  )),

            ],
            );
            }else {
              return Row(
              children: [
                ColoredBox(color: const Color(0xff81C784),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        child: Text("Bin ID: ${data['id']}" + "," + " " + "Fullness Level: % ${data['fullness']}",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
                      ),
                      ),
            ],
            );
            }
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
