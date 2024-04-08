import 'dart:io'; // Import the dart:io package
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextOnPicturePage extends StatefulWidget {
  @override
  _TextOnPicturePageState createState() => _TextOnPicturePageState();
}

class _TextOnPicturePageState extends State<TextOnPicturePage> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text on Picture'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Upload Photo'),
            ),
            SizedBox(height: 20),
            _image != null
                ? Image.file(
                    _image!,
                    height: 200,
                  )
                : SizedBox(),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter your text here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement text on picture functionality
              },
              child: Text('Apply Text'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageOverlay extends StatelessWidget {
  final ui.Image image;
  final CustomPainter overlay;

  const ImageOverlay({
    required this.image,
    required this.overlay,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: OverlayPainter(image: image, overlay: overlay),
        child: Container(),
      ),
    );
  }
}

class OverlayPainter extends CustomPainter {
  final ui.Image image;
  final CustomPainter overlay;

  OverlayPainter({
    required this.image,
    required this.overlay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    overlay.paint(canvas, size); // This line was causing the error
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
