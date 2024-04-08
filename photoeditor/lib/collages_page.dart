import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';

class CollagesPage extends StatefulWidget {
  @override
  _CollagesPageState createState() => _CollagesPageState();
}

class _CollagesPageState extends State<CollagesPage> {
  final List<File> _selectedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        setState(() {
          _selectedImages.add(file);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _saveCollage() async {
    if (_selectedImages.isNotEmpty) {
      try {
        List<img.Image> images = [];
        for (var imageFile in _selectedImages) {
          final bytes = await imageFile.readAsBytes();
          images.add(img.decodeImage(bytes)!);
        }
        final collageImage = createCollage(images);
        final collageBytes = img.encodePng(collageImage);
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(collageBytes!));
        print('Collage saved to gallery: $result');
      } catch (e) {
        print('Error saving collage to gallery: $e');
      }
    }
  }

  img.Image createCollage(List<img.Image> images) {
    int totalWidth = 0;
    int maxHeight = 0;

    for (var image in images) {
      totalWidth += image.width;
      if (image.height > maxHeight) {
        maxHeight = image.height;
      }
    }

    img.Image collage = img.Image(totalWidth, maxHeight);

    int offsetX = 0;
    for (var image in images) {
      img.drawImage(
        collage,
        image,
        dstX: offsetX,
        dstY: 0,
      );
      offsetX += image.width;
    }

    return collage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collages'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: _selectedImages.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    // Handle image tap
                  },
                  child: Image.file(
                    _selectedImages[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Add Image'),
              ),
              ElevatedButton(
                onPressed: _saveCollage,
                child: Text('Save Collage'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedImages.clear();
                  });
                },
                child: Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
