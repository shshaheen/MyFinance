import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  TransactionType _selectedType = TransactionType.expense;
  List<String> _categories = ['Food', 'Leisure', 'Travel', 'Work'];
  String? _selectedCategory;

  final formatter = DateFormat.yMMMd();

  void _addNewCategory() {
    TextEditingController _newCategoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Category"),
          content: TextField(
            controller: _newCategoryController,
            decoration: const InputDecoration(labelText: "Category Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newCategoryName = _newCategoryController.text.trim();
                if (newCategoryName.isNotEmpty && !_categories.contains(newCategoryName)) {
                  setState(() {
                    _categories.add(newCategoryName);
                    _selectedCategory = newCategoryName;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _submitTransaction() {
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
          content: const Text("Please enter a valid Title, Amount, Date, and Category."),
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  const Text("Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  DropdownButtonFormField<String?>(
                    value: _selectedCategory,
                    items: [
                      ..._categories.map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      ),
                      DropdownMenuItem<String?>(
                        value: null,
                        child: const Text("➕ Add New Category"),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        _addNewCategory();
                      } else {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GestureDetector(
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 1),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_selectedDate == null ? "Select Date" : formatter.format(_selectedDate!)),
                          const Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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