import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:firebasetutorial/widgets/big_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';


const Size canvasSize = Size(400, 400);

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {

  List<PointWrapper?> points = [];

  Color currentColor = Colors.black;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      points.add(PointWrapper(
        point: details.localPosition,
        color: currentColor,
      ));
    });
  }
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      points.add(PointWrapper(
        point: details.localPosition,
        color: currentColor,
      ));
    });
  }
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      points.add(null);
    });
  }

  Future saveAndQuit() async {
    ui.PictureRecorder recorder = ui.PictureRecorder();
    Canvas canvas = Canvas(recorder);
    var painter = Painter(points: points);
    painter.paint(canvas, canvasSize);
    ui.Image renderedImage = await recorder
      .endRecording()
      .toImage(canvasSize.width.floor(), canvasSize.height.floor());    
    ByteData? data = await renderedImage.toByteData(format: ui.ImageByteFormat.png);    
    final bytes = data!.buffer.asUint8List();

    Directory appDocDirectory = await getApplicationDocumentsDirectory();
    Directory localImagesDirectory = await Directory('${appDocDirectory.path}/images').create();
    File localFile = File("${localImagesDirectory.path}/image.png");
    localFile = await localFile.writeAsBytes(bytes, flush: true);
   
    try {
      var users = FirebaseFirestore.instance.collection('users');
      var snapshot = await users
        .where('email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
        .get();
      if (snapshot.size != 1) {
        print("multiple people with same email, did nothing");
        return;
      }
      var doc = snapshot.docs[0];
      if (doc.data().containsKey('image')) {
        FirebaseStorage.instance.ref('images/${doc.get('image')}.png').delete();
      }
      String uniqueID = DateTime.now().millisecondsSinceEpoch.toString();
      FirebaseStorage.instance.ref('images/$uniqueID.png').putFile(localFile);
      doc.reference.update({'image': uniqueID});
    } catch (error) {
      print(error.toString());
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Image saved! It may take a few seconds to appear on your home page.")
          );
        }
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text(
          "Draw!",
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 10,
                    style: BorderStyle.solid,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  )
                ),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: CustomPaint(
                    size: canvasSize,
                    painter: Painter(
                      points: points
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              MaterialButton(
                child: const Text('Change Color'),
                onPressed: () {
                  Color pickerColor = currentColor;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Pick a color!'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: pickerColor,
                            onColorChanged: (color) {
                              pickerColor = color;
                            },
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            child: const Text('Done'),
                            onPressed: () {
                              setState(() {
                                currentColor = pickerColor;
                              });
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    }
                  );
                }
              ),
              const SizedBox(height: 25),
              BigButton(text: 'Save and Quit', onTap: () {
                saveAndQuit();
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class Painter extends CustomPainter {

  List<PointWrapper?> points;
  Painter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt;
    for (int i = 0; i < points.length - 1; i++) {
      if (pointIsGood(points[i]) && pointIsGood(points[i+1])) {
        paint.color = points[i]!.color;
        canvas.drawLine(
          points[i]!.point,
          points[i+1]!.point,
          paint
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  bool pointIsGood(PointWrapper? pointWrapper) {
    return pointWrapper != null
        && pointWrapper.point.dx >= 0
        && pointWrapper.point.dx < canvasSize.width
        && pointWrapper.point.dy >= 0
        && pointWrapper.point.dy < canvasSize.height;
  }
}

class PointWrapper {
  Offset point;
  Color color;
  PointWrapper({required this.point, required this.color});
}