import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'dart:ui' as ui;
import 'dart:typed_data';

class MapViewDriverHomePage extends StatefulWidget {
  const MapViewDriverHomePage({Key? key, this.initPos}) : super(key: key);
  final LatLng? initPos;

  @override
  _MapViewDriverHomePageState createState() => _MapViewDriverHomePageState();
}

class _MapViewDriverHomePageState extends State<MapViewDriverHomePage> {
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
        required this.markerData,
        required this.markers,
        this.initPos});

  final String title;
  final String id;
  final List markerData;
  final Set<Marker> markers;
  final LatLng? initPos;

  @override
  State<MapViewHomePage> createState() => _MapViewHomePageState();
}

class _MapViewHomePageState extends State<MapViewHomePage> {
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

  Marker generateMarker(String id, LatLng pos, int fullness) {
// make sure to initialize before map loading

    Marker markerTemp = Marker(
      markerId: MarkerId(id),
      position: pos,
    );

    double hueVal = 0;
    if (fullness <= 45) {
      hueVal = BitmapDescriptor.hueGreen;
    } else if (fullness <= 70) {
      hueVal = BitmapDescriptor.hueYellow;
    } else {
      hueVal = BitmapDescriptor.hueRed;
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
  //write a function to draw polyline between all the markers in the order of given array of marker numbers
  void drawPolyline(List<int> markerNumbers) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    for (int i = 0; i < markerNumbers.length - 1; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "insert your key here",
        PointLatLng(widget.markerData[markerNumbers[i]][1],
            widget.markerData[markerNumbers[i]][2]),
        PointLatLng(widget.markerData[markerNumbers[i + 1]][1],
            widget.markerData[markerNumbers[i + 1]][2]),
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }
    }
    addPolyLine(polylineCoordinates);
  }
  //write a function to draw a polyline between all the markers starting from the current location
  void drawPolylineBetweenAllBins() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    for (int i = 0; i < widget.markerData.length; i++) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "insert your key here",
        PointLatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        PointLatLng(widget.markerData[i][1], widget.markerData[i][2]),
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      } else {
        print(result.errorMessage);
      }
    }
    addPolyLine(polylineCoordinates);
  }
  double calculateDistance(LatLng point1, LatLng point2){

    double lat1 = point1.latitude;
    double lon1 = point1.longitude;
    double lat2 = point2.latitude;
    double lon2 = point2.longitude;

    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
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



  List<Marker> markerIdsToList(List<int> markerList, HashMap<String, Marker> markerMap){
    List<Marker> res = [];
    for(int i = 0; i < markerList.length; i++){
      String id = markerList[i].toString();

      res.add(markerMap[id]!);

    }
    print(res.length);
    return res;
  }

  void handlePolyLinesSalesman(List<Marker> markerList) async{
    List<LatLng> polylineCoordinates = [];
    LatLng startLocation = LatLng(currentLocation!.latitude!, currentLocation!.longitude!);

    for(int i = 0; i < markerList.length; i++){
      print("startLocation: " + startLocation.toString());
      LatLng endLocation = markerList[i].position;
      //double distance = calculateDistance(startLocation, endLocation);
      //print(markerList[i].markerId.toString() + " distance: " + distance.toString());
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

      startLocation = endLocation;
    }

  }

  Future<List<int>> fetchDataFromServer() async {
    try {
      var url = Uri.parse('http://3.66.61.122/tsp/route?fullness=60');
      //var url = Uri.parse('http://3.66.61.122/tsp/route');
      var response = await http.get(url);

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print('Response body: $jsonResponse');
        print(jsonResponse);

        print("test "+  jsonResponse[0].toString());
        List<int> binIdList = [];
        for(int i = 0; i < jsonResponse.length; i++){
          binIdList.add(jsonResponse[i]);
        }
        //List<int> binIdList = List<int>.from(jsonResponse['binList']);
        print(binIdList);
        print('binlist'+binIdList.toString());
        return binIdList;

      } else {
        print('Request failed with status: ${response.statusCode}.');
        return [];
      }
    } catch (e) {
      print('Error occurred while fetching data: $e');
      return [];
    }

  }

  void handlePolyLinesForAll(LatLng startLocation, LatLng endLocation) async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      "insert your key here",
      PointLatLng(startLocation.latitude, startLocation.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
    );
    PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
      "insert your key here",
      PointLatLng(endLocation.latitude, endLocation.longitude),
      PointLatLng(38.3914, 27.042953),
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result.errorMessage);
    }
    addPolyLine(polylineCoordinates);

    if (result2.points.isNotEmpty) {
      result2.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    } else {
      print(result2.errorMessage);
    }
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates, {Color color = Colors.deepPurpleAccent}) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: color,
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
          widget.markerData[i][1], widget.markerData[i][2]);
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
    fetchDataFromServer();
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
    HashMap<String, Marker> markerMap = HashMap();
    for (int i = 0; i < widget.markerData.length; i++) {
      Marker currMarker = generateMarker(widget.markerData[i][0],
          widget.markerData[i][1], widget.markerData[i][2]);
      print(currMarker.markerId);
      markerMap[currMarker.markerId.value] = currMarker;
      finalMarkers.add(currMarker);
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xffaddfad),
        title: Text(widget.title),
        actions: <Widget> [
          IconButton(onPressed: () async {
            //List<Marker> markerList = markerIdsToList([10, 11, 3, 6, 4, 2, 7, 12, 5, 1, 8, 9], markerMap);
            //handlePolyLinesSalesman(markerList);

            final binIdList = await fetchDataFromServer();
            List<Marker> markerList = markerIdsToList(binIdList, markerMap);
            //print the binIdList
            print("marker listee" +binIdList.toString());
            //final markerList = markerIdsToList(binIdList, markerMap);
            handlePolyLinesSalesman(markerList);
          },
              icon: const Icon(Icons.route)),// add new waste bin
        ],
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
                      print("--------------------"+currentBinName);
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

  Marker generateMarker(String id, LatLng pos, int fullness) {
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

            markerData.add([
              data["id"],
              LatLng(g.latitude, g.longitude),
              data["fullness"]
            ]);

            markers.add(generateMarker(
                data["id"], LatLng(g.latitude, g.longitude), data["fullness"]));
          }).toList();
          return MapViewHomePage(
            title: "MapView",
            id: markerData.toString(),
            markerData: markerData,
            markers: markers,
            initPos: widget.initPos,
          );
        }
      },
    );
  }
}
