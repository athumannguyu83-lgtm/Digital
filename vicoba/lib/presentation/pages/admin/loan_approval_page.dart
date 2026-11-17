import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../bloc/loan/loan_bloc.dart';
import '../../bloc/loan/loan_event.dart';
import '../../bloc/loan/loan_state.dart';
import '../../../domain/entities/loan_entity.dart';

class LoanApprovalPage extends StatelessWidget {
  const LoanApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoanBloc loanBloc = Get.find<LoanBloc>();

    return BlocConsumer<LoanBloc, LoanState>(
      bloc: loanBloc,
      listenWhen: (previous, current) =>
          current.status == LoanStatus.success ||
          current.status == LoanStatus.failure,
      listener: (context, state) {
        if (state.operation == LoanOperation.approve &&
            state.status == LoanStatus.success) {
          Get.snackbar(
            "Success",
            "Loan approved successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if (state.operation == LoanOperation.reject &&
            state.status == LoanStatus.success) {
          Get.snackbar(
            "Success",
            "Loan rejected successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else if ((state.operation == LoanOperation.approve ||
                state.operation == LoanOperation.reject) &&
            state.status == LoanStatus.failure) {
          Get.snackbar(
            "Error",
            state.errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Loan Approvals"),
            backgroundColor: Colors.blue[900],
            foregroundColor: Colors.white,
          ),
          body: state.pendingLoans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No pending loans",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.pendingLoans.length,
                  itemBuilder: (context, index) {
                    LoanEntity loan = state.pendingLoans[index];
                    return _buildLoanCard(loan, state, loanBloc);
                  },
                ),
        );
      },
    );
  }

  Widget _buildLoanCard(
    LoanEntity loan,
    LoanState state,
    LoanBloc bloc,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TZS ${loan.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D47A1),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Pending",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Purpose: ${loan.purpose}",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Duration: ${loan.duration}",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Interest Rate: ${(loan.interestRate * 100).toStringAsFixed(1)}%",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            bloc.add(ApproveLoanRequested(loan.id!));
                          },
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text("Approve"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () {
                            bloc.add(RejectLoanRequested(loan.id!));
                          },
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text("Reject"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
