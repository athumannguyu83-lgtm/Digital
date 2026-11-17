import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import 'loan_approval_page.dart';
import '../profile_page.dart';

class AdminDashboard extends StatelessWidget {
  AdminDashboard({super.key});

  final AuthBloc _authBloc = Get.find<AuthBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) =>
          current.status == AuthStatus.success ||
          current.status == AuthStatus.failure,
      listener: (context, state) {
        if (state.operation == AuthOperation.logout &&
            state.status == AuthStatus.success) {
          Get.offAllNamed('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Admin Dashboard"),
          backgroundColor: Colors.blue[900],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Get.snackbar(
                  "Refresh",
                  "Data refreshed successfully",
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Get.to(() => const ProfileScreen());
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _authBloc.add(const LogoutRequested());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildDashboardCard(
                Icons.approval,
                "Loan Approvals",
                Colors.orange,
                () {
                  Get.to(() => const LoanApprovalPage());
                },
              ),
              _buildDashboardCard(
                Icons.people,
                "Manage Users",
                Colors.blue,
                () {
                  Get.snackbar(
                    "Coming Soon",
                    "User management feature will be available soon",
                    backgroundColor: Colors.grey,
                    colorText: Colors.white,
                  );
                },
              ),
              _buildDashboardCard(
                Icons.analytics,
                "Analytics",
                Colors.green,
                () {
                  Get.snackbar(
                    "Coming Soon",
                    "Analytics feature will be available soon",
                    backgroundColor: Colors.grey,
                    colorText: Colors.white,
                  );
                },
              ),
              _buildDashboardCard(
                Icons.settings,
                "Settings",
                Colors.purple,
                () {
                  Get.snackbar(
                    "Coming Soon",
                    "Settings feature will be available soon",
                    backgroundColor: Colors.grey,
                    colorText: Colors.white,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
