
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_bin_project/pages/forgot_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.title});
  final String title;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String? name = '';
  String? email = '';
  int totalRecycling = 0;
  int rebateAmount = 0;

  Future<void> getUserInfo() async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .get();

    if (userSnapshot.exists) {
      final userID = userSnapshot.data()?['userID'];

      setState(() {
        name = userSnapshot.data()?['userName'];
        email = userSnapshot.data()?['email'];
      });

      final wasteTrackingSnapshot = await FirebaseFirestore.instance
          .collection('WasteTracking')
          .where('userID', isEqualTo: userID)
          .get();

      print("Current User ID: $userID");

      final wasteTrackingDocs = wasteTrackingSnapshot.docs;
      print("Waste tracking numbers: ${wasteTrackingDocs.length}");

      setState(() {
        totalRecycling = wasteTrackingDocs.length;
        rebateAmount = (totalRecycling ~/ 5) * 5; //for every 5 waste tracking documents, the rebate amount increases by 5
      });
  }
  }

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }


  void showWasteTypesDialog() async {
    final currentUserID = FirebaseAuth.instance.currentUser!.uid;

    final userSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserID)
        .get();

    if (userSnapshot.exists) {
      final userID = userSnapshot.data()?['userID'];

      final wasteTrackingSnapshot = await FirebaseFirestore.instance
          .collection('WasteTracking')
          .where('userID', isEqualTo: userID)
          .get();

      if (wasteTrackingSnapshot.docs.isNotEmpty) {
        final wasteTrackingDocs = wasteTrackingSnapshot.docs;

        final wasteTypeCounts = {
          'Metal': 0,
          'Plastic': 0,
          'Glass': 0,
          'Paper': 0,
        };

        for (final doc in wasteTrackingDocs) {
          final typeID = doc.data()?['typeID'].toString();

          switch (typeID) {
            case '1':
              wasteTypeCounts['Metal'] = wasteTypeCounts['Metal']! + 1;
              break;
            case '2':
              wasteTypeCounts['Plastic'] = wasteTypeCounts['Plastic']! + 1;
              break;
            case '3':
              wasteTypeCounts['Glass'] = wasteTypeCounts['Glass']! + 1;
              break;
            case '4':
              wasteTypeCounts['Paper'] = wasteTypeCounts['Paper']! + 1;
              break;
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Waste Types'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: wasteTypeCounts.length,
                  itemBuilder: (BuildContext context, int index) {
                    final wasteType = wasteTypeCounts.keys.elementAt(index);
                    final count = wasteTypeCounts.values.elementAt(index);
                    return Container(
                      child: ListTile(
                        title: Text(
                          '$wasteType: $count',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        tileColor: const Color(0xffE8F5E9),
                        shape: (const RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black26))),
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xffaddfad),
      appBar: AppBar(
        backgroundColor: const Color(0xff295346),
        centerTitle: true,
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
               SizedBox(
                width: 150,
                height: 150,
                child: /*Icon(
                  CupertinoIcons.profile_circled,
                  size: 150,
                  color: Color(0xff295346),
                ),*/
                ClipOval(
                  child: Image.network(
                    'https://static01.nyt.com/images/2010/06/04/movies/04marmaduke-2/MARMA-1-popup.jpg?quality=75&auto=webp&disable=upscale',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'User Name: $name',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xff295346),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Email: $email',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xff295346),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: showWasteTypesDialog,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.recycling, color: Color(0xff295346)),
                      const SizedBox(width: 10),
                      Text(
                        'Total number of recycling: $totalRecycling',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xff295346),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    const Icon(CupertinoIcons.money_dollar_circle,
                        color: Color(0xff295346)),
                    const SizedBox(width: 10),
                    Text(
                      'Rebate amount: $rebateAmount',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xff295346),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
// Elevated button for changing password
              SizedBox(
                width: 200,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff295346),
                  ),
                  child: const Text('Change Password'),
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
