import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_service.dart';
import '../../../services/bank_service.dart'; // Add this import

class SetBalancePage extends StatefulWidget {
  const SetBalancePage({super.key});

  @override
  State<SetBalancePage> createState() => _SetBalancePageState();
}

class _SetBalancePageState extends State<SetBalancePage> {
  final TextEditingController _balanceController = TextEditingController();
  final AuthService _authService = AuthService();
  final BankService _bankService = BankService(); // Add BankService
  String? _errorMessage;
  bool _isLoading = false;
  bool _isFetchingBalance = false; // Track fetching state

  Future<void> _setBalance() async {
    final balanceText = _balanceController.text.trim();

    if (balanceText.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a balance';
      });
      return;
    }

    final balance = double.tryParse(balanceText);
    if (balance == null || balance < 0) {
      setState(() {
        _errorMessage = 'Please enter a valid positive number';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await _authService.updateBalance(user.uid, balance);
        await _authService.updateUserData(user.uid, {'hasSetBalance': true});
        if (context.mounted) {
          context.go('/'); // Navigate to root (HomePage)
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to set balance: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Add method to fetch balance from bank
  Future<void> _fetchBalanceFromBank() async {
    setState(() {
      _isFetchingBalance = true;
      _errorMessage = null;
    });

    try {
      final balance = await _bankService.fetchBalanceFromBank();
      _balanceController.text = balance.toString();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch balance: $e';
      });
    } finally {
      setState(() {
        _isFetchingBalance = false;
      });
    }
  }

  @override
  void dispose() {
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202422),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set Your Balance',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Initial Balance',
                  hintText: 'e.g., 1000.00',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  filled: true,
                  fillColor: const Color.fromARGB(255, 5, 4, 4),
                  labelStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color.fromRGBO(0, 0, 0, 0.45),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Add Fetch Balance button
              _isFetchingBalance
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _fetchBalanceFromBank,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Fetch Balance from Bank',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _setBalance,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF202422),
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Set Balance',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}