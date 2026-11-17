import 'package:equatable/equatable.dart';

abstract class ContributionEvent extends Equatable {
  const ContributionEvent();

  @override
  List<Object?> get props => [];
}

class SubscribeContributions extends ContributionEvent {
  const SubscribeContributions();
}

class LoadContributionsRequested extends ContributionEvent {
  const LoadContributionsRequested();
}

class LoadTotalContributionsRequested extends ContributionEvent {
  const LoadTotalContributionsRequested();
}

class MakeContributionRequested extends ContributionEvent {
  final String groupId;
  final double amount;
  final String paymentMethod;

  const MakeContributionRequested({
    required this.groupId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [groupId, amount, paymentMethod];
}

class ContributionStatusFilterChanged extends ContributionEvent {
  final String status;

  const ContributionStatusFilterChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class ContributionPaymentMethodFilterChanged extends ContributionEvent {
  final String paymentMethod;

  const ContributionPaymentMethodFilterChanged(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class ContributionStartDateChanged extends ContributionEvent {
  final DateTime? date;

  const ContributionStartDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class ContributionEndDateChanged extends ContributionEvent {
  final DateTime? date;

  const ContributionEndDateChanged(this.date);

  @override
  List<Object?> get props => [date];
}

class ApplyContributionFilters extends ContributionEvent {
  const ApplyContributionFilters();
}

class ClearContributionFilters extends ContributionEvent {
  const ClearContributionFilters();
}

class ClearContributionError extends ContributionEvent {
  const ClearContributionError();
}
