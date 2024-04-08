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
  String _selectedStyle = 'Simple'; // Default collage style

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
        final collageImage = createCollage(_selectedImages
            .map((file) => img.decodeImage(file.readAsBytesSync())!)
            .toList());
        final collageBytes = img.encodePng(collageImage!);
        final result = await ImageGallerySaver.saveImage(
            Uint8List.fromList(collageBytes!));
        print('Collage saved to gallery: $result');
      } catch (e) {
        print('Error saving collage to gallery: $e');
      }
    }
  }

  img.Image createCollage(List<img.Image> images) {
    switch (_selectedStyle) {
      case 'Simple':
        return _createSimpleCollage(images);
      case 'Grid':
        return _createGridCollage(images);
      case 'Custom':
        return _createCustomCollage(images);
      default:
        return _createSimpleCollage(images); // Default to simple collage style
    }
  }

  img.Image _createSimpleCollage(List<img.Image> images) {
    // Concatenate images horizontally
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

  img.Image _createGridCollage(List<img.Image> images) {
    // Arrange images in a grid layout
    // For simplicity, let's arrange them in a 3x3 grid
    int gridWidth = 3; // Number of columns
    int gridHeight = (images.length / gridWidth).ceil(); // Number of rows
    int collageWidth = images.fold(0, (prev, img) => prev + img.width);
    int collageHeight = images.fold(0, (prev, img) => prev + img.height);

    img.Image collage = img.Image(collageWidth, collageHeight);

    int offsetX = 0;
    int offsetY = 0;
    for (var image in images) {
      img.drawImage(
        collage,
        image,
        dstX: offsetX,
        dstY: offsetY,
      );
      offsetX += image.width;
      if ((offsetX / image.width) % gridWidth == 0) {
        offsetX = 0;
        offsetY += image.height;
      }
    }

    return collage;
  }

  img.Image _createCustomCollage(List<img.Image> images) {
    // Implement your custom collage layout here
    // You can define your own logic to arrange images in a unique layout
    // For example, you can arrange them in a circular pattern or in a random grid
    // This method allows you to create any layout you desire
    // For simplicity, let's just use the simple collage layout for now
    return _createSimpleCollage(images);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collages'),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _selectedStyle,
                onChanged: (value) {
                  setState(() {
                    _selectedStyle = value!;
                  });
                },
                items: ['Simple', 'Grid', 'Custom'].map((style) {
                  return DropdownMenuItem<String>(
                    value: style,
                    child: Text(style),
                  );
                }).toList(),
              ),
              SizedBox(width: 20), // Add space between dropdown and buttons
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: Text('Add'),
              ),
              SizedBox(width: 20), // Add space between buttons
              ElevatedButton(
                onPressed: _saveCollage,
                child: Text('Save'),
              ),
              SizedBox(width: 20), // Add space between buttons
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
        ],
      ),
    );
  }
}
