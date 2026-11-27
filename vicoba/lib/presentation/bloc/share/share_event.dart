import 'package:equatable/equatable.dart';

abstract class ShareEvent extends Equatable {
  const ShareEvent();

  @override
  List<Object?> get props => [];
}

class LoadMySharesRequested extends ShareEvent {
  const LoadMySharesRequested();
}

class LoadShareCapitalRequested extends ShareEvent {
  final String groupId;

  const LoadShareCapitalRequested(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class BuySharesRequested extends ShareEvent {
  final String groupId;
  final int quantity;
  final String paymentMethod;

  const BuySharesRequested({
    required this.groupId,
    required this.quantity,
    this.paymentMethod = 'M-Pesa',
  });

  @override
  List<Object?> get props => [groupId, quantity, paymentMethod];
}

class RedeemSharesRequested extends ShareEvent {
  final String groupId;
  final int quantity;
  final String paymentMethod;

  const RedeemSharesRequested({
    required this.groupId,
    required this.quantity,
    this.paymentMethod = 'M-Pesa',
  });

  @override
  List<Object?> get props => [groupId, quantity, paymentMethod];
}
