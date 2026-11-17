import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../../bloc/loan/loan_bloc.dart';
import '../../bloc/loan/loan_event.dart';
import '../../bloc/loan/loan_state.dart';
import '../../../domain/entities/loan_entity.dart';
import 'loan_request_page.dart';

class PendingLoanPage extends StatefulWidget {
  const PendingLoanPage({super.key});

  @override
  State<PendingLoanPage> createState() => _PendingLoanPageState();
}

class _PendingLoanPageState extends State<PendingLoanPage> {
  final LoanBloc _loanBloc = Get.find<LoanBloc>();
  String _selectedFilter = 'all';

  static const List<Map<String, String>> _filters = [
    {'key': 'all', 'label': 'All History'},
    {'key': 'paid', 'label': 'Paid'},
    {'key': 'rejected', 'label': 'Rejected'},
  ];

  @override
  void initState() {
    super.initState();
    _loanBloc.add(const LoadLoansRequested());
  }

  Future<void> _refreshLoans() async {
    _loanBloc.add(const LoadLoansRequested());
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year • $hour:$minute';
  }

  bool _isPaidLoan(LoanEntity loan) {
    final s = loan.status.toLowerCase();
    return s == 'paid' || s == 'repaid' || s == 'completed';
  }

  bool _isRejectedLoan(LoanEntity loan) {
    return loan.status.toLowerCase() == 'rejected';
  }

  bool _isHistoryLoan(LoanEntity loan) {
    return _isPaidLoan(loan) || _isRejectedLoan(loan);
  }

  List<LoanEntity> _sortedLoans(List<LoanEntity> loans) {
    final copy = List<LoanEntity>.from(loans);
    copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copy;
  }

  List<LoanEntity> _activeAppliedLoans(List<LoanEntity> loans) {
    return _sortedLoans(loans).where((loan) => !_isHistoryLoan(loan)).toList();
  }

  List<LoanEntity> _historyLoans(List<LoanEntity> loans) {
    return _sortedLoans(loans).where(_isHistoryLoan).toList();
  }

  List<LoanEntity> _filteredHistoryLoans(List<LoanEntity> loans) {
    final history = _historyLoans(loans);
    if (_selectedFilter == 'paid') {
      return history.where(_isPaidLoan).toList();
    }
    if (_selectedFilter == 'rejected') {
      return history.where(_isRejectedLoan).toList();
    }
    return history;
  }

  _StatusStyle _statusStyle(String rawStatus) {
    switch (rawStatus.toLowerCase()) {
      case 'paid':
      case 'repaid':
      case 'completed':
        return const _StatusStyle(
          label: 'Paid',
          description: 'Loan Fully Repaid',
          textColor: Color(0xFF0F766E),
          bgColor: Color(0xFFCCFBF1),
          borderColor: Color(0xFF99F6E4),
          accentColor: Color(0xFF14B8A6),
          icon: Icons.verified_rounded,
        );
      case 'approved':
        return const _StatusStyle(
          label: 'Approved',
          description: 'Disbursed / Active Loan',
          textColor: Color(0xFF047857),
          bgColor: Color(0xFFD1FAE5),
          borderColor: Color(0xFFA7F3D0),
          accentColor: Color(0xFF10B981),
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return const _StatusStyle(
          label: 'Rejected',
          description: 'Application Declined',
          textColor: Color(0xFFB91C1C),
          bgColor: Color(0xFFFEE2E2),
          borderColor: Color(0xFFFECACA),
          accentColor: Color(0xFFEF4444),
          icon: Icons.cancel_rounded,
        );
      case 'pending':
      default:
        return const _StatusStyle(
          label: 'Pending',
          description: 'Awaiting Committee Approval',
          textColor: Color(0xFFB45309),
          bgColor: Color(0xFFFEF3C7),
          borderColor: Color(0xFFFDE68A),
          accentColor: Color(0xFFF59E0B),
          icon: Icons.schedule_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "My Loans & History",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        actions: [
          IconButton(
            onPressed: _refreshLoans,
            tooltip: "Refresh Loans",
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.refresh_rounded,
                size: 18,
                color: Color(0xFF334155),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: TextButton.icon(
              onPressed: () => Get.to(() => const LoanRequestPage()),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFEFF6FF),
                foregroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 17),
              label: const Text(
                "Apply",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<LoanBloc, LoanState>(
        bloc: _loanBloc,
        builder: (context, state) {
          final allLoans = _sortedLoans(state.userLoans);
          final activeLoans = _activeAppliedLoans(state.userLoans);
          final historyLoans = _historyLoans(state.userLoans);
          final filteredHistory = _filteredHistoryLoans(state.userLoans);

          if (state.isLoading && allLoans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2563EB),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF2563EB),
            onRefresh: _refreshLoans,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Portfolio Summary Hero Card
                  _buildPortfolioHeroCard(allLoans),
                  const SizedBox(height: 24),

                  // 2. Active & Pending Applied Loans Section (shows amount, status, duration)
                  _buildSectionHeader(
                    title: "Applied Loans",
                    subtitle:
                        "Current loan applications showing amount, status, and duration",
                  ),
                  const SizedBox(height: 12),
                  if (activeLoans.isEmpty)
                    _buildNoActiveLoanCard()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeLoans.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildLatestLoanSpotlight(activeLoans[index]);
                      },
                    ),
                  const SizedBox(height: 28),

                  // 3. Loan History (ONLY Paid & Rejected loans)
                  _buildSectionHeader(
                    title: "Loan History",
                    subtitle:
                        "Past loans that have been paid or rejected",
                  ),
                  const SizedBox(height: 14),
                  _buildFilterBar(historyLoans),
                  const SizedBox(height: 16),

                  // 4. Loan History Cards or Empty State
                  if (filteredHistory.isEmpty)
                    _buildEmptyState(hasAnyHistoryLoans: historyLoans.isNotEmpty)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredHistory.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildLoanHistoryCard(
                          filteredHistory[index],
                          index: index,
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioHeroCard(List<LoanEntity> loans) {
    final totalApplied = loans.fold<double>(0.0, (sum, l) => sum + l.amount);
    final activeLoans =
        loans.where((l) => !_isHistoryLoan(l)).toList();
    final paidLoans = loans.where(_isPaidLoan).toList();
    final rejectedLoans = loans.where(_isRejectedLoan).toList();

    final activeTotal =
        activeLoans.fold<double>(0.0, (sum, l) => sum + l.amount);

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
            color: const Color(0xFF1E3A8A).withValues(alpha: 0.32),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
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
          Positioned(
            left: 15,
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
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          "Total Loans Applied",
                          style: TextStyle(
                            color: Color(0xFFE2E8F0),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Text(
                        "${loans.length} ${loans.length == 1 ? 'Record' : 'Records'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "TZS ${_formatAmount(totalApplied)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activeTotal > 0
                      ? "Active & pending loans: TZS ${_formatAmount(activeTotal)}"
                      : "Combined principal across your loan applications",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeroStat(
                        label: "Applied",
                        count: activeLoans.length.toString(),
                        dotColor: const Color(0xFFFBBF24),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      _buildHeroStat(
                        label: "Paid",
                        count: paidLoans.length.toString(),
                        dotColor: const Color(0xFF34D399),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                      _buildHeroStat(
                        label: "Rejected",
                        count: rejectedLoans.length.toString(),
                        dotColor: const Color(0xFFF87171),
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

  Widget _buildHeroStat({
    required String label,
    required String count,
    required Color dotColor,
  }) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
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
            fontSize: 17.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestLoanSpotlight(LoanEntity loan) {
    final style = _statusStyle(loan.status);
    final interestAmount = loan.amount * loan.interestRate;
    final totalRepayable = loan.amount + interestAmount;

    return InkWell(
      onTap: () => _showLoanDetailsSheet(loan),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: style.accentColor.withValues(alpha: 0.35),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Amount + Status Badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "APPLIED AMOUNT",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "TZS ${_formatAmount(loan.amount)}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(style),
              ],
            ),
            const SizedBox(height: 16),

            // Highlight pills: Duration, Total Repayment, Interest Rate
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildMetricColumn(
                      icon: Icons.timelapse_rounded,
                      iconColor: const Color(0xFF2563EB),
                      label: "Duration",
                      value: loan.duration.isNotEmpty
                          ? loan.duration
                          : "3 months",
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: _buildMetricColumn(
                        icon: Icons.payments_outlined,
                        iconColor: const Color(0xFF10B981),
                        label: "Total Repayable",
                        value: "TZS ${_formatAmount(totalRepayable)}",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Visual Status Timeline Stepper
            _buildStatusTimeline(loan.status),
            const SizedBox(height: 14),

            // Footer: Purpose & Date
            Row(
              children: [
                const Icon(
                  Icons.notes_rounded,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    loan.purpose.isNotEmpty
                        ? loan.purpose
                        : "Community Vicoba Loan",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(loan.createdAt),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(String rawStatus) {
    final status = rawStatus.toLowerCase();
    final isApproved = status == 'approved';
    final isRejected = status == 'rejected';

    final step3Color = isApproved
        ? const Color(0xFF10B981)
        : isRejected
            ? const Color(0xFFEF4444)
            : const Color(0xFFCBD5E1);

    final step3Label = isApproved
        ? "Approved"
        : isRejected
            ? "Declined"
            : "Decision";

    return Row(
      children: [
        _buildTimelineStep(
          label: "Submitted",
          isCompleted: true,
          color: const Color(0xFF10B981),
        ),
        Expanded(
          child: Container(
            height: 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        _buildTimelineStep(
          label: "In Review",
          isCompleted: true,
          color: isApproved || isRejected
              ? const Color(0xFF10B981)
              : const Color(0xFFF59E0B),
        ),
        Expanded(
          child: Container(
            height: 2.5,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isApproved || isRejected
                  ? step3Color
                  : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        _buildTimelineStep(
          label: step3Label,
          isCompleted: isApproved || isRejected,
          color: step3Color,
          isCross: isRejected,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String label,
    required bool isCompleted,
    required Color color,
    bool isCross = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: isCompleted ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCompleted ? color : const Color(0xFFCBD5E1),
              width: 1.8,
            ),
          ),
          child: isCompleted
              ? Icon(
                  isCross ? Icons.close_rounded : Icons.check_rounded,
                  size: 12,
                  color: Colors.white,
                )
              : null,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isCompleted ? FontWeight.w700 : FontWeight.w500,
            color: isCompleted
                ? const Color(0xFF0F172A)
                : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(List<LoanEntity> historyLoans) {
    int countFor(String key) {
      if (key == 'paid') return historyLoans.where(_isPaidLoan).length;
      if (key == 'rejected') return historyLoans.where(_isRejectedLoan).length;
      return historyLoans.length;
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _filters.map((filter) {
          final key = filter['key']!;
          final label = filter['label']!;
          final isSelected = _selectedFilter == key;
          final count = countFor(key);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _selectedFilter = key),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.22)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoanHistoryCard(LoanEntity loan, {required int index}) {
    final style = _statusStyle(loan.status);
    final totalRepayable = loan.amount + (loan.amount * loan.interestRate);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _showLoanDetailsSheet(loan),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Icon + Amount & Purpose + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: style.bgColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: style.borderColor),
                    ),
                    child: Icon(
                      style.icon,
                      color: style.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TZS ${_formatAmount(loan.amount)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          loan.purpose.isNotEmpty
                              ? loan.purpose
                              : "Community Loan Application",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(style),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 12),

              // Row 2: Duration, Interest/Total, and Date
              Row(
                children: [
                  // Duration chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 14,
                          color: Color(0xFF2563EB),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "Duration: ${loan.duration.isNotEmpty ? loan.duration : '3 months'}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Repayable chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      "Repay: TZS ${_formatAmount(totalRepayable)}",
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Applied on ${_formatDate(loan.createdAt)}",
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    style.description,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: style.textColor,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatusBadge(_StatusStyle style) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.textColor),
          const SizedBox(width: 5),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: style.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoActiveLoanCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.request_quote_outlined,
              color: Color(0xFF2563EB),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "No Active Loan Application",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Apply for a new loan to view its amount, duration, and live approval status here.",
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({required bool hasAnyHistoryLoans}) {
    final filterName = _selectedFilter == 'paid' ? 'paid' : 'rejected';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.history_rounded,
              size: 32,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasAnyHistoryLoans
                ? "No $filterName loans found"
                : "No Paid or Rejected Loan History",
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasAnyHistoryLoans
                ? "You don't have any $filterName loans in your history right now."
                : "Completed (paid) and rejected loan applications will appear in this history section.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: Color(0xFF64748B),
            ),
          ),
          if (hasAnyHistoryLoans) ...[
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => setState(() => _selectedFilter = 'all'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2563EB),
                side: const BorderSide(color: Color(0xFFBFDBFE)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Show All Paid & Rejected",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showLoanDetailsSheet(LoanEntity loan) {
    final style = _statusStyle(loan.status);
    final interestAmount = loan.amount * loan.interestRate;
    final totalRepayable = loan.amount + interestAmount;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
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
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Loan Application Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  _buildStatusBadge(style),
                ],
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
                    _buildDetailRow(
                      "Principal Amount",
                      "TZS ${_formatAmount(loan.amount)}",
                      isBold: true,
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      "Repayment Duration",
                      loan.duration.isNotEmpty ? loan.duration : "3 months",
                    ),
                    const SizedBox(height: 10),
                    _buildDetailRow(
                      "Interest (${(loan.interestRate * 100).toStringAsFixed(0)}%)",
                      "TZS ${_formatAmount(interestAmount)}",
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                    _buildDetailRow(
                      "Total Repayable",
                      "TZS ${_formatAmount(totalRepayable)}",
                      isBold: true,
                      valueColor: const Color(0xFF2563EB),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                "Loan Purpose",
                loan.purpose.isNotEmpty ? loan.purpose : "Community Loan",
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                "Date Applied",
                _formatDate(loan.createdAt),
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                "Current Status",
                "${style.label} — ${style.description}",
                valueColor: style.textColor,
              ),
              const SizedBox(height: 22),
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
                    "Close",
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

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: isBold ? 14.5 : 13.5,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F172A),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusStyle {
  final String label;
  final String description;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final Color accentColor;
  final IconData icon;

  const _StatusStyle({
    required this.label,
    required this.description,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
    required this.accentColor,
    required this.icon,
  });
}
