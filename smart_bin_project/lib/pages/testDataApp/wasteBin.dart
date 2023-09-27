import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WasteBin {
  int fullnessLevel;
  GeoPoint geoPoint;
  String id;
  Timestamp timestamp;
  String secret;

  WasteBin({
    required this.fullnessLevel,
    required this.geoPoint,
    required this.id,
    required this.timestamp,
    required this.secret,
  });
}

Random random = new Random();
final double minLatitude = 38.387257;
final double maxLatitude = 38.393000;
final double minLongitude = 27.040191;
final double maxLongitude = 27.049736;

WasteBin generateRandomWasteBin() {
  int fullnessLevel = random.nextInt(101);
  double longitude = minLongitude + random.nextDouble() * (maxLongitude - minLongitude);
  double latitude = minLatitude + random.nextDouble() * (maxLatitude - minLatitude);
  int id = random.nextInt(16) + 12; // generates a random number between 12 and 27
  GeoPoint location = GeoPoint(latitude, longitude);
  Timestamp timestamp = Timestamp.now();
  String secret = _generateRandomSecret();


  return WasteBin(
    fullnessLevel: fullnessLevel,
    geoPoint: location,
    id: id.toString(),
    timestamp: timestamp,
    secret: secret,
  );
}
//38.392473, 27.041697, 38.393000, 27.049736, 38.387688, 27.040191, 38.387257, 27.048576
void writeWasteBinToFirestore(WasteBin wasteBin) {
  FirebaseFirestore.instance.collection('WasteBin').add({
    'fullness': wasteBin.fullnessLevel,
    'id': wasteBin.id,
    'location': wasteBin.geoPoint,
    'timestamp': wasteBin.timestamp,
    'secret': wasteBin.secret,
  });
}

List<WasteBin> wasteBins = [];
void generateAndWriteRandomWasteBins() {
  // Generate and write initial waste bins
  for (int i = 0; i < 5; i++) {
    WasteBin wasteBin = generateRandomWasteBin();
    writeWasteBinToFirestore(wasteBin);
  }
  /*// Update random waste bins every 10 minutes
  Timer.periodic(Duration(minutes: 10), (timer) {
    // Select random waste bins to update
    List<WasteBin> wasteBinsToUpdate = [];
    for (int i = 0; i < random.nextInt(2) + 2; i++) {
      int randomIndex = random.nextInt(15);
      WasteBin wasteBin = wasteBins[randomIndex];
      wasteBinsToUpdate.add(wasteBin);
    }
    // Update fullness levels and timestamps for selected waste bins
    wasteBinsToUpdate.forEach((wasteBin) {
      WasteBin updatedWasteBin = generateRandomFullnessUpdate(wasteBin);
      writeWasteBinToFirestore(updatedWasteBin);
    });
  });*/
}

String _generateRandomSecret() {
  final _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return List.generate(10, (index) => _chars[random.nextInt(_chars.length)]).join();
}

/*WasteBin generateRandomFullnessUpdate(WasteBin wasteBin) {
  int newFullnessLevel = wasteBin.fullnessLevel + random.nextInt(2) + 4;
  Timestamp newTimestamp = Timestamp.now();
  double longitude = minLongitude + random.nextDouble() * (maxLongitude - minLongitude);
  double latitude = minLatitude + random.nextDouble() * (maxLatitude - minLatitude);
  int id = random.nextInt(16) + 12; // generates a random number between 12 and 27
  GeoPoint location = GeoPoint(latitude, longitude);
  String secret = _generateRandomSecret();

  return WasteBin(
    fullnessLevel: newFullnessLevel,
    geoPoint: location,
    id: id.toString(),
    timestamp: newTimestamp,
    secret: secret,
  );
}*/

class WasteBinHomePage extends StatefulWidget {
  const WasteBinHomePage({super.key, required this.title});

  final String title;

  @override
  State<WasteBinHomePage> createState() => _WasteBinHomePage();
}

class _WasteBinHomePage extends State<WasteBinHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffaddfad),
        appBar: AppBar(
        backgroundColor: const Color(0xff295346),
        centerTitle: true,
        title: Text(widget.title),
    ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Generate Waste Bins'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff295346)),
                onPressed: () {
                generateAndWriteRandomWasteBins();
            },
    ),
          ],
        ),
      )
    );
  }
}


