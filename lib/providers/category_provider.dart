import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryProvider with ChangeNotifier {
  List<String> _categories = [];
  String? _selectedCategory;

  List<String> get categories => _categories;
  String? get selectedCategory => _selectedCategory;

  CategoryProvider() {
    _fetchCategories();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> addCategory(String newCategory) async {
    if (!_categories.contains(newCategory)) {
      _categories.add(newCategory);
      _selectedCategory = newCategory;
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(newCategory)
          .set({'name': newCategory});
      notifyListeners();
    }
  }

  Future<void> editCategory(String oldCategory, String newCategory) async {
    if (_categories.contains(oldCategory) && !_categories.contains(newCategory)) {
      await FirebaseFirestore.instance.collection('categories').doc(oldCategory).delete();
      await FirebaseFirestore.instance.collection('categories').doc(newCategory).set({'name': newCategory});
      int index = _categories.indexOf(oldCategory);
      _categories[index] = newCategory;
      if (_selectedCategory == oldCategory) {
        _selectedCategory = newCategory;
      }
      notifyListeners();
    }
  }

  Future<void> removeCategory(String category) async {
    if (_categories.contains(category)) {
      await FirebaseFirestore.instance.collection('categories').doc(category).delete();
      _categories.remove(category);
      if (_selectedCategory == category) {
        _selectedCategory = null;
      }
      notifyListeners();
    }
  }

  Future<void> _fetchCategories() async {
    final snapshot = await FirebaseFirestore.instance.collection('categories').get();
    _categories = snapshot.docs.map((doc) => doc['name'].toString()).toList();
    notifyListeners();
  }
}