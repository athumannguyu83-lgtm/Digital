import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:vicoba/presentation/pages/contribution_page.dart';
import 'package:vicoba/presentation/pages/shares_page.dart';
import 'package:vicoba/presentation/pages/users/loan_request_page.dart';
import 'package:vicoba/presentation/pages/users/loan_pending_page.dart';
import 'package:vicoba/presentation/pages/vicoba_group_page.dart';
import 'package:vicoba/presentation/pages/view_group_page.dart';
import 'package:vicoba/presentation/pages/profile_page.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/contribution/contribution_bloc.dart';
import '../../bloc/contribution/contribution_state.dart';
import '../../bloc/loan/loan_bloc.dart';
import '../../bloc/loan/loan_state.dart';
import '../../bloc/share/share_bloc.dart';
import '../../bloc/share/share_event.dart';
import '../../bloc/share/share_state.dart';
import '../../bloc/group/group_bloc.dart';
import '../../bloc/group/group_event.dart';
import '../../bloc/group/group_state.dart';
import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/loan_entity.dart';
import '../../../domain/entities/share_entity.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthBloc _authBloc = Get.find<AuthBloc>();
  final ContributionBloc _contributionBloc = Get.find<ContributionBloc>();
  final LoanBloc _loanBloc = Get.find<LoanBloc>();
  final ShareBloc _shareBloc = Get.find<ShareBloc>();
  final GroupBloc _groupBloc = Get.find<GroupBloc>();

  @override
  void initState() {
    super.initState();
    _shareBloc.add(const LoadMySharesRequested());
    _groupBloc.add(const LoadUserGroupsRequested());
  }

  double _fallbackSavings = 12450000;
  bool _isLoading = false;
  bool _isBalanceVisible = true;
  String? _selectedShareGroupId;

  double _currentSavings(double liveTotal) {
    if (liveTotal > 0) {
      return liveTotal;
    }
    return _fallbackSavings;
  }

  String _activeLoanSummary(List<LoanEntity> loans) {
    final active = loans.where((l) => l.status.toLowerCase() == 'approved').toList();
    if (active.isNotEmpty) {
      final total = active.fold<double>(0.0, (sum, item) => sum + item.amount);
      return "TZS ${total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} Active";
    }
    final pending = loans.where((l) => l.status.toLowerCase() == 'pending').toList();
    if (pending.isNotEmpty) {
      return "${pending.length} Loan Application Pending";
    }
    return "TZS 150,000 Remaining";
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _fallbackSavings += 50000;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    return "TZS ${amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}";
  }

  void _showLogoutDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.redAccent,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Sign Out",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to log out of your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Get.back(),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        _authBloc.add(const LogoutRequested());
                      },
                      child: const Text(
                        "Logout",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
      child: BlocListener<GroupBloc, GroupState>(
        bloc: _groupBloc,
        listenWhen: (previous, current) =>
            current.groups.isNotEmpty &&
            previous.groups != current.groups,
        listener: (context, state) {
          final targetId = _selectedShareGroupId != null &&
                  state.groups.any((g) => g.id == _selectedShareGroupId)
              ? _selectedShareGroupId!
              : state.groups.first.id;
          _selectedShareGroupId = targetId;
          _shareBloc.add(LoadShareCapitalRequested(targetId));
        },
        child: BlocListener<ShareBloc, ShareState>(
          bloc: _shareBloc,
          listener: (context, state) {
            if (state.successMessage != null &&
                state.successMessage!.isNotEmpty) {
              Get.snackbar(
                "Success",
                state.successMessage!,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF10B981),
                colorText: Colors.white,
              );
              if (Get.isBottomSheetOpen ?? false) Get.back();
            }
            if (state.errorMessage != null &&
                state.errorMessage!.isNotEmpty) {
              Get.snackbar(
                "Error",
                state.errorMessage!,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.redAccent,
                colorText: Colors.white,
              );
            }
          },
          child: _buildDashboard(context),
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    final user = _authBloc.state.currentUser;
    final userName = user?.name.trim().isNotEmpty == true
        ? user!.name.trim().split(' ').first
        : "Member";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildCustomAppBar(userName),
      body: RefreshIndicator(
        color: const Color(0xFF2563EB),
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<ContributionBloc, ContributionState>(
                bloc: _contributionBloc,
                builder: (context, contributionState) {
                  return _buildSavingsCard(contributionState.totalContributions);
                },
              ),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: "My Shares",
                subtitle: "Shareholdings & capital",
              ),
              const SizedBox(height: 14),
              _buildSharesSection(),
              const SizedBox(height: 24),
              _buildSectionHeader(
                title: "Quick Actions",
                subtitle: "Frequent services & requests",
              ),
              const SizedBox(height: 14),
              _buildQuickActionsGrid(),
              const SizedBox(height: 28),
              _buildSectionHeader(
                title: "Financial Overview",
                subtitle: "Your current standing & records",
              ),
              const SizedBox(height: 14),
              _buildOverviewTiles(),
              const SizedBox(height: 26),
              _buildHelpCard(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildCustomAppBar(String userName) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 70,
      title: Row(
        children: [
          Hero(
            tag: 'user_avatar',
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : "M",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hello, $userName 👋",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "Active Member",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          tooltip: "Refresh Data",
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Color(0xFF2563EB),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 19,
                    color: Color(0xFF334155),
                  ),
                ),
        ),
        IconButton(
          onPressed: () => Get.to(() => const ProfileScreen()),
          tooltip: "My Profile",
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              size: 19,
              color: Color(0xFF334155),
            ),
          ),
        ),
        IconButton(
          onPressed: _showLogoutDialog,
          tooltip: "Sign Out",
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFEE2E2)),
            ),
            child: const Icon(
              Icons.logout_rounded,
              size: 19,
              color: Color(0xFFEF4444),
            ),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard(double liveTotal) {
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
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative circle 1
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          // Background decorative circle 2
          Positioned(
            left: 20,
            bottom: -35,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
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
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Text(
                          "Total Group Savings",
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isBalanceVisible = !_isBalanceVisible;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isBalanceVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _isBalanceVisible ? "Hide" : "Show",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
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
                  _isBalanceVisible ? _formatCurrency(_currentSavings(liveTotal)) : "••••••••••",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF34D399),
                                size: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Status",
                                  style: TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 11,
                                  ),
                                ),
                                Text(
                                  "Good Standing",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 26,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.autorenew_rounded,
                                  color: Color(0xFF7DD3FC),
                                  size: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Cycle",
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      fontSize: 11,
                                    ),
                                  ),
                                  Text(
                                    "Weekly Share",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSharesSection() {
    return BlocBuilder<GroupBloc, GroupState>(
      bloc: _groupBloc,
      builder: (context, groupState) {
        final uniqueGroups = <String, GroupEntity>{};
        for (final g in groupState.groups) {
          uniqueGroups[g.id] = g;
        }
        final groups = uniqueGroups.values.toList();
        final currentGroup = groups.isEmpty
            ? null
            : (_selectedShareGroupId != null &&
                    uniqueGroups.containsKey(_selectedShareGroupId)
                ? uniqueGroups[_selectedShareGroupId]!
                : groups.first);

        return BlocBuilder<ShareBloc, ShareState>(
          bloc: _shareBloc,
          builder: (context, shareState) {
            final groupShares = currentGroup == null
                ? const <ShareEntity>[]
                : shareState.shares
                    .where((s) => s.groupId == currentGroup.id)
                    .toList();
            final totalShares =
                groupShares.fold<int>(0, (sum, s) => sum + s.quantity);
            final totalValue = groupShares.fold<double>(
              0.0,
              (sum, s) => sum + s.shareValue,
            );
            final groupCapital =
                shareState.shareCapitalForGroup(currentGroup?.id);
            final ownershipPct = groupCapital > 0
                ? ((totalValue / groupCapital) * 100).clamp(0.0, 100.0)
                : 0.0;
            final recentPurchases = groupShares.take(3).toList();

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (groups.length > 1 && currentGroup != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.groups_rounded,
                          size: 16,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentGroup.id,
                              isDense: true,
                              isExpanded: true,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                              items: groups
                                  .map(
                                    (g) => DropdownMenuItem<String>(
                                      value: g.id,
                                      child: Text(
                                        g.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (groupId) {
                                if (groupId == null) return;
                                setState(() {
                                  _selectedShareGroupId = groupId;
                                });
                                _shareBloc.add(
                                  LoadShareCapitalRequested(groupId),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _buildShareStat(
                          label: "Total Shares",
                          value:
                              "${shareState.isLoadingShares ? '…' : totalShares}",
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildShareStat(
                          label: "Share Value",
                          value: _formatCurrency(totalValue),
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE2E8F0),
                      ),
                      Expanded(
                        child: _buildShareStat(
                          label: "Share Capital",
                          value: shareState.isLoadingCapital &&
                                  groupCapital == 0
                              ? "…"
                              : _formatCurrency(groupCapital),
                        ),
                      ),
                    ],
                  ),
                  if (currentGroup != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Ownership Share",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          "${ownershipPct.toStringAsFixed(1)}% of group capital",
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (ownershipPct / 100).clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showBuySharesSheet(
                            initialGroupId: currentGroup?.id,
                          ),
                          icon: const Icon(Icons.add_chart_rounded, size: 18),
                          label: Text(
                            currentGroup == null
                                ? "Join a Group to Buy Shares"
                                : "Buy Shares",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      if (currentGroup != null) ...[
                        const SizedBox(width: 10),
                        OutlinedButton(
                          onPressed: () => Get.to(
                            () => SharesPage(initialGroupId: currentGroup.id),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF2563EB),
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "View All",
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (recentPurchases.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    for (final purchase in recentPurchases)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.confirmation_number_outlined,
                              size: 16,
                              color: Color(0xFF2563EB),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${purchase.quantity} share${purchase.quantity > 1 ? 's' : ''} • ${purchase.createdAt.day}/${purchase.createdAt.month}/${purchase.createdAt.year}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                            Text(
                              _formatCurrency(purchase.totalAmount),
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShareStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10.5,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showBuySharesSheet({String? initialGroupId}) {
    final uniqueGroups = <String, GroupEntity>{};
    for (final g in _groupBloc.state.groups) {
      uniqueGroups[g.id] = g;
    }
    final groups = uniqueGroups.values.toList();
    if (groups.isEmpty) {
      Get.snackbar(
        "No Groups",
        "Join or create a group before buying shares.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    const int maxQuantity = 1000;
    const List<int> quickQuantities = [1, 5, 10, 25, 50];

    String selectedGroupId =
        initialGroupId != null && uniqueGroups.containsKey(initialGroupId)
            ? initialGroupId
            : groups.first.id;
    int quantity = 1;
    final quantityController = TextEditingController(text: '1');

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedGroup = uniqueGroups[selectedGroupId] ?? groups.first;
          final unitPrice = selectedGroup.contributionAmount;
          final total = quantity * unitPrice;

          void setQuantity(int next) {
            final clamped = next.clamp(1, maxQuantity);
            setSheetState(() {
              quantity = clamped;
              quantityController.text = '$clamped';
              quantityController.selection = TextSelection.fromPosition(
                TextPosition(offset: quantityController.text.length),
              );
            });
          }

          return Container(
            padding: EdgeInsets.only(
              left: 22,
              right: 22,
              top: 22,
              bottom: MediaQuery.of(context).viewInsets.bottom + 22,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  "Buy Shares",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Group",
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
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  items: groups
                      .map(
                        (group) => DropdownMenuItem<String>(
                          value: group.id,
                          child: Text(
                            "${group.name} • ${_formatCurrency(group.contributionAmount)}/share",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (groupId) {
                    if (groupId == null) return;
                    setSheetState(() => selectedGroupId = groupId);
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
                      "Max $maxQuantity shares",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove_rounded,
                      onTap: quantity > 1
                          ? () => setQuantity(quantity - 1)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: quantityController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                          if (parsed > maxQuantity) {
                            setQuantity(maxQuantity);
                          } else if (parsed >= 1) {
                            setSheetState(() => quantity = parsed);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildQuantityButton(
                      icon: Icons.add_rounded,
                      onTap: quantity < maxQuantity
                          ? () => setQuantity(quantity + 1)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: quickQuantities.map((preset) {
                    final isSelected = quantity == preset;
                    return ChoiceChip(
                      label: Text("$preset"),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2563EB),
                      backgroundColor: const Color(0xFFF1F5F9),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color:
                            isSelected ? Colors.white : const Color(0xFF334155),
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
                      const Text(
                        "Total",
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                      Text(
                        _formatCurrency(total),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    ).whenComplete(quantityController.dispose);
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Icon(
          icon,
          color: onTap == null ? Colors.grey[400] : const Color(0xFF2563EB),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Row(
      children: [
        _buildActionCard(
          icon: Icons.add_card_rounded,
          label: "Contribute",
          caption: "Save now",
          color: const Color(0xFF2563EB),
          bgColor: const Color(0xFFEFF6FF),
          onTap: () => Get.to(() => const ContributionsScreen()),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          icon: Icons.payments_rounded,
          label: "Request Loan",
          caption: "Fast approval",
          color: const Color(0xFFD97706),
          bgColor: const Color(0xFFFEF3C7),
          onTap: () => Get.to(() => const LoanRequestPage()),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          icon: Icons.receipt_long_rounded,
          label: "My Loans",
          caption: "Check status",
          color: const Color(0xFF7C3AED),
          bgColor: const Color(0xFFF5F3FF),
          onTap: () => Get.to(() => const PendingLoanPage()),
        ),
        const SizedBox(width: 12),
        _buildActionCard(
          icon: Icons.groups_rounded,
          label: "Circle",
          caption: "Members",
          color: const Color(0xFF0D9488),
          bgColor: const Color(0xFFCCFBF1),
          onTap: () => Get.to(() => const ViewGroupPage()),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String caption,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTiles() {
    return Column(
      children: [
        _buildInteractiveTile(
          icon: Icons.verified_rounded,
          iconColor: const Color(0xFF10B981),
          iconBg: const Color(0xFFECFDF5),
          title: "Contribution Status",
          subtitle: "Up to date • No outstanding arrears",
          badge: "Active",
          badgeColor: const Color(0xFF10B981),
          onTap: () {
            Get.bottomSheet(
              Container(
                padding: const EdgeInsets.all(22),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF10B981),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Contribution Up to Date",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Great job! All your periodic contributions have been received and verified. Keep contributing to maintain high loan eligibility.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13.5),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        minimumSize: const Size(double.infinity, 46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.to(() => const ContributionsScreen());
                      },
                      child: const Text(
                        "View History",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        BlocBuilder<LoanBloc, LoanState>(
          bloc: _loanBloc,
          builder: (context, loanState) {
            return _buildInteractiveTile(
              icon: Icons.account_balance_wallet_rounded,
              iconColor: const Color(0xFFEF4444),
              iconBg: const Color(0xFFFEF2F2),
              title: "Active Loans",
              subtitle: _activeLoanSummary(loanState.userLoans),
              badge: "Loans",
              badgeColor: const Color(0xFFF59E0B),
              onTap: () => Get.to(() => const PendingLoanPage()),
            );
          },
        ),
        const SizedBox(height: 12),
        _buildInteractiveTile(
          icon: Icons.groups_3_rounded,
          iconColor: const Color(0xFF0284C7),
          iconBg: const Color(0xFFF0F9FF),
          title: "Circle Details & Members",
          subtitle: "Explore members, constitution & group meetings",
          badge: null,
          badgeColor: null,
          onTap: () => Get.to(() => const ViewGroupPage()),
        ),
        const SizedBox(height: 12),
        _buildInteractiveTile(
          icon: Icons.history_rounded,
          iconColor: const Color(0xFF8B5CF6),
          iconBg: const Color(0xFFF5F3FF),
          title: "Payment History",
          subtitle: "Review deposits, shares & transaction receipts",
          badge: null,
          badgeColor: null,
          onTap: () => Get.to(() => const ContributionsScreen()),
        ),
        const SizedBox(height: 12),
        _buildInteractiveTile(
          icon: Icons.group_add_rounded,
          iconColor: const Color(0xFF059669),
          iconBg: const Color(0xFFECFDF5),
          title: "Register New Group",
          subtitle: "Create or initialize an additional VICOBA group",
          badge: "New",
          badgeColor: const Color(0xFF059669),
          onTap: () => Get.to(() => const VicobaGroupPage()),
        ),
      ],
    );
  }

  Widget _buildInteractiveTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String? badge,
    required Color? badgeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (badge != null && badgeColor != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Need Assistance?",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Contact your group leader or chairperson for support.",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
