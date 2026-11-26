import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/group_entity.dart';
import '../../../domain/usecases/create_group_usecase.dart';
import '../../../domain/usecases/get_user_groups_usecase.dart';
import '../../../domain/usecases/get_group_members_usecase.dart';
import '../../../domain/usecases/join_group_by_code_usecase.dart';
import '../../../domain/usecases/join_group_usecase.dart';
import 'group_event.dart';
import 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final GetUserGroupsUseCase _getUserGroupsUseCase;
  final CreateGroupUseCase _createGroupUseCase;
  final JoinGroupByCodeUseCase _joinGroupByCodeUseCase;
  final JoinGroupUseCase _joinGroupUseCase;
  final GetGroupMembersUseCase _getGroupMembersUseCase;

  GroupBloc(
    this._getUserGroupsUseCase,
    this._createGroupUseCase,
    this._joinGroupByCodeUseCase,
    this._joinGroupUseCase,
    this._getGroupMembersUseCase,
  ) : super(const GroupState()) {
    on<LoadUserGroupsRequested>(_onLoadUserGroupsRequested);
    on<CreateGroupRequested>(_onCreateGroupRequested);
    on<JoinGroupByCodeRequested>(_onJoinGroupByCodeRequested);
    on<JoinGroupRequested>(_onJoinGroupRequested);
    on<LoadGroupMembersRequested>(_onLoadGroupMembersRequested);
    on<ClearGroupError>(_onClearGroupError);

    add(const LoadUserGroupsRequested());
  }

  bool get _hasCurrentUser => FirebaseAuth.instance.currentUser != null;

  GroupState _mapGroups(List<GroupEntity> groups) {
    final isActionLoading = state.status == GroupStatus.loading;
    return state.copyWith(
      groups: groups,
      status: isActionLoading ? state.status : GroupStatus.initial,
      operation: isActionLoading ? state.operation : GroupOperation.none,
      errorMessage: '',
    );
  }

  Future<void> _onLoadUserGroupsRequested(
    LoadUserGroupsRequested event,
    Emitter<GroupState> emit,
  ) async {
    if (!_hasCurrentUser) return;
    await emit.forEach<List<GroupEntity>>(
      _getUserGroupsUseCase.execute(),
      onData: _mapGroups,
      onError: (error, _) => state.copyWith(
        status: GroupStatus.failure,
        operation: GroupOperation.load,
        errorMessage: error.toString(),
      ),
    );
  }

  Future<void> _onCreateGroupRequested(
    CreateGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GroupStatus.loading,
        operation: GroupOperation.create,
        errorMessage: '',
      ),
    );
    try {
      await _createGroupUseCase.execute(
        name: event.name,
        contributionAmount: event.contributionAmount,
        contributionFrequency: event.contributionFrequency,
      );
      emit(
        state.copyWith(
          status: GroupStatus.success,
          operation: GroupOperation.create,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GroupStatus.failure,
          operation: GroupOperation.create,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onJoinGroupByCodeRequested(
    JoinGroupByCodeRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GroupStatus.loading,
        operation: GroupOperation.join,
        errorMessage: '',
      ),
    );
    try {
      final group = await _joinGroupByCodeUseCase.execute(event.code);
      if (group == null) {
        emit(
          state.copyWith(
            status: GroupStatus.failure,
            operation: GroupOperation.join,
            errorMessage: 'No group found with that code.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: GroupStatus.success,
          operation: GroupOperation.join,
          joinedGroup: group,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GroupStatus.failure,
          operation: GroupOperation.join,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onJoinGroupRequested(
    JoinGroupRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GroupStatus.loading,
        operation: GroupOperation.join,
        errorMessage: '',
      ),
    );
    try {
      await _joinGroupUseCase.execute(event.groupId);
      emit(
        state.copyWith(
          status: GroupStatus.success,
          operation: GroupOperation.join,
          errorMessage: '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GroupStatus.failure,
          operation: GroupOperation.join,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadGroupMembersRequested(
    LoadGroupMembersRequested event,
    Emitter<GroupState> emit,
  ) async {
    emit(
      state.copyWith(
        status: GroupStatus.loading,
        operation: GroupOperation.loadMembers,
        membersGroupId: event.groupId,
        clearMembers: true,
      ),
    );
    try {
      final members = await _getGroupMembersUseCase.execute(event.groupId);
      emit(
        state.copyWith(
          status: GroupStatus.success,
          operation: GroupOperation.loadMembers,
          members: members,
          membersGroupId: event.groupId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: GroupStatus.failure,
          operation: GroupOperation.loadMembers,
          errorMessage: e.toString(),
          membersGroupId: event.groupId,
        ),
      );
    }
  }

  void _onClearGroupError(ClearGroupError event, Emitter<GroupState> emit) {
    emit(
      state.copyWith(
        status: GroupStatus.initial,
        operation: GroupOperation.none,
        errorMessage: '',
        clearJoinedGroup: true,
      ),
    );
  }
}
