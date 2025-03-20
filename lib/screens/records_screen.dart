import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_finance/screens/add_transaction_screen.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  double totalIncome = 0;
  double totalExpense = 0;
  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  /// Fetch transactions from Firestore
  void _fetchTransactions() async {
    QuerySnapshot snapshot = await _firestore.collection('transactions').get();

    List<Map<String, dynamic>> fetchedTransactions = snapshot.docs.map((doc) {
      // print("Fetched doc ID: ${doc.id}"); // Debugging
      return {
        'id': doc.id, // Store document ID
        ...doc.data() as Map<String, dynamic>,
      };  
    }).toList();

    setState(() {
      transactions = fetchedTransactions;
    });
  }

  /// Delete transaction from Firestore & update UI
  void _deleteTransaction(String transactionId) async {
    // print(
    //     "Attempting to delete transaction with ID: $transactionId"); // Debugging

    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      // print("Transaction deleted successfully: $transactionId");

      // Remove from UI after deletion
      setState(() {
        transactions.removeWhere((t) => t['id'] == transactionId);
      });
    } catch (e) {
      // print("Error deleting transaction: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
            data['id'] = doc.id; // Add document ID

            DateTime date;
            if (data['date'] is Timestamp) {
              date = (data['date'] as Timestamp).toDate();
            } else if (data['date'] is String) {
              date = DateTime.parse(data['date']);
            } else {
              date = DateTime.now();
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.2), // Shadow color
                  blurRadius: 12, // Softness of the shadow
                  spreadRadius: 3, // How much the shadow spreads
                  offset: Offset(0, 4), // Moves shadow downward
                ),
              ],
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)), // Rounded bottom
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _summaryItem(context,"EXPENSE", "-\$${totalExpense.toStringAsFixed(2)}", Colors.red),
                _summaryItem(context, "INCOME", "+\$${totalIncome.toStringAsFixed(2)}", Colors.green),
                _summaryItem(context, "TOTAL", "\$${balance.toStringAsFixed(2)}", const Color.fromARGB(255, 36, 181, 225)),
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
                    List<Map<String, dynamic>> transactions =
                        groupedTransactions[date]!;
                    return buildTransactionSection(date, transactions);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryItem(BuildContext context, title, String value, Color color) {
    return Column(
      children: [
        Text(title,
         style:  TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget buildTransactionSection(
      String date, List<Map<String, dynamic>> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(date,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Column(
          children: transactions
              .map((transaction) => _buildTransactionItem(transaction))
              .toList(),
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
      title: Text(transaction['title'],
          style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Row(
        children: [
          Text(transaction['category'] ?? 'Unknown'),
          const SizedBox(width: 10),
          Text(
            "${isExpense ? '-' : '+'}₹${transaction['amount'].toStringAsFixed(2)}",
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_horiz),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        elevation: 8,
        onSelected: (value) {
          if (value == 'edit') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(transaction: transaction,)));
            // print("Edit clicked: ${transaction['id']}");
          } else if (value == 'delete') {
            // print("Delete clicked for ID: ${transaction['id']}"); // Debugging
            _deleteTransaction(transaction['id']);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit')),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete')),
          ),
        ],
      ),
    );
  }
}
