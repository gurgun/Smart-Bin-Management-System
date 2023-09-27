
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditUserHomePage extends StatefulWidget {
  const EditUserHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<EditUserHomePage> createState() => _EditUserHomePageState();
}

class _EditUserHomePageState extends State<EditUserHomePage> {
  final TextEditingController textController = TextEditingController();
  String searchQuery = "";
  List<String> userDocumentIDs = [];
  List<String> roleOptions = ['Admin', 'Normal User', 'Normal Driver', 'Med-Tox User',
    'Medical User', 'Med-Tox Driver', 'Medical Driver'];
  Map<String, String> selectedRoles = {};

  String _getRoleId(String role) {
    switch (role) {
      case 'Admin':
        return '7';
      case 'Normal User':
        return '1';
      case 'Normal Driver':
        return '4';
      case 'Medical User':
        return '2';
      case 'Med-Tox Driver':
        return '6';
      case 'Medical Driver':
        return '5';
      case 'Med-Tox User':
        return '3';
      default:
        return '';
    }
  }

  String _getRoleName(String roleId) {
    switch (roleId) {
      case '7':
        return 'Admin';
      case '1':
        return 'Normal User';
      case '4':
        return 'Normal Driver';
      case '2':
        return 'Medical User';
      case '6':
        return 'Med-Tox Driver';
      case '5':
        return 'Medical Driver';
      case '3':
        return 'Med-Tox User';
      default:
        return '';
    }
  }

  Future<void> getUserDocumentID() async {
    await FirebaseFirestore.instance
        .collection('Users')
        .orderBy('userID', descending: false)
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
      userDocumentIDs.add(document.reference.id);
    }));
  }

  Future<List<String>> getFilteredUserDocumentID(String query) async {
    List<String> filteredUserDocumentIDs = [];
    await FirebaseFirestore.instance
        .collection('Users')
        .orderBy('userID', descending: false)
        .get()
        .then((snapshot) => snapshot.docs.forEach((document) {
      String id = document.data()['userID'].toString().toLowerCase();
      if (id.contains(query.toLowerCase()) &&
          document != null &&
          document.reference != null) {
        filteredUserDocumentIDs.add(document.reference.id);
      }
    }));
    return filteredUserDocumentIDs;
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
                    getFilteredUserDocumentID(value).then((result) {
                      setState(() {
                        userDocumentIDs = result;
                      });
                    });
                  }
                },
                controller: textController,
                decoration: InputDecoration(
                  hintText: "Search the user ID..",
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
                  future: getFilteredUserDocumentID(searchQuery),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final documentId = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: ListTile(
                                title: getUserInfo(documentId: documentId),
                                tileColor: const Color(0xffE8F5E9),
                                shape: const RoundedRectangleBorder(
                                    side: BorderSide(color: Colors.black26)),
                                trailing: FutureBuilder<DocumentSnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(documentId)
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot> snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      Map<String, dynamic> data =
                                      snapshot.data!.data() as Map<String, dynamic>;
                                      String currentRoleId = data['roleID'].toString();
                                      String defaultRole = _getRoleName(currentRoleId);
                                      selectedRoles[documentId] = defaultRole;
                                      return DropdownButton<String>(
                                        value: defaultRole,
                                        items: roleOptions.map((String role) {
                                          return DropdownMenuItem<String>(
                                            value: role,
                                            child: Text(role),
                                          );
                                        }).toList(),
                                        onChanged: (String? selectedRole) {
                                          setState(() {
                                            selectedRoles[documentId] = selectedRole!;
                                            final roleId = _getRoleId(selectedRole);
                                            updateRoleId(documentId, roleId);
                                          });
                                        },
                                      );
                                    }
                                    return const CircularProgressIndicator();
                                  },
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
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

class getUserInfo extends StatelessWidget {
  final String documentId;
  const getUserInfo({Key? key, required this.documentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
          return Text("ID: ${data['userID']}" + "," + " " + "Name: ${data['userName']}");
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

void updateRoleId(String documentId, String roleId) {
  CollectionReference users = FirebaseFirestore.instance.collection('Users');
  users.doc(documentId).update({'roleID': roleId});
}
