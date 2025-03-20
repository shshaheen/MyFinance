import 'package:flutter_test/flutter_test.dart';

// Sample function to calculate net balance
int calculateNetBalance(int income, int expenses) {
  return income - expenses;
}

void main() {
  test('Net balance should be calculated correctly', () {
    expect(calculateNetBalance(5000, 2000), 3000);
    expect(calculateNetBalance(10000, 7500), 2500);
  });
}
