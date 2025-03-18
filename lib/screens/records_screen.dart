import 'package:flutter/material.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});
  @override
  RecordsScreenState createState() => RecordsScreenState();
}

class RecordsScreenState extends State<RecordsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Records'),
      ),
      body: Center(
        child: Text('This is the Records screen.'),
      ),
    );
  }
}
