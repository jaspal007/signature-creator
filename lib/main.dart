import 'package:flutter/material.dart';
import 'package:sig_app/face_outline.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Signature Creator"),
          centerTitle: true,
        ),
        body: Center(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.purpleAccent,
                    child: CustomPaint(
                      painter: FaceOutlinePainter(context: context),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Clear"),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text("Download"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
