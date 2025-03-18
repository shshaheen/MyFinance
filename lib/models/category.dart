class CategoryModel {
  List<String> categories = ["Food", "Leisure", "Travel", "Work"];

  void addCategory(String newCategory) {
    categories.add(newCategory);
  }

  void editCategory(int index, String updatedCategory) {
    categories[index] = updatedCategory;
  }

  void deleteCategory(int index) {
    categories.removeAt(index);
  }
}

final categoryModel = CategoryModel(); // Global instance
