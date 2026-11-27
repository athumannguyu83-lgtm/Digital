import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../../domain/entities/group_entity.dart';
import '../../domain/entities/share_entity.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';
import '../bloc/share/share_bloc.dart';
import '../bloc/share/share_event.dart';
import '../bloc/share/share_state.dart';

class SharesPage extends StatefulWidget {
  final String? initialGroupId;

  const SharesPage({super.key, this.initialGroupId});

  @override
  State<SharesPage> createState() => _SharesPageState();
}

class _SharesPageState extends State<SharesPage> {
  static const int _maxQuantity = 1000;
  static const List<int> _quickQuantities = [1, 5, 10, 25, 50];

  final ShareBloc _shareBloc = Get.find<ShareBloc>();
  final GroupBloc _groupBloc = Get.find<GroupBloc>();

  String? _selectedGroupId; // null means "All Groups"
  String _selectedDateFilter = 'all'; // all, 7d, 30d, custom
  DateTimeRange? _customDateRange;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.initialGroupId;
    _shareBloc.add(const LoadMySharesRequested());
    if (_groupBloc.state.groups.isEmpty) {
      _groupBloc.add(const LoadUserGroupsRequested());
    }
    if (_selectedGroupId != null) {
      _shareBloc.add(LoadShareCapitalRequested(_selectedGroupId!));
    } else if (_groupBloc.state.groups.isNotEmpty) {
      _shareBloc.add(LoadShareCapitalRequested(_groupBloc.state.groups.first.id));
    }
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
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$day ${months[dt.month - 1]} ${dt.year} • $hour:$min";
  }

  String _formatShortDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return "${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}";
  }

  List<ShareEntity> _filterShares(List<ShareEntity> shares) {
    final now = DateTime.now();
    return shares.where((share) {
      if (_selectedGroupId != null && share.groupId != _selectedGroupId) {
        return false;
      }
      switch (_selectedDateFilter) {
        case '7d':
          return share.createdAt.isAfter(now.subtract(const Duration(days: 7)));
        case '30d':
          return share.createdAt.isAfter(now.subtract(const Duration(days: 30)));
        case 'custom':
          if (_customDateRange == null) return true;
          final start = DateTime(
            _customDateRange!.start.year,
            _customDateRange!.start.month,
            _customDateRange!.start.day,
          );
          final end = DateTime(
            _customDateRange!.end.year,
            _customDateRange!.end.month,
            _customDateRange!.end.day,
            23,
            59,
            59,
          );
          return !share.createdAt.isBefore(start) &&
              !share.createdAt.isAfter(end);
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  Future<void> _pickCustomDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _customDateRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          ),
    );
    if (picked != null && mounted) {
      setState(() {
        _customDateRange = picked;
        _selectedDateFilter = 'custom';
      });
    }
  }

  void _showBuySharesSheet(List<GroupEntity> groups) {
    if (groups.isEmpty) {
      Get.snackbar(
        "No Groups",
        "Join or create a group before buying shares.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final groupMap = {for (final g in groups) g.id: g};
    String selectedGroupId =
        _selectedGroupId != null && groupMap.containsKey(_selectedGroupId)
            ? _selectedGroupId!
            : groups.first.id;
    int quantity = 1;
    final qtyController = TextEditingController(text: '1');

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedGroup = groupMap[selectedGroupId] ?? groups.first;
          final unitPrice = selectedGroup.contributionAmount;
          final total = quantity * unitPrice;

          void setQuantity(int next) {
            final clamped = next.clamp(1, _maxQuantity);
            setSheetState(() {
              quantity = clamped;
              qtyController.text = '$clamped';
              qtyController.selection = TextSelection.fromPosition(
                TextPosition(offset: qtyController.text.length),
              );
            });
          }

          return Container(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 18,
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
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Buy Shares",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    "Select Group",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    key: ValueKey(selectedGroupId),
                    initialValue: selectedGroupId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                    items: groups
                        .map(
                          (g) => DropdownMenuItem<String>(
                            value: g.id,
                            child: Text(
                              "${g.name} • ${_formatCurrency(g.contributionAmount)}/share",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      setSheetState(() => selectedGroupId = id);
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Quantity",
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        "Max $_maxQuantity shares / purchase",
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStepperButton(
                        icon: Icons.remove_rounded,
                        onTap: quantity > 1
                            ? () => setQuantity(quantity - 1)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: qtyController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.6,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            final parsed = int.tryParse(val);
                            if (parsed == null) return;
                            if (parsed > _maxQuantity) {
                              setQuantity(_maxQuantity);
                            } else if (parsed >= 1) {
                              setSheetState(() => quantity = parsed);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStepperButton(
                        icon: Icons.add_rounded,
                        onTap: quantity < _maxQuantity
                            ? () => setQuantity(quantity + 1)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _quickQuantities.map((preset) {
                      final isSelected = quantity == preset;
                      return ChoiceChip(
                        label: Text("$preset"),
                        selected: isSelected,
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF334155),
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        onSelected: (_) => setQuantity(preset),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "$quantity × ${_formatCurrency(unitPrice)}",
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        Text(
                          _formatCurrency(total),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  BlocBuilder<ShareBloc, ShareState>(
                    bloc: _shareBloc,
                    builder: (context, shareState) {
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: shareState.isBuying
                              ? null
                              : () {
                                  _shareBloc.add(
                                    BuySharesRequested(
                                      groupId: selectedGroup.id,
                                      quantity: quantity,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: shareState.isBuying
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Confirm Purchase",
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
    ).whenComplete(qtyController.dispose);
  }

  Widget _buildStepperButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  void _showShareReceiptModal(ShareEntity share, String groupName) {
    final ref = share.id != null && share.id!.isNotEmpty
        ? share.id!.substring(0, share.id!.length > 10 ? 10 : share.id!.length)
        : "N/A";

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_rounded,
                  color: Color(0xFF2563EB),
                  size: 30,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Share Purchase Receipt",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatDate(share.createdAt),
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow(
                      "Total Paid",
                      _formatCurrency(share.totalAmount),
                      isBold: true,
                      valueColor: const Color(0xFF2563EB),
                    ),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildReceiptRow("Group", groupName),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      "Shares Purchased",
                      "${share.quantity} share${share.quantity > 1 ? 's' : ''}",
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow(
                      "Price per Share",
                      _formatCurrency(share.unitPrice),
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptRow("Reference", ref.toUpperCase()),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Done",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildReceiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isBold ? 15 : 13.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ShareBloc, ShareState>(
      bloc: _shareBloc,
      listener: (context, state) {
        if (state.successMessage != null && state.successMessage!.isNotEmpty) {
          if (Get.isBottomSheetOpen ?? false) Get.back();
          Get.snackbar(
            "Success",
            state.successMessage!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF10B981),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        } else if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty) {
          Get.snackbar(
            "Error",
            state.errorMessage!,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFEF4444),
            colorText: Colors.white,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        }
      },
      child: BlocBuilder<GroupBloc, GroupState>(
        bloc: _groupBloc,
        builder: (context, groupState) {
          final uniqueGroups = <String, GroupEntity>{};
          for (final g in groupState.groups) {
            uniqueGroups[g.id] = g;
          }
          final groups = uniqueGroups.values.toList();

          return BlocBuilder<ShareBloc, ShareState>(
            bloc: _shareBloc,
            builder: (context, shareState) {
              final filtered = _filterShares(shareState.shares);
              final totalShares =
                  filtered.fold<int>(0, (sum, s) => sum + s.quantity);
              final totalValue =
                  filtered.fold<double>(0.0, (sum, s) => sum + s.shareValue);

              final activeGroupId = _selectedGroupId ??
                  (groups.isNotEmpty ? groups.first.id : null);
              final groupCapital =
                  shareState.shareCapitalForGroup(activeGroupId);

              // Calculate ownership % when a single group is active.
              final memberGroupValue = activeGroupId == null
                  ? 0.0
                  : shareState.shares
                      .where((s) => s.groupId == activeGroupId)
                      .fold<double>(0.0, (sum, s) => sum + s.shareValue);
              final ownershipPct = groupCapital > 0
                  ? ((memberGroupValue / groupCapital) * 100).clamp(0.0, 100.0)
                  : 0.0;

              return Scaffold(
                backgroundColor: const Color(0xFFF8FAFC),
                appBar: AppBar(
                  title: const Text(
                    "My Shares & History",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  foregroundColor: const Color(0xFF0F172A),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => _showBuySharesSheet(groups),
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  icon: const Icon(Icons.add_chart_rounded, size: 19),
                  label: const Text(
                    "Buy Shares",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroCard(
                        totalShares: totalShares,
                        totalValue: totalValue,
                        groupCapital: groupCapital,
                        ownershipPct: ownershipPct,
                        activeGroupName: activeGroupId != null
                            ? uniqueGroups[activeGroupId]?.name
                            : null,
                        showOwnership: _selectedGroupId != null ||
                            groups.length == 1,
                      ),
                      const SizedBox(height: 18),

                      // Group filter row
                      if (groups.isNotEmpty) ...[
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildGroupFilterChip(
                                label: "All Groups",
                                isSelected: _selectedGroupId == null,
                                onTap: () =>
                                    setState(() => _selectedGroupId = null),
                              ),
                              for (final group in groups)
                                _buildGroupFilterChip(
                                  label: group.name,
                                  isSelected: _selectedGroupId == group.id,
                                  onTap: () {
                                    setState(() => _selectedGroupId = group.id);
                                    _shareBloc.add(
                                      LoadShareCapitalRequested(group.id),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Date filter row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildDateChip('all', 'All Time'),
                            _buildDateChip('7d', 'Last 7 Days'),
                            _buildDateChip('30d', 'Last 30 Days'),
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                avatar: Icon(
                                  Icons.date_range_rounded,
                                  size: 16,
                                  color: _selectedDateFilter == 'custom'
                                      ? Colors.white
                                      : const Color(0xFF2563EB),
                                ),
                                label: Text(
                                  _selectedDateFilter == 'custom' &&
                                          _customDateRange != null
                                      ? "${_formatShortDate(_customDateRange!.start)} – ${_formatShortDate(_customDateRange!.end)}"
                                      : "Custom Range",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _selectedDateFilter == 'custom'
                                        ? Colors.white
                                        : const Color(0xFF334155),
                                  ),
                                ),
                                backgroundColor: _selectedDateFilter == 'custom'
                                    ? const Color(0xFF2563EB)
                                    : Colors.white,
                                side: BorderSide(
                                  color: _selectedDateFilter == 'custom'
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFFE2E8F0),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                onPressed: _pickCustomDateRange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        "Purchase History (${filtered.length})",
                        style: const TextStyle(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (shareState.isLoadingShares && filtered.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(36),
                            child: CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        )
                      else if (filtered.isEmpty)
                        _buildEmptyState(groups)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final share = filtered[index];
                            final groupName =
                                uniqueGroups[share.groupId]?.name ??
                                    "VICOBA Group";
                            return _buildShareHistoryTile(share, groupName);
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeroCard({
    required int totalShares,
    required double totalValue,
    required double groupCapital,
    required double ownershipPct,
    required String? activeGroupName,
    required bool showOwnership,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "MY SHARE PORTFOLIO",
                style: TextStyle(
                  color: Color(0xFFBFDBFE),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              if (showOwnership)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF34D399).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    "${ownershipPct.toStringAsFixed(1)}% Ownership",
                    style: const TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatCurrency(totalValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "$totalShares share${totalShares == 1 ? '' : 's'} owned"
            "${activeGroupName != null && showOwnership ? ' in $activeGroupName' : ''}",
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
          if (showOwnership) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: (ownershipPct / 100).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: 0.16),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Group Share Capital",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 12,
                  ),
                ),
                Text(
                  _formatCurrency(groupCapital),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGroupFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF0F172A),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: isSelected ? Colors.white : const Color(0xFF334155),
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _buildDateChip(String key, String label) {
    final isSelected = _selectedDateFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF475569),
        ),
        side: BorderSide(
          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onSelected: (_) => setState(() => _selectedDateFilter = key),
      ),
    );
  }

  Widget _buildShareHistoryTile(ShareEntity share, String groupName) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => _showShareReceiptModal(share, groupName),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Color(0xFF2563EB),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${share.quantity} Share${share.quantity > 1 ? 's' : ''} • $groupName",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "${_formatDate(share.createdAt)} • ${_formatCurrency(share.unitPrice)}/share",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(share.totalAmount),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Receipt",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(List<GroupEntity> groups) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFEFF6FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pie_chart_outline_rounded,
              size: 36,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "No Share Purchases Found",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Buy shares in your VICOBA group or clear the filters above to see your history.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
