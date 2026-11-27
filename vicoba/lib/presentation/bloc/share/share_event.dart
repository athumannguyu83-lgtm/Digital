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

  const BuySharesRequested({
    required this.groupId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [groupId, quantity];
}
