import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Main Page')),
      body: Center(
        child: MaterialButton(
          onPressed: () {
            DatabaseReference dbRef =
                FirebaseDatabase.instance.reference().child('Test');
            dbRef.set('Isconnected');
          },
          height: 50,
          minWidth: 300,
          color: Colors.amber,
          child: Text('test connection'),
        ),
      ),
    );
  }
}
