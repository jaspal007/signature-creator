// ignore_for_file: unused_local_variable, avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hand_signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sig_app/global_variable.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();
  runApp(MyApp(
    token: pref.getInt('token'),
  ));
}

HandSignatureControl signatureControl = HandSignatureControl(
  threshold: 3.0,
  smoothRatio: 0.65,
  velocityRange: 2.0,
);

class MyApp extends StatefulWidget {
  final token;
  const MyApp({
    super.key,
    required this.token,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Signature(),
    );
  }
}

class Signature extends StatefulWidget {
  const Signature({super.key});

  @override
  State<Signature> createState() => _SignatureState();
}

Future<File> getImage(Future<ByteData?> img) async {
  final byteData = await img;
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String imgAppDir = appDocDir.path;
  final file = await File('$imgAppDir/sign.png').create(recursive: true);
  await file.writeAsBytes(byteData!.buffer
      .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  print('file path: $file');
  return file;
}

Future<void> saveImage(Future<ByteData?> img) async {
  late File image;
  await getImage(img).then((file) => image = file);
  // print('image: $image');
  final extDir = await getExternalStorageDirectory();
  final path = '${extDir!.path}/images';
  String basename = 'sign.png';
  // print('path: $path');
  final file = await File('$path/$basename').create(recursive: true);
  // print('newImage1: $file');
  File newImage = await image.copy("$path/$basename");
  // print('newImage2: ${newImage.path}');
}

class _SignatureState extends State<Signature> {
  late SharedPreferences pref;
  Color? dropDownValue = colors[2];
  bool active = false;
  @override
  void initState() {
    super.initState();
    initSharedPref();
    signatureControl.addListener(() {
      if (signatureControl.isFilled) {
        setState(() {
          active = true;
        });
      }
    });
  }

  void initSharedPref() async {
    pref = await SharedPreferences.getInstance();
    print('initialized');
    setState(() {
      dropDownValue =
          colors[(pref.getInt('token') == null) ? 0 : pref.getInt('token')!];
    });
  }

  @override
  void dispose() {
    super.dispose();
    signatureControl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var signature = HandSignature(
      control: signatureControl,
      color: dropDownValue!,
      width: 1.0,
      maxWidth: 10.0,
      type: SignatureDrawType.shape,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text("Signature Creator"),
        centerTitle: true,
        actions: [
          DropdownButton(
            value: dropDownValue,
            icon: const Icon(Icons.brush),
            items: colors
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Center(
                      child: CircleAvatar(
                        backgroundColor: e,
                        radius: 15,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (Object? val) async {
              int id = colors.indexOf(val! as Color);
              setState(() {
                dropDownValue = val as Color?;
                HandSignature newSignature = HandSignature(
                  control: signatureControl,
                  color: dropDownValue!,
                  width: 1.0,
                  maxWidth: 10.0,
                  type: SignatureDrawType.shape,
                );
                signature = newSignature;
              });
              await pref.setInt('token', id);
              print(pref.getInt('token'));
              Color? color = colors[pref.getInt('token')!];
              print('color: $color');
            },
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Column(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.all(20),
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 5,
                    ),
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Colors.grey.shade300,
                  ),
                  child: signature,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: (active)
                      ? () {
                          signatureControl.clear();
                          setState(() {
                            active = false;
                          });
                        }
                      : null,
                  style: (active)
                      ? ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.purple,
                          ),
                        )
                      : null,
                  child: const Text(
                    "Clear",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: (active)
                      ? () {
                          final png = signature.control.toImage();
                          final svg = signature.control.toSvg();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: const Text('Preview'),
                              content: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                height: MediaQuery.of(context).size.width,
                                width: MediaQuery.of(context).size.width,
                                child: (svg == null)
                                    ? const Placeholder()
                                    : SvgPicture.string(svg),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await saveImage(png);
                                    } catch (err) {
                                      print(err);
                                      SnackBar snackBar = const SnackBar(
                                          content: Text('Failed to save'));
                                      ScaffoldMessenger.of(context)
                                          .clearSnackBars();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      return;
                                    }
                                    SnackBar snackBar = const SnackBar(
                                        content: Text(
                                            'Successfully saved in the app directory'));

                                    ScaffoldMessenger.of(context)
                                        .clearSnackBars();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);

                                    Navigator.pop(context);
                                  },
                                  child: const Text('Download'),
                                ),
                              ],
                            ),
                          );
                        }
                      : null,
                  style: (active)
                      ? ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            Colors.purple,
                          ),
                        )
                      : null,
                  child: const Text(
                    "Preview",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
