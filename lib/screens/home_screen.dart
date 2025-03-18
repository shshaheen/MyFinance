import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './add_transaction_screen.dart';
import 'package:my_finance/screens/analysis_screen.dart';
import 'package:my_finance/screens/records_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;
  String fullName = "Loading...";

  final List<Widget> _pages = [
    AnalysisScreen(),
    AddTransactionScreen(),
    RecordsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userData = await _authService.getUserData(user.uid);
      setState(() {
        fullName = userData['fullName'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, $fullName')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex:  _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items:  const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), 
            label: 'Analysis'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Transaction'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Records'),
        ]
      ),
    );
  }
}
