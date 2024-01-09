import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Image App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();

  Future<void> _takePicture() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadData() async {
    if (_imageFile == null) {
      return;
    }

    final storage = FirebaseStorage.instance;
    final imageRef = storage.ref().child('images/${DateTime.now()}.png');
    await imageRef.putFile(_imageFile!);

    final downloadUrl = await imageRef.getDownloadURL();

    final firestore = FirebaseFirestore.instance;
    await firestore.collection('images').add({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'imagePath': downloadUrl,
    });

    // Clear fields after upload
    _nameController.clear();
    _descriptionController.clear();
    setState(() {
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_imageFile != null)
              Image.file(
                _imageFile!,
                height: 200,
              ),
            ElevatedButton(
              onPressed: _takePicture,
              child: Text('Take Picture'),
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _uploadData,
              child: Text('Upload Data'),
            ),
          ],
        ),
      ),
    );
  }
}
