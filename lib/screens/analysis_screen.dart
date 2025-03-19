import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});
  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedFilter = "Net Amount";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Aligns items properly
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
                items: ["Income Overview", "Expense Overview", "Net Amount"]
                    .map((filter) => DropdownMenuItem(
                          value: filter,
                          child: Text(filter,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                        ))
                    .toList(),
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white), // Filter icon
              onPressed: () {
                // Action when filter icon is clicked
                print("Filter icon clicked");
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

          Map<String, double> categorySpending = {};
          Map<String, double> categoryEarnings = {};
          Map<String, double> categoryNetAmount = {};
          for (var doc in snapshot.data!.docs) {
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

          Map<String, double> positiveNetAmount = {};
          categoryNetAmount.forEach((key, value) {
            positiveNetAmount[key] =
                value.abs(); // Convert to positive for the chart
          });

          Map<String, double> positiveSpending = {};
          categorySpending.forEach((key, value) {
            positiveSpending[key] =
                value.abs(); // Convert to positive for the chart
          });
          Map<String, double> selectedData;
          Map<String, double> selectedDataForCategory;
          if (_selectedFilter == "Expense Overview") {
            selectedData = positiveSpending;
            selectedDataForCategory = categorySpending;
          } else if (_selectedFilter == "Income Overview") {
            selectedData = categoryEarnings;
            selectedDataForCategory = categoryEarnings; //
          } else {
            selectedData = positiveNetAmount;
            selectedDataForCategory = categoryNetAmount;
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
        final Color amountColor = isNegative ? Colors.red : Colors.green;
        return Card(
          // color: Colors.black,
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: ListTile(
            leading: Icon(Icons.circle,
                color: Colors.primaries[data.keys.toList().indexOf(entry.key) %
                    Colors.primaries.length]),
            title: Text(entry.key,
                style: TextStyle(color: const Color.fromARGB(255, 54, 52, 52))),
            trailing: Text("$sign ₹${entry.value.abs().toStringAsFixed(2)}",
                style:
                    TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }
}
