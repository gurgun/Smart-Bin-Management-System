
import 'dart:collection';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MapViewHomePage2 extends StatefulWidget {
  const MapViewHomePage2({Key? key, this.initPos}) : super(key: key);
  final LatLng? initPos;

  @override
  _MapViewHomePage2State createState() => _MapViewHomePage2State();
}

class _MapViewHomePage2State extends State<MapViewHomePage2> {
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
    return MapViewFromFirebase(
      initPos: widget.initPos,
    );
  }
}

class MapViewHomePage extends StatefulWidget {
  const MapViewHomePage(
      {super.key,
        required this.title,
        required this.id,
        required this.medicalWaste,
        required this.markerData,
        required this.markers,
        this.initPos});

  final String title;
  final String id;
  final bool medicalWaste;
  final List markerData;
  final Set<Marker> markers;
  final LatLng? initPos;

  @override
  State<MapViewHomePage> createState() => _MapViewHomePageState();
}

class _MapViewHomePageState extends State<MapViewHomePage> {
  ///////////////////////////////////////////////////
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

  GoogleMapController? mapController;
  var listener;

  bool isBinDataVisible = false;

  //BitmapDescriptor binIcon = BitmapDescriptor.defaultMarker;

  String currentBinName = "";
  LatLng currentMarkerLoc = LatLng(0, 0);
  int currentBinFullness = -1;

  Map<PolylineId, Polyline> polylines = {};

  double zoom = 20;
  Set<Marker> markers = Set();
  LocationData? currentLocation;
  CameraPosition initCameraPos = CameraPosition(
    target: LatLng(38.38837044628515, 27.044779361369322),
    zoom: 20,
  );

  @override
  void dispose() {
    if (listener != null) {
      listener.cancel();
    }
    super.dispose();
  }

  void getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    setState(() {
      currentLocation = _locationData;
      Marker currLoc = Marker(
          markerId: MarkerId("Current Location"),
          position:
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow));
      if (widget.initPos == null) {
        initCameraPos = CameraPosition(
          target:
          LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          zoom: 20,
        );
      }
    });

    setState(() {
      listener = location.onLocationChanged.listen((newLocation) {
        setState(() {
          currentLocation = newLocation;
        });
      });
    });
  }

  Marker generateMarker(String id, LatLng pos, int fullness, bool medicalWaste) {
// make sure to initialize before map loading

    Marker markerTemp = Marker(
      markerId: MarkerId(id),
      position: pos,
    );


    double hueVal = 0;
    if (fullness <= 30) {
      hueVal = BitmapDescriptor.hueGreen;
    } else if (fullness <= 70) {
      hueVal = BitmapDescriptor.hueYellow;
    } else {
      hueVal = BitmapDescriptor.hueRed;
    }
    if(medicalWaste){
      hueVal = BitmapDescriptor.hueViolet;
    }
    BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(hueVal);
    Marker markerFinal = Marker(
        markerId: MarkerId(id),
        position: pos,
        onTap: () {
          markerFunction(markerTemp, fullness);
        },
        icon: icon);

    return markerFinal;

  }



  void handlePolyLines(LatLng startLocation, LatLng endLocation) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "insert your key here",
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 8,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  void addMarkers() async {
    print(widget.markerData.length);
    print(widget.markerData.toString());
    for (int i = 0; i < widget.markerData.length; i++) {
      Marker currMarker = generateMarker(widget.markerData[i][0],
          widget.markerData[i][1], widget.markerData[i][2], widget.markerData[i][3]);
      setState(() {
        markers.add(currMarker);
      });
    }
  }

  @override
  void initState() {
    //addMarkers();
    getCurrentLocation();
    if (widget.initPos != null) {
      initCameraPos = CameraPosition(
        target: widget.initPos!,
        zoom: 20,
      );
    }
    super.initState();
    getUserInfo();
  }


  void markerFunction(Marker marker, int fullness) {
    setState(() {
      zoom = 50;
      isBinDataVisible = true;

      currentBinName = marker.markerId.value;
      currentMarkerLoc = marker.position;
      currentBinFullness = fullness;

      mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: marker.position, zoom: zoom)
        //17 is new zoom level
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    print("builded");
    Set<Marker> finalMarkers = Set();

    for (int i = 0; i < widget.markerData.length; i++) {
      bool medicalWaste = widget.markerData[i][3];
      if(hasMedicalRole == false && medicalWaste == true){
        continue;
      }
      Marker currMarker = generateMarker(widget.markerData[i][0],
          widget.markerData[i][1], widget.markerData[i][2], widget.markerData[i][3]);
      print(currMarker.markerId);
      finalMarkers.add(currMarker);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffaddfad),
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          currentLocation == null
              ? Center(
            child: CircularProgressIndicator(),
          )
              : GoogleMap(
            polylines: Set<Polyline>.of(polylines.values),
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            initialCameraPosition: initCameraPos,
            onTap: (data) {
              setState(() {
                isBinDataVisible = false;
                polylines = {};
              });
            },
            onMapCreated: (controller) {
              mapController = controller;
            },
            markers: finalMarkers,
            //circles: {Circle(circleId: CircleId("currentLocation"),  radius: 1, center: LatLng(currentLocation!.latitude!, currentLocation!.longitude! ), fillColor: Colors.blue.withAlpha(70), strokeColor: Colors.blue,)},
          ),
          Visibility(
              visible: isBinDataVisible,
              child: Align(
                  alignment: Alignment.bottomCenter,
                  child: BinDataContainer(
                    name: currentBinName,
                    fullness: currentBinFullness,
                    loc: currentMarkerLoc,
                    routeFunction: () {
                      handlePolyLines(
                          LatLng(currentLocation!.latitude!,
                              currentLocation!.longitude!),
                          currentMarkerLoc);
                      mapController?.animateCamera(
                          CameraUpdate.newCameraPosition(CameraPosition(
                              target: LatLng(currentLocation!.latitude!,
                                  currentLocation!.longitude!),
                              zoom: 18)
                            //17 is new zoom level
                          ));
                    },
                  )))
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class BinDataContainer extends StatelessWidget {
  const BinDataContainer(
      {Key? key,
        required this.name,
        required this.fullness,
        required this.loc,
        required this.routeFunction})
      : super(key: key);
  final String name;
  final int fullness;
  final LatLng loc;
  final Function routeFunction;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(),
          flex: 3,
        ),
        Expanded(
          flex: 1,
          child: Container(
            alignment: Alignment.bottomCenter,
            width: 200,
            color: Color(0xff295346),
            child: Padding(
              padding: EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "Name: " + name,
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Fullness: %" + fullness.toString(),
                            style: TextStyle(color: Colors.white))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Lat: " + loc.latitude.toString(),
                            style: TextStyle(color: Colors.white))),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text("Long: " + loc.longitude.toString(),
                            style: TextStyle(color: Colors.white))),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff205052)),
                      onPressed: () {
                        routeFunction();
                      },
                      child: Text("Get Route"))
                  //another elevated button getting totp code

                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MapViewFromFirebase extends StatefulWidget {
  const MapViewFromFirebase({Key? key, this.initPos}) : super(key: key);

  final LatLng? initPos;

  @override
  _MapViewFromFirebaseState createState() => _MapViewFromFirebaseState();
}

class _MapViewFromFirebaseState extends State<MapViewFromFirebase> {
  List firebaseData = [];
  var binDataMap = new Map();

  @override
  void initState() {
    //handleData();
    super.initState();
  }

  Marker generateMarker(String id, LatLng pos, int fullness, bool medicalWaste) {
// make sure to initialize before map loading

    Marker markerTemp = Marker(
      markerId: MarkerId(id),
      position: pos,
    );


    double hueVal = 0;
    if (fullness <= 30) {
      hueVal = BitmapDescriptor.hueGreen;
    } else if (fullness <= 60) {
      hueVal = BitmapDescriptor.hueYellow;
    } else {
      hueVal = BitmapDescriptor.hueRed;
    }
    // write a function to check if medical waste
    //this part is not working
    if (medicalWaste) {
      hueVal = BitmapDescriptor.hueOrange;
    }

    BitmapDescriptor icon = BitmapDescriptor.defaultMarkerWithHue(hueVal);
    Marker markerFinal =
    Marker(markerId: MarkerId(id), position: pos, icon: icon);

    return markerFinal;
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream =
    FirebaseFirestore.instance.collection('WasteBin').snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: _usersStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot != null && snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          var binDataMap = Map();
          var markerData = [];
          Set<Marker> markers = Set();
          if (snapshot.data == null) {
            return CircularProgressIndicator();
          }
          var d = snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
            document.data()! as Map<String, dynamic>;

            GeoPoint g = data["location"];

            binDataMap[data["id"]] = [g.latitude, g.longitude];

            bool b = data["medicalWaste"];

            markerData.add([
              data["id"],
              LatLng(g.latitude, g.longitude),
              data["fullness"],
              data["medicalWaste"],
            ]);

            markers.add(generateMarker(
                data["id"], LatLng(g.latitude, g.longitude), data["fullness"], data["medicalWaste"]));
          }).toList();
          return MapViewHomePage(
            title: "MapView",
            id: markerData.toString(),
            //
            medicalWaste: true,
            //
            markerData: markerData,
            markers: markers,
            initPos: widget.initPos,
          );
        }
      },
    );
  }
}
