import 'dart:io'; // Import the dart:io package
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';

class TextOnPicturePage extends StatefulWidget {
  @override
  _TextOnPicturePageState createState() => _TextOnPicturePageState();
}

class _TextOnPicturePageState extends State<TextOnPicturePage> {
  File? _image;
  String _text = ''; // Variable to store the entered text

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveImage() async {
    if (_image != null) {
      try {
        // Convert the image file to bytes
        Uint8List bytes = await _image!.readAsBytes();

        // Decode the image bytes
        ui.Image image = await decodeImageFromList(bytes);

        // Get the image width and height
        int width = image.width;
        int height = image.height;

        // Create a new PictureRecorder
        ui.PictureRecorder recorder = ui.PictureRecorder();

        // Create a new Canvas
        ui.Canvas canvas = ui.Canvas(recorder);

        // Draw the image on the canvas
        Paint paint = Paint()..filterQuality = FilterQuality.high;
        canvas.drawImage(image, Offset.zero, paint);

        // Draw text on the canvas
        TextPainter painter = TextPainter(
          text: TextSpan(
            text: _text,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );
        painter.layout();
        painter.paint(canvas, Offset((width - painter.width) / 2, height - 50));

        // End the recording
        ui.Picture picture = recorder.endRecording();

        // Convert the picture to an image
        ui.Image img = await picture.toImage(width, height);

        // Convert the image to bytes
        ByteData? byteData =
            await img.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // Save the image to the gallery
        await ImageGallerySaver.saveImage(pngBytes);

        // Show a confirmation message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Image saved successfully'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (e) {
        print('Error saving image: $e');
        // Show an error message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred while saving the image'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
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
              onChanged: (text) {
                setState(() {
                  _text = text; // Update the text variable
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Implement text on picture functionality
              },
              child: Text('Apply Text'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveImage,
              child: Text('Save Image'),
            ),
          ],
        ),
      ),
    );
  }
}
