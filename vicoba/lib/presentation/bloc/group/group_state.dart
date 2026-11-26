import 'package:equatable/equatable.dart';

import '../../../domain/entities/group_entity.dart';
import '../../../domain/entities/group_member_entity.dart';

enum GroupStatus { initial, loading, success, failure }

enum GroupOperation { none, load, create, join, loadMembers }

class GroupState extends Equatable {
  final GroupStatus status;
  final GroupOperation operation;
  final String errorMessage;
  final List<GroupEntity> groups;
  final GroupEntity? joinedGroup;
  final List<GroupMemberEntity> members;
  final String? membersGroupId;

  const GroupState({
    this.status = GroupStatus.initial,
    this.operation = GroupOperation.none,
    this.errorMessage = '',
    this.groups = const [],
    this.joinedGroup,
    this.members = const [],
    this.membersGroupId,
  });

  bool get isLoading => status == GroupStatus.loading;

  GroupState copyWith({
    GroupStatus? status,
    GroupOperation? operation,
    String? errorMessage,
    List<GroupEntity>? groups,
    GroupEntity? joinedGroup,
    bool clearJoinedGroup = false,
    List<GroupMemberEntity>? members,
    String? membersGroupId,
    bool clearMembers = false,
  }) {
    return GroupState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      errorMessage: errorMessage ?? this.errorMessage,
      groups: groups ?? this.groups,
      joinedGroup: clearJoinedGroup
          ? null
          : (joinedGroup ?? this.joinedGroup),
      members: clearMembers ? const [] : (members ?? this.members),
      membersGroupId: membersGroupId ?? this.membersGroupId,
    );
  }

  @override
  List<Object?> get props => [
    status,
    operation,
    errorMessage,
    groups,
    joinedGroup,
    members,
    membersGroupId,
  ];
}
