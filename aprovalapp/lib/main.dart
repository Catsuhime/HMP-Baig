import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'image_detail_page.dart';
import 'image_search_delegate.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image List App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _getScreen(),
    );
  }

  Widget _getScreen() {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return MyHomePage();
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _ascendingOrder = true;
  String _searchQuery = '';
  late List<QueryDocumentSnapshot> _imageList;

  @override
  void initState() {
    super.initState();
    _imageList = [];
  }

  void _signOut() async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // Get the current user
    User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort_by_alpha),
            onPressed: () {
              setState(() {
                _ascendingOrder = !_ascendingOrder;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final result = await showSearch(
                context: context,
                delegate: ImageSearchDelegate(imageList: _imageList),
              );

              if (result != null) {
                setState(() {
                  _searchQuery = result;
                });
              }
            },
          ),
          // Display the user's email in the app bar
          Text(currentUser?.email ??
              ''), // Use null-aware operator to avoid null reference

          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _firestore.collection('images').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          _imageList = snapshot.data!.docs;

          _imageList.sort((a, b) {
            String nameA = a['name'].toString().toUpperCase();
            String nameB = b['name'].toString().toUpperCase();
            return _ascendingOrder
                ? nameA.compareTo(nameB)
                : nameB.compareTo(nameA);
          });

          if (_searchQuery.isNotEmpty) {
            _imageList = _imageList.where((doc) {
              String name = doc['name'].toString().toLowerCase();
              return name.contains(_searchQuery.toLowerCase());
            }).toList();
          }

          return ListView.builder(
            itemCount: _imageList.length,
            itemBuilder: (context, index) {
              var image = _imageList[index].data() as Map<String, dynamic>;

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageDetailPage(
                        imagePath: image['imagePath'],
                        name: image['name'],
                        description: image['description'],
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(image['name']),
                  subtitle: Text(image['description']),
                  leading: Hero(
                    tag: 'imageHero-$index',
                    child: Image.network(
                      image['imagePath'],
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
