import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';

class VicobaGroupPage extends StatefulWidget {
  const VicobaGroupPage({super.key});

  @override
  State<VicobaGroupPage> createState() => _VicobaGroupPageState();
}

class _VicobaGroupPageState extends State<VicobaGroupPage> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController contributionAmountController =
      TextEditingController();
  String contributionFrequency = "Weekly";

  final GroupBloc _groupBloc = Get.find<GroupBloc>();

  void createGroup() {
    if (groupNameController.text.trim().isEmpty ||
        contributionAmountController.text.trim().isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in all fields",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(contributionAmountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar(
        "Error",
        "Please enter a valid contribution amount",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    _groupBloc.add(
      CreateGroupRequested(
        name: groupNameController.text.trim(),
        contributionAmount: amount,
        contributionFrequency: contributionFrequency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      bloc: _groupBloc,
      listenWhen: (previous, current) =>
          current.status == GroupStatus.success ||
          current.status == GroupStatus.failure,
      listener: (context, state) {
        if (state.operation == GroupOperation.create) {
          if (state.status == GroupStatus.success) {
            groupNameController.clear();
            contributionAmountController.clear();

            Get.snackbar(
              "Success",
              "Group created successfully",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );

            Get.toNamed('/member-dashboard');
          } else {
            Get.snackbar(
              "Error",
              state.errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.blue[800],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  "Vicoba Group",
                  style: TextStyle(fontSize: 18),
                ),
                background: Container(color: Colors.blue[900]),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeaderSection(),
                    const SizedBox(height: 20),
                    _buildFormCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Start a New Journey",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        Text(
          "Set up your group rules and begin saving together.",
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Group Name
          TextFormField(
            controller: groupNameController,
            decoration: InputDecoration(
              labelText: 'Group Name',
              prefixIcon: Icon(Icons.group_work, color: Colors.blue),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Contribution Amount
          TextFormField(
            controller: contributionAmountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Contribution Amount',
              prefixIcon: Icon(Icons.payments, color: Colors.green),
              suffixText: "TZS",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Dropdown
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              labelText: "Contribution Frequency",
              prefixIcon: Icon(Icons.calendar_month, color: Colors.orange),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: ["Weekly", "Monthly"].map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              setState(() {
                contributionFrequency = value!;
              });
            },
          ),
          const SizedBox(height: 30),

          // Styled Button
          BlocBuilder<GroupBloc, GroupState>(
            bloc: _groupBloc,
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create Group',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
