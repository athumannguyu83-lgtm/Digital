import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/contribution_entity.dart';
import '../../../domain/usecases/get_contributions_by_filter_usecase.dart';
import '../../../domain/usecases/get_total_contributions_usecase.dart';
import '../../../domain/usecases/get_user_contributions_usecase.dart';
import '../../../domain/usecases/make_contribution_usecase.dart';
import 'contribution_event.dart';
import 'contribution_state.dart';

class ContributionBloc
    extends Bloc<ContributionEvent, ContributionState> {
  final MakeContributionUseCase _makeContributionUseCase;
  final GetUserContributionsUseCase _getUserContributionsUseCase;
  final GetContributionsByFilterUseCase _getContributionsByFilterUseCase;
  final GetTotalContributionsUseCase _getTotalContributionsUsecase;

  static const List<String> paymentMethods = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'Bank Transfer',
    'Cash',
  ];

  final StreamController<List<ContributionEntity>> _contributionsController =
      StreamController<List<ContributionEntity>>();
  StreamSubscription? _sourceSubscription;
  bool _filtersActive = false;

  ContributionBloc(
    this._makeContributionUseCase,
    this._getUserContributionsUseCase,
    this._getContributionsByFilterUseCase,
    this._getTotalContributionsUsecase,
  ) : super(const ContributionState()) {
    on<SubscribeContributions>(_onSubscribeContributions);
    on<LoadContributionsRequested>(_onLoadContributionsRequested);
    on<LoadTotalContributionsRequested>(_onLoadTotalContributionsRequested);
    on<MakeContributionRequested>(_onMakeContributionRequested);
    on<ContributionStatusFilterChanged>(_onStatusFilterChanged);
    on<ContributionPaymentMethodFilterChanged>(_onPaymentMethodFilterChanged);
    on<ContributionStartDateChanged>(_onStartDateChanged);
    on<ContributionEndDateChanged>(_onEndDateChanged);
    on<ApplyContributionFilters>(_onApplyFilters);
    on<ClearContributionFilters>(_onClearFilters);
    on<ClearContributionError>(_onClearError);

    add(const SubscribeContributions());
    add(const LoadContributionsRequested());
    add(const LoadTotalContributionsRequested());
  }

  bool get _hasCurrentUser => FirebaseAuth.instance.currentUser != null;

  Stream<List<ContributionEntity>> _currentContributionsStream() {
    if (_filtersActive) {
      return _getContributionsByFilterUseCase.execute(
        status: state.selectedStatusFilter == 'all'
            ? null
            : state.selectedStatusFilter,
        paymentMethod: state.selectedPaymentMethodFilter == 'all'
            ? null
            : state.selectedPaymentMethodFilter,
        startDate: state.selectedStartDate,
        endDate: state.selectedEndDate,
      );
    }
    return _getUserContributionsUseCase.execute();
  }

  void _setContributionsSource() {
    _sourceSubscription?.cancel();
    if (!_hasCurrentUser) return;
    _sourceSubscription = _currentContributionsStream().listen(
      _contributionsController.add,
      onError: _contributionsController.addError,
    );
  }

  ContributionState _mapContributions(List<ContributionEntity> contributions) {
    final isActionLoading = state.status == ContributionStatus.loading;
    return state.copyWith(
      contributions: contributions,
      status: isActionLoading
          ? state.status
          : ContributionStatus.initial,
      operation: isActionLoading
          ? state.operation
          : ContributionOperation.none,
      errorMessage: '',
    );
  }

  ContributionState _mapStreamError(Object error) {
    return state.copyWith(
      status: ContributionStatus.failure,
      operation: ContributionOperation.load,
      errorMessage: error.toString(),
    );
  }

  Future<void> _onSubscribeContributions(
    SubscribeContributions event,
    Emitter<ContributionState> emit,
  ) async {
    await emit.forEach<List<ContributionEntity>>(
      _contributionsController.stream,
      onData: _mapContributions,
      onError: (error, _) => _mapStreamError(error),
    );
  }

  void _resetFilters(Emitter<ContributionState> emit) {
    emit(
      state.copyWith(
        selectedStatusFilter: 'all',
        selectedPaymentMethodFilter: 'all',
        clearStartDate: true,
        clearEndDate: true,
      ),
    );
  }

  void _onLoadContributionsRequested(
    LoadContributionsRequested event,
    Emitter<ContributionState> emit,
  ) {
    _filtersActive = false;
    _resetFilters(emit);
    _setContributionsSource();
  }

  Future<void> _onLoadTotalContributionsRequested(
    LoadTotalContributionsRequested event,
    Emitter<ContributionState> emit,
  ) async {
    if (!_hasCurrentUser) return;

    try {
      final total = await _getTotalContributionsUsecase.execute();
      if (isClosed) return;
      emit(state.copyWith(totalContributions: total));
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ContributionStatus.failure,
          operation: ContributionOperation.load,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMakeContributionRequested(
    MakeContributionRequested event,
    Emitter<ContributionState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ContributionStatus.loading,
        operation: ContributionOperation.contribute,
        errorMessage: '',
      ),
    );
    try {
      await _makeContributionUseCase
          .execute(
            groupId: event.groupId,
            amount: event.amount,
            paymentMethod: event.paymentMethod,
          )
          .timeout(const Duration(seconds: 15));

      emit(
        state.copyWith(
          status: ContributionStatus.success,
          operation: ContributionOperation.contribute,
          errorMessage: '',
        ),
      );

      add(const LoadTotalContributionsRequested());
      _setContributionsSource();
    } on Exception catch (e) {
      final msg = e.toString();
      emit(
        state.copyWith(
          status: ContributionStatus.failure,
          operation: ContributionOperation.contribute,
          errorMessage: msg.contains('TimeoutException')
              ? "Request timed out. Please check your network connection."
              : msg.replaceFirst("Exception: ", ""),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ContributionStatus.failure,
          operation: ContributionOperation.contribute,
          errorMessage: e.toString().replaceFirst("Exception: ", ""),
        ),
      );
    }
  }

  void _onStatusFilterChanged(
    ContributionStatusFilterChanged event,
    Emitter<ContributionState> emit,
  ) {
    emit(state.copyWith(selectedStatusFilter: event.status));
  }

  void _onPaymentMethodFilterChanged(
    ContributionPaymentMethodFilterChanged event,
    Emitter<ContributionState> emit,
  ) {
    emit(state.copyWith(selectedPaymentMethodFilter: event.paymentMethod));
  }

  void _onStartDateChanged(
    ContributionStartDateChanged event,
    Emitter<ContributionState> emit,
  ) {
    emit(
      state.copyWith(
        selectedStartDate: event.date,
        clearStartDate: event.date == null,
      ),
    );
  }

  void _onEndDateChanged(
    ContributionEndDateChanged event,
    Emitter<ContributionState> emit,
  ) {
    emit(
      state.copyWith(
        selectedEndDate: event.date,
        clearEndDate: event.date == null,
      ),
    );
  }

  void _onApplyFilters(
    ApplyContributionFilters event,
    Emitter<ContributionState> emit,
  ) {
    _filtersActive = true;
    _setContributionsSource();
  }

  void _onClearFilters(
    ClearContributionFilters event,
    Emitter<ContributionState> emit,
  ) {
    _filtersActive = false;
    _resetFilters(emit);
    _setContributionsSource();
  }

  void _onClearError(
    ClearContributionError event,
    Emitter<ContributionState> emit,
  ) {
    emit(
      state.copyWith(
        status: ContributionStatus.initial,
        operation: ContributionOperation.none,
        errorMessage: '',
      ),
    );
  }

  @override
  Future<void> close() {
    _sourceSubscription?.cancel();
    _contributionsController.close();
    return super.close();
  }
}
