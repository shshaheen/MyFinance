import 'package:flutter/material.dart';
import 'package:my_finance/models/category.dart';
// import 'package:my_finance/screens/records_screen.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
 
@override
void initState() {
  super.initState();
  if (widget.transaction != null) {
    _titleController.text = widget.transaction!['title'];
    _amountController.text = widget.transaction!['amount'].toString();
    _selectedDate = DateTime.parse(widget.transaction!['date']);
    _selectedCategory = widget.transaction!['category'];
    _selectedType = widget.transaction!['type'] == "TransactionType.expense"
        ? TransactionType.expense
        : TransactionType.income;
  }
}

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  TransactionType _selectedType = TransactionType.expense;
  // List<Category> _categories = [];

  // void _fetchCategories() async {
  //   FirebaseFirestore.instance.collection('categories').snapshots().listen((snapshot) {
  //     setState(() {
  //       _categories = snapshot.docs.map((doc) => Category.fromFirestore(doc.data(), doc.id)).toList();
  //     });
  //   });
  // }

  String? _selectedCategory;

  final formatter = DateFormat.yMMMd();
  void _manageCategories() {
  TextEditingController categoryController = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text("Manage Categories"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // List of categories
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('categories').snapshots(),
                builder: (ctx, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final categories = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    itemBuilder: (ctx, index) {
                      var category = categories[index];
                      String categoryId = category.id;
                      String categoryName = category['name'];

                      return ListTile(
                        title: Text(categoryName),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit category button
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                categoryController.text = categoryName;
                                _editCategory(categoryId, categoryController.text);
                              },
                            ),
                            // Delete category button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCategory(categoryId),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),
              // Add new category input
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "New Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  _addNewCategory(categoryController.text.trim());
                  categoryController.clear();
                },
                child: const Text("Add New Category"),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _editCategory(String categoryId, String newName) async {
    if (newName.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .update({'name': newName.trim()});
  }


  void _deleteCategory(String categoryId) async {
  await FirebaseFirestore.instance
      .collection('categories')
      .doc(categoryId)
      .delete();
  }


void _addNewCategory(String category) async {
  final docRef = FirebaseFirestore.instance.collection('categories').doc();
  await docRef.set({'name': category});
}



  void _submitTransaction() async {
  final enteredAmount = double.tryParse(_amountController.text);
  final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

  if (_titleController.text.trim().isEmpty ||
      amountIsInvalid ||
      _selectedDate == null ||
      _selectedCategory == null) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Invalid Input"),
        content: const Text(
            "Please enter a valid Title, Amount, Date, and Category."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
    return;
  }

  try {
    if (widget.transaction != null) {
      // **Update Existing Transaction**
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(widget.transaction!['id'])
          .update({
        'title': _titleController.text.trim(),
        'amount': enteredAmount,
        'date': _selectedDate!.toIso8601String(),
        'category': _selectedCategory,
        'type': _selectedType.toString(),
      });
    } else {
      // **Add New Transaction**
      String docId =
          FirebaseFirestore.instance.collection('transactions').doc().id;
      await FirebaseFirestore.instance.collection('transactions').doc(docId).set({
        'id': docId,
        'title': _titleController.text.trim(),
        'amount': enteredAmount,
        'date': _selectedDate!.toIso8601String(),
        'category': _selectedCategory,
        'type': _selectedType.toString(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    Navigator.pop(context);
  } catch (error) {
    // print("Error saving transaction: $error");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Error"),
        content: const Text("Failed to save transaction. Try again."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Okay"),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("Add Transaction"),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body:  SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, keyboardSpace + 16),
              child: Card(
              color: theme.cardColor,
          
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _titleController,
                        maxLength: 50,
                        decoration: InputDecoration(
                          labelText: "Title",
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          prefixIcon: const Icon(Icons.attach_money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Transaction Type",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ToggleButtons(
                                isSelected: [
                                  _selectedType == TransactionType.expense,
                                  _selectedType == TransactionType.income
                                ],
                                onPressed: (index) {
                                  setState(() {
                                    _selectedType = index == 0
                                        ? TransactionType.expense
                                        : TransactionType.income;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                selectedColor: Colors.white,
                                fillColor: theme.colorScheme.secondary,
                                color: theme.colorScheme.onBackground,
                                children: const [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text("Expense"),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12),
                                    child: Text("Income"),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(DateTime.now().year - 1),
                                    lastDate: DateTime(DateTime.now().year + 1),
                                  );
                                  if (pickedDate != null) {
                                    setState(() {
                                      _selectedDate = pickedDate;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(_selectedDate == null
                                          ? "Select Date"
                                          : formatter.format(_selectedDate!)),
                                      const SizedBox(width: 8),
                                       Icon(Icons.calendar_today,
                                          color: Theme.of(context).colorScheme.secondary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Text("Category",
                          style:
                              TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('categories').snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return Text("No categories available");
    }

    // Map Firestore data to a list of category objects
    List<Category> categories = snapshot.data!.docs.map((doc) {
      return Category(id: doc.id, name: doc['name']);
    }).toList();

    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: categories.map((category) {
        return DropdownMenuItem(
          value: category.id,
          child: Text(category.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategory = value;
        });
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  },
),

                      const SizedBox(height: 2),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _manageCategories,
                          
                          style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.secondary,
                          
                        ),
                        child: const Text("Manage Categories"),),
                        ),
                      
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                          ElevatedButton.icon(
                            onPressed: _submitTransaction,
                            icon: const Icon(Icons.save),
                            label: const Text("Save Transaction"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                             ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}