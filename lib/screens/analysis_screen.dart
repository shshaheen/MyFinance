import 'package:flutter/material.dart';

class AnalysisScreen extends StatefulWidget {
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis Screen'),
      ),
      body: Center(
        child: Text('This is the Analysis Screen'),
      ),
    );
  }

}
