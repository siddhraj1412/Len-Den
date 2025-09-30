import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _storage = StorageService();
  List<Budget> _budgets = [];
  List<Expense> _expenses = [];
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    _budgets = await _storage.getBudgets();
    _expenses = await _storage.getExpenses();
    setState(() => _isLoading = false);
  }

  Budget? get _currentMonthBudget {
    return _budgets.firstWhere(
      (b) =>
          b.month.year == _selectedMonth.year &&
          b.month.month == _selectedMonth.month,
      orElse: () => Budget(amount: 0, month: _selectedMonth),
    );
  }

  double get _totalBudget => _currentMonthBudget?.amount ?? 0.0;

  double get _totalSpent {
    return _expenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildMonthSelector(),
                  const SizedBox(height: 16),
                  _buildOverallBudgetCard(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addOrEditBudget,
        icon: const Icon(Icons.add),
        label: Text(
          _totalBudget > 0 ? 'Edit Budget' : 'Set Budget',
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedMonth = DateTime(
                    _selectedMonth.year,
                    _selectedMonth.month - 1,
                  );
                });
              },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(
              DateFormat('MMMM yyyy').format(_selectedMonth),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                final now = DateTime.now();
                final nextMonth = DateTime(
                  _selectedMonth.year,
                  _selectedMonth.month + 1,
                );
                if (nextMonth.isBefore(now) ||
                    (nextMonth.year == now.year &&
                        nextMonth.month == now.month)) {
                  setState(() {
                    _selectedMonth = nextMonth;
                  });
                }
              },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallBudgetCard() {
    final remaining = _totalBudget - _totalSpent;
    final percentage = _totalBudget > 0 ? (_totalSpent / _totalBudget) : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Budget',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${_totalBudget.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spent',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '₹${_totalSpent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Remaining',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      '₹${remaining.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: remaining < 0
                            ? AppConstants.errorColor
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: Colors.white30,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage > 0.9
                      ? AppConstants.errorColor
                      : percentage > 0.7
                          ? AppConstants.warningColor
                          : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(percentage * 100).toStringAsFixed(1)}% used',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addOrEditBudget() {
    final existingBudget = _currentMonthBudget;
    final amountController = TextEditingController(
      text: existingBudget?.amount == 0 ? '' : existingBudget?.amount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existingBudget == null || existingBudget.amount == 0
            ? 'Set Budget'
            : 'Edit Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 8),
            Text(
              'For ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (amountController.text.isEmpty) return;

              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: AppConstants.errorColor,
                  ),
                );
                return;
              }

              final budget = Budget(
                amount: amount,
                month: DateTime(_selectedMonth.year, _selectedMonth.month),
              );

              await _storage.saveBudget(budget);
              Navigator.pop(context);
              _loadData();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      existingBudget == null || existingBudget.amount == 0
                          ? 'Budget set successfully!'
                          : 'Budget updated successfully!',
                    ),
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
