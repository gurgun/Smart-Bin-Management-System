import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'addBinPage.dart';
import 'editPage.dart';
import 'mapView.dart';

class EditBinInfoHomePage extends StatefulWidget {
  const EditBinInfoHomePage({super.key, required this.title});

  final String title;

  @override
  State<EditBinInfoHomePage> createState() => _EditBinInfoHomePageState();
}

class _EditBinInfoHomePageState extends State<EditBinInfoHomePage> {

  final TextEditingController textController = TextEditingController();
  String searchQuery = "";
  List<String> wasteDocumentIDs = [];
  Map<String, LatLng> wasteLocations = HashMap();

  Future getWasteDocumentID() async { // to get document IDs
    await FirebaseFirestore.instance.collection('WasteBin').orderBy('id', descending: false).get().
    then((snapshot) => snapshot.docs.forEach((document) {
      wasteDocumentIDs.add(document.reference.id);
      GeoPoint point = document.data()["location"];
      wasteLocations[document.reference.id] = LatLng(point.latitude, point.longitude);
    })
    );
  }

  Future<List<String>> getFilteredWasteDocumentID(String query) async {
    List<String> filteredWasteDocumentIDs = [];
    await FirebaseFirestore.instance
        .collection('WasteBin')
        .orderBy('id', descending: false)
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
      String id = document.data()['id'].toString().toLowerCase();
      if (id.contains(query.toLowerCase()) && document != null && document.reference != null) {
        filteredWasteDocumentIDs.add(document.reference.id);
        GeoPoint point = document.data()["location"];
        wasteLocations[document.reference.id] =
            LatLng(point.latitude, point.longitude);
      }
    }));
    return filteredWasteDocumentIDs;
  }

  @override
  void dispose(){
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
        actions: <Widget> [
          IconButton(onPressed: (){Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddBinPageHomePage (title: "Add Bin Info")),
          );},
              icon: const Icon(Icons.add_circle_outline)),// add new waste bin
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value){
                  if (value != searchQuery) {
                    setState(() {
                      searchQuery = value;
                    });
                    getFilteredWasteDocumentID(value).then((result) {
                      setState(() {
                        wasteDocumentIDs = result;
                      });
                    });
                  }
                },
                controller:  textController,
                decoration: InputDecoration(
                  hintText: "Search the waste bin..",
                  hintStyle: TextStyle(fontStyle: FontStyle.italic),
                  prefixIcon: Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xff295346)),
                ),
                ),
              ),
            ),
            const SizedBox(height: 3),

            Flexible(
              child: FutureBuilder<List<String>>(
                  future: getFilteredWasteDocumentID(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index){
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: MaterialButton(
                                child: ListTile(
                                  title: getWasteInfo(documentId: snapshot.data![index]),
                                  tileColor: const Color(0xffE8F5E9),
                                  shape: (const RoundedRectangleBorder( side: BorderSide(color:Colors.black26))),
                                  trailing: MaterialButton(
                                    onPressed: (){
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => MapViewHomePage2(initPos: wasteLocations[snapshot.data![index]],)),);
                                    },
                                    child: const Icon(
                                        Icons.location_on,
                                        color: Colors.black54,
                                        size: 25),
                                  ),
                                ),
                                onPressed: (){
                                  Navigator.push(context,
                                    MaterialPageRoute(builder: (context) => EditPageHomePage (title: "Edit Bin Info", docID: snapshot.data![index],)),
                                  );},
                              ),
                            );
                          },);
                      } else {
                        return const Center(
                            child: Text('No results found.'));
                      }
                    }
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
              ),
            )
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class getWasteInfo extends StatelessWidget {
  final String documentId;
  const getWasteInfo({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference WasteBin = FirebaseFirestore.instance.collection('WasteBin');

    return FutureBuilder<DocumentSnapshot>(
      future: WasteBin.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text("Bin ID: ${data['id']}" + "," + " " + "Fullness Level: ${data['fullness']}");
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
