//image_detail_page.dart
import 'package:flutter/material.dart';

class ImageDetailPage extends StatelessWidget {
  final String imagePath;
  final String name;
  final String description;

  ImageDetailPage({
    required this.imagePath,
    required this.name,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Detail'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'imageHero-0',
            child: Image.network(imagePath),
          ),
          SizedBox(height: 20),
          Text(
            'Name: $name',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 10),
          Text(
            'Description: $description',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

