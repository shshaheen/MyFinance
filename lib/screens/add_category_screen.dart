// import 'package:flutter/material.dart';
// import 'add_transaction_screen.dart';

// class AddCategoryScreen extends StatelessWidget {
//   final TextEditingController _categoryController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Add Category")),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _categoryController,
//               decoration: InputDecoration(labelText: "Category Name"),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 if (_categoryController.text.trim().isNotEmpty) {
//                   Navigator.pop(
//                     context,
//                     CategoryModel(
//                       id: DateTime.now().toString(),
//                       name: _categoryController.text.trim(),
//                     ),
//                   );
//                 }
//               },
//               child: Text("Add Category"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
