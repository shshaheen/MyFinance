import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  AnalysisScreenState createState() => AnalysisScreenState();
}

class AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedFilter = "Net Amount";
  DateTimeRange? _selectedDateRange;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Scaffold(
      // backgroundColor: Colors.black87,
appBar: AppBar(
  elevation: 0, // No shadow
  backgroundColor: Colors.transparent, // Fully transparent
  surfaceTintColor: Colors.transparent, // Prevents unwanted overlay color
  titleSpacing: 0, // Aligns title properly
  title: Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedFilter,
          dropdownColor: Theme.of(context).colorScheme.background, // Matches body
          onChanged: (value) {
            setState(() {
              _selectedFilter = value!;
            });
          },
          items: ["Income Overview", "Expense Overview", "Net Amount"]
              .map((filter) => DropdownMenuItem(
                    value: filter,
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
      const SizedBox(width: 16),
      IconButton(
        icon: Icon(
          Icons.filter_list,
          color: Theme.of(context).colorScheme.onBackground, // Matches text color
        ),
        onPressed: () async {
          DateTimeRange? picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            initialDateRange: _selectedDateRange,
          );

          if (picked != null) {
            setState(() {
              _selectedDateRange = picked;
            });
          }
          },
        ),
      ],
    ),
  ),


      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('transactions').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

    List<QueryDocumentSnapshot> filteredDocs =
        snapshot.data!.docs.where((doc) {
      var data = doc.data() as Map<String, dynamic>;

      if (!data.containsKey('date')) return false;

      // Ensure correct date conversion
      DateTime transactionDate;
      if (data['date'] is Timestamp) {
        transactionDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        try {
          transactionDate = DateTime.parse(data['date']); // Convert string to DateTime
        } catch (e) {
          // print("Invalid date format: ${data['date']}");
          return false; // Skip this document if date format is incorrect
        }
      } else {
        return false; // Skip if date is neither Timestamp nor String
      }

      if (_selectedDateRange == null) return true;

      return transactionDate.isAfter(
              _selectedDateRange!.start.subtract(Duration(seconds: 1))) &&
          transactionDate.isBefore(
              _selectedDateRange!.end.add(Duration(days: 1)));
    }).toList();



          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No $_selectedFilter transactions found in the selected date range!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            );
          }

          if (filteredDocs.isEmpty) {
            return Center(
              child: Text(
                "No $_selectedFilter transactions found in the selected date range!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            );
          }

          // Process filtered transactions
          Map<String, double> categorySpending = {};
          Map<String, double> categoryEarnings = {};
          Map<String, double> categoryNetAmount = {};

          for (var doc in filteredDocs) {
            var data = doc.data() as Map<String, dynamic>;
            double amount = (data['amount'] as num).toDouble();
            String type = data['type'];
            String category = data['category'];

            if (type == 'TransactionType.income') {
              categoryEarnings[category] =
                  (categoryEarnings[category] ?? 0) + amount;
            } else {
              categorySpending[category] =
                  (categorySpending[category] ?? 0) - amount;
            }

            // Ensure values exist before calculating net amount
            double earnings = categoryEarnings[category] ?? 0;
            double spending = categorySpending[category] ?? 0;
            categoryNetAmount[category] = earnings + spending;
          }

          // Convert negative values to positive for visualization
          Map<String, double> positiveNetAmount = {};
          categoryNetAmount.forEach((key, value) {
            positiveNetAmount[key] = value.abs();
          });

          Map<String, double> positiveSpending = {};
          categorySpending.forEach((key, value) {
            positiveSpending[key] = value.abs();
          });

          Map<String, double> selectedData;
          Map<String, double> selectedDataForCategory;

          if (_selectedFilter == "Expense Overview") {
            selectedData = positiveSpending;
            selectedDataForCategory = categorySpending;
          } else if (_selectedFilter == "Income Overview") {
            selectedData = categoryEarnings;
            selectedDataForCategory = categoryEarnings;
          } else {
            selectedData = positiveNetAmount;
            selectedDataForCategory = categoryNetAmount;
          }
          if (selectedData.isEmpty) {
            return Center(
              child: Text(
                "No $_selectedFilter transactions found!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            );
          }
          return Column(
            children: [
              SizedBox(height: 10),
              Expanded(child: _buildPieChart(selectedData)),
              Expanded(child: _buildCategoryList(selectedDataForCategory)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> data) {
    List<Color> colors =
        Colors.primaries.take(data.length).toList(); // Assign unique colors

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pie Chart
        SizedBox(
          height: 200,
          width: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 50, // Creates space in the center
              sections: data.entries.map((entry) {
                int index = data.keys.toList().indexOf(entry.key);
                return PieChartSectionData(
                  value: entry.value,
                  title: '', // Removed text inside chart
                  color: colors[index],
                  radius: 50,
                );
              }).toList(),
            ),
          ),
        ),

        // Legend beside the Pie Chart
        SizedBox(width: 20), // Space between chart and legend
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            int index = data.keys.toList().indexOf(entry.key);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colors[index],
                      shape: BoxShape.circle, // Circular color indicator
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(entry.key, style: TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

Widget _buildCategoryList(Map<String, double> data) {
  return ListView(
    shrinkWrap: true,
    children: data.entries.map((entry) {
      final bool isNegative = entry.value < 0;
      final String sign = isNegative ? "-" : "+";
      final Color amountColor = isNegative 
          ? Theme.of(context).colorScheme.error 
          : Theme.of(context).colorScheme.primary;

      return Card(
        elevation: 3, // Soft shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // color: Theme.of(context).cardColor, // Matches theme
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: Icon(
            Icons.circle,
            size: 12,
            color: Colors.primaries[data.keys.toList().indexOf(entry.key) % Colors.primaries.length],
          ),
          title: Text(
            entry.key,
            style: Theme.of(context).textTheme.titleMedium, // Themed text
          ),
          trailing: Text(
            "$sign ₹${entry.value.abs().toStringAsFixed(2)}",
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      );
    }).toList(),
  );
}

}
