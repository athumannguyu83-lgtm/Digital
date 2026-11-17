import 'package:flutter/material.dart';
class RepaymentScreen extends StatefulWidget {
  const RepaymentScreen({super.key});

  @override
  State<RepaymentScreen> createState() => _RepaymentScreenState();
}

class _RepaymentScreenState extends State<RepaymentScreen> {
  // Mock Loan Data
  double totalLoanAmount = 1000000;
  double paidAmount = 450000;

  // Mock History
  final List<Map<String, dynamic>> _repayments = [
    {"date": "Feb 01, 2026", "amount": 150000, "method": "M-Pesa"},
    {"date": "Jan 01, 2026", "amount": 150000, "method": "Bank Transfer"},
    {"date": "Dec 01, 2025", "amount": 150000, "method": "Cash"},
  ];

  @override
  Widget build(BuildContext context) {
    double progress = paidAmount / totalLoanAmount;
    double remainingBalance = totalLoanAmount - paidAmount;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Loan Repayment"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Balance Overview Card
          _buildBalanceCard(remainingBalance, progress),

          const SizedBox(height: 10),

          // 2. History Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Payment History",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text("View All")),
              ],
            ),
          ),

          // 3. Repayment List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _repayments.length,
              itemBuilder: (context, index) {
                final item = _repayments[index];
                return _buildHistoryTile(item);
              },
            ),
          ),
        ],
      ),

      // 4. Add Repayment Button
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBalanceCard(double remaining, double progress) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "Outstanding Balance",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 5),
          Text(
            "TZS ${remaining.toStringAsFixed(0)}",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            color: Colors.green,
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${(progress * 100).toStringAsFixed(0)}% Paid",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
              Text(
                "Total: TZS ${totalLoanAmount.toStringAsFixed(0)}",
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFE3F2FD),
          child: Icon(Icons.arrow_downward, color: Colors.blue),
        ),
        title: Text(
          "TZS ${item['amount']}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${item['date']} • ${item['method']}"),
        trailing: const Icon(Icons.receipt_long_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: () {
            
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: const Text(
            "Add Repayment",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
