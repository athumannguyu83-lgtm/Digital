import 'package:equatable/equatable.dart';

import '../../../domain/entities/contribution_entity.dart';

enum ContributionStatus { initial, loading, success, failure }

enum ContributionOperation { none, load, contribute, filter }

class ContributionState extends Equatable {
  final ContributionStatus status;
  final ContributionOperation operation;
  final String errorMessage;
  final List<ContributionEntity> contributions;
  final double totalContributions;

  // Filter state
  final String selectedStatusFilter;
  final String selectedPaymentMethodFilter;
  final DateTime? selectedStartDate;
  final DateTime? selectedEndDate;

  const ContributionState({
    this.status = ContributionStatus.initial,
    this.operation = ContributionOperation.none,
    this.errorMessage = '',
    this.contributions = const [],
    this.totalContributions = 0.0,
    this.selectedStatusFilter = 'all',
    this.selectedPaymentMethodFilter = 'all',
    this.selectedStartDate,
    this.selectedEndDate,
  });

  bool get isLoading => status == ContributionStatus.loading;

  ContributionState copyWith({
    ContributionStatus? status,
    ContributionOperation? operation,
    String? errorMessage,
    List<ContributionEntity>? contributions,
    double? totalContributions,
    String? selectedStatusFilter,
    String? selectedPaymentMethodFilter,
    DateTime? selectedStartDate,
    DateTime? selectedEndDate,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return ContributionState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      errorMessage: errorMessage ?? this.errorMessage,
      contributions: contributions ?? this.contributions,
      totalContributions: totalContributions ?? this.totalContributions,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedPaymentMethodFilter:
          selectedPaymentMethodFilter ?? this.selectedPaymentMethodFilter,
      selectedStartDate: clearStartDate
          ? null
          : (selectedStartDate ?? this.selectedStartDate),
      selectedEndDate: clearEndDate
          ? null
          : (selectedEndDate ?? this.selectedEndDate),
    );
  }

  @override
  List<Object?> get props => [
    status,
    operation,
    errorMessage,
    contributions,
    totalContributions,
    selectedStatusFilter,
    selectedPaymentMethodFilter,
    selectedStartDate,
    selectedEndDate,
  ];
}
