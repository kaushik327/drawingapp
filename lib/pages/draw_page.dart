import 'package:flutter/material.dart';
import 'package:firebasetutorial/widgets/big_button.dart';

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                BigButton(text: 'Save and Quit', onTap: () {
                  Navigator.of(context).pop();
                })
              ],
            ),
          ),
        ),
      ),
    );
  }
}