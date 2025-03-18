import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

enum Category { food, leisure, travel, work }
enum TransactionType { income, expense }

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category _selectedCategory = Category.food;
  TransactionType _selectedType = TransactionType.expense; // Default to Expense

  void _presentDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _selectedDate = pickedDate;
    });
  }

  void _submitTransaction() {
    final enteredAmount = double.tryParse(_amountController.text);
    final amountIsInvalid = enteredAmount == null || enteredAmount <= 0;

    if (_titleController.text.trim().isEmpty ||
        amountIsInvalid ||
        _selectedDate == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Invalid Input"),
          content: const Text(
              "Please enter a valid Title, Amount, Date, and Category."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text("Okay"),
            ),
          ],
        ),
      );
      return;
    }

    // widget.onAddTransaction(Transaction(
    //     title: _titleController.text,
    //     amount: enteredAmount,
    //     date: _selectedDate!,
    //     category: _selectedCategory,
    //     type: _selectedType, // Store income/expense type
    // ));

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
                  // **Title Input**
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

                  // **Amount Input**
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

                  // **Transaction Type Selector (Income / Expense)**
                  Text(
                    "Transaction Type",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ChoiceChip(
                        label: const Text("Expense"),
                        selected: _selectedType == TransactionType.expense,
                        selectedColor: Colors.redAccent,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = TransactionType.expense;
                          });
                        },
                      ),
                      const SizedBox(width: 10),
                      ChoiceChip(
                        label: const Text("Income"),
                        selected: _selectedType == TransactionType.income,
                        selectedColor: Colors.green,
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = TransactionType.income;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // **Category Selector**
                  Text(
                    "Category",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  DropdownButtonFormField(
                    value: _selectedCategory,
                    items: Category.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
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
                  ),
                  const SizedBox(height: 12),

                  // **Date Picker**
                  GestureDetector(
                    onTap: _presentDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDate == null
                                ? "Select Date"
                                : formatter.format(_selectedDate!),
                            style: TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, color: Colors.blue),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // **Buttons: Cancel & Save**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _submitTransaction,
                        icon: const Icon(Icons.save),
                        label: const Text("Save Transaction"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
