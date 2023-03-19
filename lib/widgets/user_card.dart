import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class UserCard extends StatefulWidget {
  const UserCard({super.key, required this.doc});
  final QueryDocumentSnapshot<Map<String, dynamic>> doc;

  @override
  State<UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {

  String imageUrl = "";
  Future getImageUrl() async {
    try {
      if (widget.doc.data().containsKey('image')) {
        imageUrl = await FirebaseStorage.instance.ref('images/${widget.doc.get('image')}.png').getDownloadURL();
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImageUrl(),
      builder: (context, snapshot) {
        if (imageUrl == "") return Container(); // user card doesn't appear if user doesn't have an image
        return Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                widget.doc.get('name'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: getImageUrl(),
                builder:(context, snapshot) => Image.network(imageUrl), 
              ),
            ],
          ) 
        );
      },
    );
  }
}