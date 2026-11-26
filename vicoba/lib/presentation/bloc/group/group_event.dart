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

  const CreateGroupRequested({
    required this.name,
    required this.contributionAmount,
    required this.contributionFrequency,
  });

  @override
  List<Object?> get props => [name, contributionAmount, contributionFrequency];
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
