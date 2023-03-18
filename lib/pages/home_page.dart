import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebasetutorial/widgets/user_card.dart';
import 'package:flutter/material.dart';
import 'package:firebasetutorial/pages/draw_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

  Future getDocs() async {
    docs.clear();
    var snapshot = await FirebaseFirestore.instance.collection('users').get();
    docs = snapshot.docs;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                FirebaseAuth.instance.signOut();
              },
              child: const Icon(Icons.logout),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder(
                future: getDocs(),
                builder: (context, snapshot) {
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      return UserCard(doc: docs[index]);
                    }
                  );
                },
              ),
            ),
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(context, 
            MaterialPageRoute(
              builder: (context) {
                return const DrawPage();
              }
            )
          ).then((_) {
            showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Text("Image saved! It may take a few seconds to appear on your home page.")
                );
              }
            );
          });
        },
        child: const Icon(Icons.draw),
      )
    );
  }
}