import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/contribution/contribution_bloc.dart';
import '../bloc/contribution/contribution_event.dart';
import '../bloc/contribution/contribution_state.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_state.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/entities/contribution_entity.dart';

class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final ContributionBloc _contributionBloc = Get.find<ContributionBloc>();
  final GroupBloc _groupBloc = Get.find<GroupBloc>();
  final TextEditingController _amountController = TextEditingController();
  GroupEntity? _selectedGroup;
  String? _selectedPaymentMethod;
  double _lastContributionAmount = 0.0;

  final List<double> _presetAmounts = [10000, 25000, 50000, 100000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    return "TZS ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}";
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  void _showContributionBottomSheet() {
    _amountController.clear();
    final groups = _groupBloc.state.groups;
    _selectedGroup = groups.isNotEmpty ? groups.first : null;
    _selectedPaymentMethod = ContributionBloc.paymentMethods.isNotEmpty
        ? ContributionBloc.paymentMethods.first
        : 'M-Pesa';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 22,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Make Contribution",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Group Selection Field
                  const Text(
                    "Select Group",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  BlocBuilder<GroupBloc, GroupState>(
                    bloc: _groupBloc,
                    builder: (context, groupState) {
                      if (groupState.groups.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Text(
                            "You are not a member of any group yet. Join or create a group first.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        );
                      }
                      return DropdownButtonFormField<GroupEntity>(
                        initialValue: _selectedGroup,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: "Select your group",
                          hintStyle: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.groups_rounded,
                            color: Color(0xFF2563EB),
                            size: 20,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF2563EB),
                              width: 1.6,
                            ),
                          ),
                        ),
                        items: groupState.groups.map((group) {
                          return DropdownMenuItem<GroupEntity>(
                            value: group,
                            child: Text(
                              group.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                          );
                        }).toList(),
                        onChanged: (group) {
                          setState(() {
                            _selectedGroup = group;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Amount Field
                  const Text(
                    "Contribution Amount",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        margin: const EdgeInsets.only(right: 10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                        ),
                        child: const Text(
                          "TZS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF334155),
                            fontSize: 13,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                      hintText: "e.g. 50,000",
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14, fontWeight: FontWeight.normal),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick presets
                  Wrap(
                    spacing: 8,
                    children: _presetAmounts.map((amt) {
                      return ActionChip(
                        label: Text(
                          "${(amt / 1000).toStringAsFixed(0)}k",
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: const Color(0xFFF1F5F9),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        onPressed: () {
                          setSheetState(() {
                            _amountController.text = amt.toStringAsFixed(0);
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // Payment Method
                  const Text(
                    "Payment Method",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ContributionBloc.paymentMethods.map((method) {
                      final isSelected = _selectedPaymentMethod == method;
                      return InkWell(
                        onTap: () {
                          setSheetState(() {
                            _selectedPaymentMethod = method;
                          });
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                                color: isSelected ? const Color(0xFF2563EB) : Colors.grey[400],
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                method,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  BlocBuilder<ContributionBloc, ContributionState>(
                    bloc: _contributionBloc,
                    buildWhen: (previous, current) =>
                        previous.isLoading != current.isLoading,
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  if (_selectedGroup == null ||
                                      _amountController.text.trim().isEmpty ||
                                      _selectedPaymentMethod == null) {
                                    Get.snackbar(
                                      "Incomplete",
                                      "Please fill in all contribution details.",
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 12,
                                    );
                                    return;
                                  }

                                  final amount = double.tryParse(_amountController.text.trim());
                                  if (amount == null || amount <= 0) {
                                    Get.snackbar(
                                      "Invalid Amount",
                                      "Please enter a valid amount greater than zero.",
                                      backgroundColor: Colors.redAccent,
                                      colorText: Colors.white,
                                      snackPosition: SnackPosition.BOTTOM,
                                      margin: const EdgeInsets.all(16),
                                      borderRadius: 12,
                                    );
                                    return;
                                  }

                                  _lastContributionAmount = amount;
                                  _contributionBloc.add(
                                    MakeContributionRequested(
                                      groupId: _selectedGroup!.id,
                                      amount: amount,
                                      paymentMethod: _selectedPaymentMethod!,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            disabledBackgroundColor: const Color(0xFF93C5FD),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                                  "Confirm & Pay Contribution",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Filter Records",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _contributionBloc.add(const ClearContributionFilters());
                      Get.back();
                    },
                    child: const Text("Reset All"),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Status Filter
              const Text(
                "Status",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ContributionBloc, ContributionState>(
                bloc: _contributionBloc,
                buildWhen: (previous, current) =>
                    previous.selectedStatusFilter != current.selectedStatusFilter,
                builder: (context, state) {
                  return Wrap(
                    spacing: 8,
                    children: ['all', 'completed', 'pending', 'failed'].map((status) {
                      final isSelected = state.selectedStatusFilter == status;
                      return ChoiceChip(
                        label: Text(status == 'all' ? 'All' : _capitalizeFirst(status)),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (val) {
                          _contributionBloc.add(
                            ContributionStatusFilterChanged(status),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Payment Method Filter
              const Text(
                "Payment Method",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ContributionBloc, ContributionState>(
                bloc: _contributionBloc,
                buildWhen: (previous, current) =>
                    previous.selectedPaymentMethodFilter !=
                    current.selectedPaymentMethodFilter,
                builder: (context, state) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: ['all', ...ContributionBloc.paymentMethods].map((method) {
                      final isSelected = state.selectedPaymentMethodFilter == method;
                      return ChoiceChip(
                        label: Text(method == 'all' ? 'All Methods' : method),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF334155),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        onSelected: (val) {
                          _contributionBloc.add(
                            ContributionPaymentMethodFilterChanged(method),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Date Range
              const Text(
                "Date Range",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 8),
              BlocBuilder<ContributionBloc, ContributionState>(
                bloc: _contributionBloc,
                buildWhen: (previous, current) =>
                    previous.selectedStartDate != current.selectedStartDate ||
                    previous.selectedEndDate != current.selectedEndDate,
                builder: (context, state) {
                  return Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: Get.context!,
                              initialDate: state.selectedStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _contributionBloc.add(
                                ContributionStartDateChanged(date),
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(
                            state.selectedStartDate != null
                                ? _formatDate(state.selectedStartDate!)
                                : "Start Date",
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: Get.context!,
                              initialDate: state.selectedEndDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (date != null) {
                              _contributionBloc.add(
                                ContributionEndDateChanged(date),
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_today_rounded, size: 16),
                          label: Text(
                            state.selectedEndDate != null
                                ? _formatDate(state.selectedEndDate!)
                                : "End Date",
                            style: const TextStyle(fontSize: 12),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    _contributionBloc.add(const ApplyContributionFilters());
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReceiptModal(ContributionEntity item) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.receipt_rounded, color: Color(0xFF10B981), size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              "Contribution Receipt",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 4),
            Text(
              _formatDate(item.contributionDate),
              style: TextStyle(color: Colors.grey[500], fontSize: 12.5),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildReceiptRow("Amount", _formatCurrency(item.amount), isBold: true),
                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                  _buildReceiptRow("Status", _capitalizeFirst(item.status)),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Payment Method", item.paymentMethod),
                  const SizedBox(height: 8),
                  _buildReceiptRow("Group ID", item.groupId),
                  if (item.id != null) ...[
                    const SizedBox(height: 8),
                    _buildReceiptRow("Reference", item.id!.substring(0, item.id!.length > 10 ? 10 : item.id!.length)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13.5,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ContributionBloc, ContributionState>(
      bloc: _contributionBloc,
      listenWhen: (previous, current) =>
          current.status == ContributionStatus.success ||
          current.status == ContributionStatus.failure,
      listener: (context, state) {
        if (state.operation == ContributionOperation.contribute) {
          if (state.status == ContributionStatus.success) {
            Get.back();
            Get.snackbar(
              "Success",
              "Contribution of TZS ${_formatCurrency(_lastContributionAmount).replaceFirst("TZS ", "")} submitted!",
              backgroundColor: const Color(0xFF10B981),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
            );
          } else {
            Get.snackbar(
              "Error",
              state.errorMessage.isNotEmpty
                  ? state.errorMessage
                  : "Failed to record contribution.",
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
              borderRadius: 12,
            );
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Contributions & Savings",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color(0xFF0F172A),
              ),
            ),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                tooltip: "Filter Contributions",
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.filter_list_rounded, size: 18, color: Color(0xFF334155)),
                ),
                onPressed: _showFilterBottomSheet,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // 1. Total Contributions Card
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
                child: _buildTotalContributionsCard(state),
              ),

              // 2. Quick Horizontal Status Filter Bar
              _buildQuickStatusFilterBar(state),
              const SizedBox(height: 12),

              // 3. Contribution History List
              Expanded(
                child: state.contributions.isEmpty
                    ? _buildEmptyState()
                    : _buildContributionsList(state),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showContributionBottomSheet,
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text(
              "Make Contribution",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatusFilterBar(ContributionState state) {
    final filters = ['all', 'completed', 'pending', 'failed'];
    return SizedBox(
      height: 38,
      child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemCount: filters.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final status = filters[index];
              final isSelected = state.selectedStatusFilter == status;
              return InkWell(
                onTap: () {
                  _contributionBloc.add(
                    ContributionStatusFilterChanged(status),
                  );
                  _contributionBloc.add(const ApplyContributionFilters());
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      status == 'all' ? 'All Records' : _capitalizeFirst(status),
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _buildTotalContributionsCard(ContributionState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.savings_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Total Contributions",
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: _showContributionBottomSheet,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "Deposit",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _formatCurrency(state.totalContributions),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: Color(0xFF34D399), size: 12),
                          SizedBox(width: 4),
                          Text(
                            "Verified Balance",
                            style: TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "${state.contributions.length} recorded payments",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsList(ContributionState state) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 80),
      itemCount: state.contributions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final contribution = state.contributions[index];
        return _buildContributionCard(contribution);
      },
    );
  }

  Widget _buildContributionCard(ContributionEntity contribution) {
    IconData methodIcon;
    Color methodColor;

    switch (contribution.paymentMethod.toLowerCase()) {
      case 'm-pesa':
        methodIcon = Icons.phone_android_rounded;
        methodColor = const Color(0xFFEF4444);
        break;
      case 'tigo pesa':
        methodIcon = Icons.phone_android_rounded;
        methodColor = const Color(0xFF0284C7);
        break;
      case 'airtel money':
        methodIcon = Icons.phone_android_rounded;
        methodColor = const Color(0xFFDC2626);
        break;
      case 'bank transfer':
        methodIcon = Icons.account_balance_rounded;
        methodColor = const Color(0xFF4F46E5);
        break;
      default:
        methodIcon = Icons.payments_rounded;
        methodColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReceiptModal(contribution),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: methodColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(methodIcon, color: methodColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribution.paymentMethod,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${_formatDate(contribution.contributionDate)} • Group ${contribution.groupId}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "+ ${_formatCurrency(contribution.amount)}",
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildStatusChip(contribution.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg;
    Color fg;

    switch (status.toLowerCase()) {
      case 'completed':
        bg = const Color(0xFFECFDF5);
        fg = const Color(0xFF059669);
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case 'failed':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFDC2626);
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _capitalizeFirst(status),
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.bold,
          fontSize: 10.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Icon(
                Icons.savings_outlined,
                size: 54,
                color: Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No Contributions Found",
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Start contributing to your circle or adjust your filters above.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showContributionBottomSheet,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text("Make Contribution"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return "${text[0].toUpperCase()}${text.substring(1)}";
}
