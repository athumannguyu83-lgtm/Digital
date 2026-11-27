import 'package:equatable/equatable.dart';

abstract class GroupEvent extends Equatable {
  const GroupEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserGroupsRequested extends GroupEvent {
  const LoadUserGroupsRequested();
}

class CreateGroupRequested extends GroupEvent {
  final String name;
  final double contributionAmount;
  final String contributionFrequency;
  final double? sharePrice;
  final int maxSharesPerPurchase;
  final double loanMultiplier;

  const CreateGroupRequested({
    required this.name,
    required this.contributionAmount,
    required this.contributionFrequency,
    this.sharePrice,
    this.maxSharesPerPurchase = 1000,
    this.loanMultiplier = 3.0,
  });

  @override
  List<Object?> get props => [
        name,
        contributionAmount,
        contributionFrequency,
        sharePrice,
        maxSharesPerPurchase,
        loanMultiplier,
      ];
}

class JoinGroupByCodeRequested extends GroupEvent {
  final String code;

  const JoinGroupByCodeRequested(this.code);

  @override
  List<Object?> get props => [code];
}

class JoinGroupRequested extends GroupEvent {
  final String groupId;

  const JoinGroupRequested(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class LoadGroupMembersRequested extends GroupEvent {
  final String groupId;

  const LoadGroupMembersRequested(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class ClearGroupError extends GroupEvent {
  const ClearGroupError();
}
