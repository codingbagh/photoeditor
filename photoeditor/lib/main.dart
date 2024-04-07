import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Editing App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Photo Editing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<String> _filters = ['No Filter', 'Grayscale', 'Sepia', 'Invert'];
  String _selectedFilter = 'No Filter';
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CollagesPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Widget _buildImage() {
    if (_imageFile != null) {
      final image = img.decodeImage(_imageFile!.readAsBytesSync())!;
      final filteredImage = applyFilter(image, _selectedFilter);
      final encodedImage = Uint8List.fromList(img.encodePng(filteredImage)!);
      return Image.memory(
        encodedImage,
        height: 300,
      );
    } else {
      return const Text(
        'No image selected',
        style: TextStyle(fontSize: 20),
      );
    }
  }

  img.Image applyFilter(img.Image image, String filter) {
    switch (filter) {
      case 'Grayscale':
        return img.grayscale(image);
      case 'Sepia':
        return img.sepia(image);
      case 'Invert':
        return img.invert(image);
      default:
        return image;
    }
  }

  Future<void> _saveImage() async {
    if (_imageFile != null) {
      try {
        final image = img.decodeImage(_imageFile!.readAsBytesSync())!;
        final filteredImage = applyFilter(image, _selectedFilter);
        final bytes = Uint8List.fromList(img.encodePng(filteredImage)!);
        final result = await ImageGallerySaver.saveImage(bytes);
        print('Image saved to gallery: $result');
      } catch (e) {
        print('Error saving image to gallery: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildImage(),
            const SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
              items: _filters.map((filter) {
                return DropdownMenuItem<String>(
                  value: filter,
                  child: Text(filter),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery),
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.camera),
              child: const Text('Take Photo'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveImage,
              child: const Text('Download Image'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Edit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: 'Collages',
          ),
        ],
      ),
    );
  }
}

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
        // Save collage functionality
      } catch (e) {
        print('Error saving collage to gallery: $e');
      }
    }
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
