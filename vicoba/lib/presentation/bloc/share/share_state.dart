import 'package:equatable/equatable.dart';

import '../../../domain/entities/share_entity.dart';

class ShareState extends Equatable {
  final List<ShareEntity> shares;
  final double shareCapital;
  final bool isLoadingShares;
  final bool isLoadingCapital;
  final bool isBuying;
  final String? errorMessage;
  final String? successMessage;

  const ShareState({
    this.shares = const [],
    this.shareCapital = 0.0,
    this.isLoadingShares = false,
    this.isLoadingCapital = false,
    this.isBuying = false,
    this.errorMessage,
    this.successMessage,
  });

  int get totalShares =>
      shares.fold(0, (sum, share) => sum + share.quantity);

  double get totalShareValue =>
      shares.fold(0.0, (sum, share) => sum + share.shareValue);

  ShareState copyWith({
    List<ShareEntity>? shares,
    double? shareCapital,
    bool? isLoadingShares,
    bool? isLoadingCapital,
    bool? isBuying,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ShareState(
      shares: shares ?? this.shares,
      shareCapital: shareCapital ?? this.shareCapital,
      isLoadingShares: isLoadingShares ?? this.isLoadingShares,
      isLoadingCapital: isLoadingCapital ?? this.isLoadingCapital,
      isBuying: isBuying ?? this.isBuying,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
        shares,
        shareCapital,
        isLoadingShares,
        isLoadingCapital,
        isBuying,
        errorMessage,
        successMessage,
      ];
}
