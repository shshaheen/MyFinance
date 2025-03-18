import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();
const uuid = Uuid();

enum Category { food, leisure, travel, work }


enum TransactionType { income, expense }

class Transaction {
  Transaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.type,  // NEW FIELD
  }) : id = uuid.v4();

  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final TransactionType type; // NEW FIELD

  String get formattedDate {
    return formatter.format(date);
  }
}
