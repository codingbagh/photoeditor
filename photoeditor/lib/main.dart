import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:image_picker/image_picker.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:photoeditor/constants/constants.dart';
import 'package:image/image.dart' as img;
import 'package:photoeditor/utils/show_dialogue.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grp 16 Image Editor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(212, 180, 127, 227),
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Grp 16 Image Editor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? originalImageData;
  Uint8List? imageData;
  int imageSelected = 0;

  @override
  void initState() {
    super.initState();
    loadAsset(AssetsConstants.placeholderLogo);
  }

  void loadAsset(String name) async {
    var data = await rootBundle.load(name);
    setState(() {
      imageData = data.buffer.asUint8List();
    });
  }

  Future<Uint8List?> applyFilter(Uint8List? imageBytes) async {
    if (imageBytes == null) return null;

    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;
    final sepiaImage = img.sepia(originalImage);

    return Uint8List.fromList(img.encodeJpg(sepiaImage));
  }

  Future<void> saveEditedImage(Uint8List editedImageData) async {
    try {
      final result = await ImageGallerySaver.saveImage(editedImageData);
      if (result != null && result.isNotEmpty) {
        showDialogBox(context, 'Image saved successfully');
      } else {
        showDialogBox(context, 'Failed to save image');
      }
    } catch (e) {
      showDialogBox(context, "Image not saved: $e");
    }
  }

  Future getImage(ImageSource source) async {
    final image = await ImagePicker().pickImage(source: source);
    if (image == null) return;

    final imageTemporary = File(image.path);
    setState(() {
      imageSelected = 1;
      originalImageData = imageTemporary.readAsBytesSync();
      imageData = imageTemporary.readAsBytesSync();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                imageData != null
                    ? SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.memory(imageData!),
                      )
                    : SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.asset('assets/images/Screenshot.png'),
                      ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton.icon(
                  onPressed: () => getImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Image From Gallery"),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (imageSelected != 1) {
                              throw Exception("Please select an image first");
                            }
                            final editedImage = await applyFilter(imageData);
                            if (editedImage != null) {
                              setState(() {
                                imageData = editedImage;
                              });
                            }
                          } catch (e) {
                            showDialogBox(context, "$e");
                          }
                        },
                        child: const Text("Apply a Filter"),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            if (imageSelected != 1) {
                              throw Exception("Please select an image first");
                            }
                            var editedImage = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ImageEditor(
                                  image: imageData,
                                ),
                              ),
                            );
                            if (editedImage != null) {
                              imageData = editedImage;
                              setState(() {});
                            }
                          } catch (e) {
                            showDialogBox(context, "$e");
                          }
                        },
                        child: const Text("Full Image editor"),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 133, 214, 230),
                          ),
                        ),
                        onPressed: () async {
                          try {
                            if (imageSelected != 1) {
                              throw Exception("Please select an image first");
                            }
                            await saveEditedImage(imageData!);
                          } catch (e) {
                            showDialogBox(context, "$e");
                          }
                        },
                        child: const Text("Save"),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.all(10),
                      child: ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            Color.fromARGB(255, 241, 86, 34),
                          ),
                        ),
                        onPressed: () {
                          try {
                            if (imageSelected != 1) {
                              throw Exception("Please select an image first");
                            }
                            imageData = originalImageData;
                            setState(() {});
                          } catch (e) {
                            showDialogBox(context, "$e");
                          }
                        },
                        child: const Text("Reset all changes"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
