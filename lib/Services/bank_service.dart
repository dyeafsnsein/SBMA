import 'dart:math';

class BankService {
  // Simulate fetching the balance from a bank account
  Future<double> fetchBalanceFromBank() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate a random balance between $1000 and $10000
    final random = Random();
    final balance = 1000 + (random.nextDouble() * 9000); // Range: $1000 to $10000
    return double.parse(balance.toStringAsFixed(2));
  }
}