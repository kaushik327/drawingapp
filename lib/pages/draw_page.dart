import 'package:flutter/material.dart';
import 'package:firebasetutorial/widgets/big_button.dart';

const Size canvasSize = Size(400, 400);
// TODO: change width and height of draw box

class DrawPage extends StatefulWidget {
  const DrawPage({super.key});

  @override
  State<DrawPage> createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {

  List<PointWrapper?> points = [];

  void _onPanStart(DragStartDetails details) {
    setState(() {
      points.add(PointWrapper(point: details.localPosition));
    });
  }
  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      points.add(PointWrapper(point: details.localPosition));
    });
  }
  void _onPanEnd(DragEndDetails details) {
    setState(() {
      points.add(null);
    });
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(25),
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
                BigButton(text: 'Save and Quit', onTap: () {
                  Navigator.of(context).pop();
                }),
              ],
            ),
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
      ..color = Colors.black
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.butt;
    for (int i = 0; i < points.length - 1; i++) {
      if (pointIsGood(points[i]) && pointIsGood(points[i+1])) {
        canvas.drawLine(points[i]!.point, points[i+1]!.point, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  bool pointIsGood(PointWrapper? pointWrapper) {
    if (pointWrapper == null) {
      return false;
    }
    // TODO: check if the point is within the canvas
    return true;
  }
}

class PointWrapper {
  Offset point;
  PointWrapper({required this.point});
}