import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/buy_shares_usecase.dart';
import '../../../domain/usecases/get_my_shares_usecase.dart';
import '../../../domain/usecases/get_share_capital_usecase.dart';
import 'share_event.dart';
import 'share_state.dart';

class ShareBloc extends Bloc<ShareEvent, ShareState> {
  final GetMySharesUseCase _getMySharesUseCase;
  final BuySharesUseCase _buySharesUseCase;
  final GetShareCapitalUseCase _getShareCapitalUseCase;

  ShareBloc({
    required GetMySharesUseCase getMySharesUseCase,
    required BuySharesUseCase buySharesUseCase,
    required GetShareCapitalUseCase getShareCapitalUseCase,
  })  : _getMySharesUseCase = getMySharesUseCase,
        _buySharesUseCase = buySharesUseCase,
        _getShareCapitalUseCase = getShareCapitalUseCase,
        super(const ShareState()) {
    on<LoadMySharesRequested>(_onLoadMyShares);
    on<BuySharesRequested>(_onBuyShares);
    on<LoadShareCapitalRequested>(_onLoadShareCapital);
  }

  Future<void> _onLoadShareCapital(
    LoadShareCapitalRequested event,
    Emitter<ShareState> emit,
  ) async {
    emit(state.copyWith(isLoadingCapital: true));
    try {
      final capital = await _getShareCapitalUseCase.execute(event.groupId);
      emit(state.copyWith(
        shareCapital: capital,
        isLoadingCapital: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoadingCapital: false));
    }
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
        errorMessage: "Failed to load shares",
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
      );

      // Refresh share capital for the group.
      double capital = state.shareCapital;
      try {
        capital = await _getShareCapitalUseCase.execute(event.groupId);
      } catch (_) {}

      emit(state.copyWith(
        isBuying: false,
        shareCapital: capital,
        successMessage: "Shares purchased successfully",
      ));
    } catch (e) {
      emit(state.copyWith(
        isBuying: false,
        errorMessage: e.toString().replaceFirst("Exception: ", ""),
      ));
    }
  }
}
