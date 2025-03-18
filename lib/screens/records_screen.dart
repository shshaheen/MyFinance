import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalIncome = 0;
  double totalExpense = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money Manager"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('transactions')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No transactions found."));
          }

          List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
          Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
          totalIncome = 0;
          totalExpense = 0;

          for (var doc in docs) {
            var data = doc.data() as Map<String, dynamic>;
            var date;
            if (data['date'] is Timestamp) {
              date = (data['date'] as Timestamp).toDate();
            } else if (data['date'] is String) {
              date = DateTime.parse(data['date']);
            } else {
              date = DateTime.now(); // Fallback to current date if the format is unknown
            }

            String formattedDate = DateFormat.yMMMMd().format(date);

            if (!groupedTransactions.containsKey(formattedDate)) {
              groupedTransactions[formattedDate] = [];
            }
            groupedTransactions[formattedDate]!.add(data);

            if (data['type'] == 'TransactionType.income') {
              totalIncome += data['amount'];
            } else {
              totalExpense += data['amount'];
            }
          }

          double balance = totalIncome - totalExpense;

          return Column(
            children: [
              // Top Summary Section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.deepPurple,
                child: Column(
                  children: [
                    Text(
                      "January, 2025",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem("EXPENSE", "-\$${totalExpense.toStringAsFixed(2)}", Colors.red),
                        _summaryItem("INCOME", "+\$${totalIncome.toStringAsFixed(2)}", Colors.green),
                        _summaryItem("TOTAL", "\$${balance.toStringAsFixed(2)}", Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Transactions List
              Expanded(
                child: ListView.builder(
                  itemCount: groupedTransactions.keys.length,
                  itemBuilder: (context, index) {
                    String date = groupedTransactions.keys.elementAt(index);
                    List<Map<String, dynamic>> transactions = groupedTransactions[date]!;
                    return _buildTransactionSection(date, transactions);
                  },
                ),
              ),
            ],
          );
        },
      ),
      
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTransactionSection(String date, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Column(
          children: transactions.map((transaction) => _buildTransactionItem(transaction)).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    bool isExpense = transaction['type'] == 'TransactionType.expense';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.attach_money, color: Colors.black),
      ),
      title: Text(transaction['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(transaction['category'] ?? 'Unknown'),
      trailing: Text(
        "${isExpense ? '-' : '+'}\$${transaction['amount'].toStringAsFixed(2)}",
        style: TextStyle(color: isExpense ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
      ),
    );
  }
}
