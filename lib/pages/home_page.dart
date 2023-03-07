import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasetutorial/read_data/get_user_name.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  // document IDs
  List<String> docIDs = [];

  // get docIDs
  Future getDocId() async {
    docIDs.clear();
    await FirebaseFirestore.instance.collection('users').orderBy('age', descending: true).get().then(
      (snapshot) => snapshot.docs.forEach((document) {
        docIDs.add(document.reference.id);
      }) 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        title: Text(
          user!.email!,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              FirebaseAuth.instance.signOut();
            },
            child: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: FutureBuilder(
                future: getDocId(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docIDs.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          tileColor: Colors.grey[300],
                          title: GetUserName(documentId: docIDs[index],),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}