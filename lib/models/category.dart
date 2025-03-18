import 'package:uuid/uuid.dart';

const uuid = Uuid();

class CategoryModel {
  final String id;
  String name;

  CategoryModel({required this.id, required this.name});

  // Factory constructor to create a new category with a unique ID
  factory CategoryModel.create(String name) {
    return CategoryModel(id: uuid.v4(), name: name);
  }
}


List<CategoryModel> defaultCategories = [
  CategoryModel(id: "1", name: "Food"),
  CategoryModel(id: "2", name: "Leisure"),
  CategoryModel(id: "3", name: "Travel"),
  CategoryModel(id: "4", name: "Work"),
];