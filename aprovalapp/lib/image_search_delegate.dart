//image_search_delegate.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImageSearchDelegate extends SearchDelegate<String> {
  final List<QueryDocumentSnapshot> imageList;

  ImageSearchDelegate({required this.imageList});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<QueryDocumentSnapshot> results = imageList.where((doc) {
      String name = doc['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var image = results[index].data() as Map<String, dynamic>;

        return ListTile(
          title: Text(image['name']),
          subtitle: Text(image['description']),
          leading: Image.network(
            image['imagePath'],
            width: 50,
            height: 50,
          ),
          onTap: () {
            close(context, image['name']);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<QueryDocumentSnapshot> suggestions = imageList.where((doc) {
      String name = doc['name'].toString().toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var suggestion = suggestions[index].data() as Map<String, dynamic>;

        return ListTile(
          title: Text(suggestion['name']),
          subtitle: Text(suggestion['description']),
          leading: Image.network(
            suggestion['imagePath'],
            width: 50,
            height: 50,
          ),
          onTap: () {
            query = suggestion['name'];
            showResults(context);
          },
        );
      },
    );
  }
}
