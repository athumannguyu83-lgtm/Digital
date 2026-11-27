import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/buy_shares_usecase.dart';
import '../../../domain/usecases/get_my_shares_usecase.dart';
import '../../../domain/usecases/get_share_capital_usecase.dart';
import '../../../domain/usecases/redeem_shares_usecase.dart';
import 'share_event.dart';
import 'share_state.dart';

class _ShareCapitalUpdated extends ShareEvent {
  final String groupId;
  final double capital;

  const _ShareCapitalUpdated({required this.groupId, required this.capital});

  @override
  List<Object?> get props => [groupId, capital];
}

class _ShareCapitalFailed extends ShareEvent {
  final String message;

  const _ShareCapitalFailed(this.message);

  @override
  List<Object?> get props => [message];
}

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  static const List<String> paymentMethods = [
    'M-Pesa',
    'Tigo Pesa',
    'Airtel Money',
    'Bank Transfer',
    'Cash',
  ];

  final GetMySharesUseCase _getMySharesUseCase;
  final BuySharesUseCase _buySharesUseCase;
  final GetShareCapitalUseCase _getShareCapitalUseCase;
  final RedeemSharesUseCase? _redeemSharesUseCase;

  StreamSubscription<double>? _capitalSubscription;
  String? _watchedCapitalGroupId;

  ShareBloc({
    required GetMySharesUseCase getMySharesUseCase,
    required BuySharesUseCase buySharesUseCase,
    required GetShareCapitalUseCase getShareCapitalUseCase,
    RedeemSharesUseCase? redeemSharesUseCase,
  })  : _getMySharesUseCase = getMySharesUseCase,
        _buySharesUseCase = buySharesUseCase,
        _getShareCapitalUseCase = getShareCapitalUseCase,
        _redeemSharesUseCase = redeemSharesUseCase,
        super(const ShareState()) {
    on<LoadMySharesRequested>(_onLoadMyShares);
    on<BuySharesRequested>(_onBuyShares);
    on<RedeemSharesRequested>(_onRedeemShares);
    on<LoadShareCapitalRequested>(_onLoadShareCapital);
    on<_ShareCapitalUpdated>(_onShareCapitalUpdated);
    on<_ShareCapitalFailed>(_onShareCapitalFailed);
  }

  Future<void> _onLoadShareCapital(
    LoadShareCapitalRequested event,
    Emitter<ShareState> emit,
  ) async {
    if (_watchedCapitalGroupId == event.groupId &&
        _capitalSubscription != null) {
      emit(state.copyWith(activeGroupId: event.groupId));
      return;
    }

    await _capitalSubscription?.cancel();
    _watchedCapitalGroupId = event.groupId;

    emit(state.copyWith(
      activeGroupId: event.groupId,
      isLoadingCapital: true,
    ));

    _capitalSubscription = _getShareCapitalUseCase.watch(event.groupId).listen(
      (capital) {
        if (!isClosed) {
          add(_ShareCapitalUpdated(groupId: event.groupId, capital: capital));
        }
      },
      onError: (Object error) {
        if (!isClosed) {
          add(_ShareCapitalFailed(
            error.toString().replaceFirst('Exception: ', ''),
          ));
        }
      },
    );
  }

  void _onShareCapitalUpdated(
    _ShareCapitalUpdated event,
    Emitter<ShareState> emit,
  ) {
    final updated = Map<String, double>.from(state.shareCapitalByGroup)
      ..[event.groupId] = event.capital;
    emit(state.copyWith(
      shareCapitalByGroup: updated,
      isLoadingCapital: false,
    ));
  }

  void _onShareCapitalFailed(
    _ShareCapitalFailed event,
    Emitter<ShareState> emit,
  ) {
    emit(state.copyWith(
      isLoadingCapital: false,
      errorMessage: event.message,
    ));
  }

  Future<void> _onLoadMyShares(
    LoadMySharesRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(state.copyWith(isLoadingShares: true, clearMessages: true));
    await emit.forEach(
      _getMySharesUseCase.execute(),
      onData: (shares) => state.copyWith(
        shares: shares,
        isLoadingShares: false,
      ),
      onError: (error, _) => state.copyWith(
        isLoadingShares: false,
        errorMessage: error.toString().replaceFirst('Exception: ', ''),
      ),
    );
  }

  Future<void> _onBuyShares(
    BuySharesRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(state.copyWith(isBuying: true, clearMessages: true));
    try {
      await _buySharesUseCase.execute(
        groupId: event.groupId,
        quantity: event.quantity,
        paymentMethod: event.paymentMethod,
      );

      final updatedMap = Map<String, double>.from(state.shareCapitalByGroup);
      try {
        updatedMap[event.groupId] =
            await _getShareCapitalUseCase.execute(event.groupId);
      } catch (_) {}

      emit(state.copyWith(
        isBuying: false,
        shareCapitalByGroup: updatedMap,
        successMessage: "Shares purchased successfully via ${event.paymentMethod}",
      ));
    } catch (e) {
      emit(state.copyWith(
        isBuying: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
      ));
    }
  }

  Future<void> _onRedeemShares(
    RedeemSharesRequested event,
    Emitter<ShareState> emit,
  ) async {
    if (_redeemSharesUseCase == null) {
      emit(state.copyWith(errorMessage: "Share redemption is not configured."));
      return;
    }

    emit(state.copyWith(isBuying: true, clearMessages: true));
    try {
      await _redeemSharesUseCase.execute(
        groupId: event.groupId,
        quantity: event.quantity,
        paymentMethod: event.paymentMethod,
      );

      final updatedMap = Map<String, double>.from(state.shareCapitalByGroup);
      try {
        updatedMap[event.groupId] =
            await _getShareCapitalUseCase.execute(event.groupId);
      } catch (_) {}

      emit(state.copyWith(
        isBuying: false,
        shareCapitalByGroup: updatedMap,
        successMessage:
            "Redeemed ${event.quantity} share${event.quantity > 1 ? 's' : ''} via ${event.paymentMethod}",
      ));
    } catch (e) {
      emit(state.copyWith(
        isBuying: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
      ));
    }
  }

  @override
  Future<void> close() async {
    await _capitalSubscription?.cancel();
    return super.close();
  }
}
