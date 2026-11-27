import 'package:equatable/equatable.dart';

import '../../../domain/entities/share_entity.dart';

class ShareState extends Equatable {
  final List<ShareEntity> shares;
  final Map<String, double> shareCapitalByGroup;
  final String? activeGroupId;
  final bool isLoadingShares;
  final bool isLoadingCapital;
  final bool isBuying;
  final String? errorMessage;
  final String? successMessage;

  const ShareState({
    this.shares = const [],
    this.shareCapitalByGroup = const {},
    this.activeGroupId,
    this.isLoadingShares = false,
    this.isLoadingCapital = false,
    this.isBuying = false,
    this.errorMessage,
    this.successMessage,
  });

  double get shareCapital =>
      activeGroupId == null ? 0.0 : (shareCapitalByGroup[activeGroupId] ?? 0.0);

  double shareCapitalForGroup(String? groupId) =>
      groupId == null ? 0.0 : (shareCapitalByGroup[groupId] ?? 0.0);

  int get totalShares =>
      shares.fold(0, (sum, share) => sum + share.quantity);

  double get totalShareValue =>
      shares.fold(0.0, (sum, share) => sum + share.shareValue);

  ShareState copyWith({
    List<ShareEntity>? shares,
    Map<String, double>? shareCapitalByGroup,
    String? activeGroupId,
    bool? isLoadingShares,
    bool? isLoadingCapital,
    bool? isBuying,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ShareState(
      shares: shares ?? this.shares,
      shareCapitalByGroup: shareCapitalByGroup ?? this.shareCapitalByGroup,
      activeGroupId: activeGroupId ?? this.activeGroupId,
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
        shareCapitalByGroup,
        activeGroupId,
        isLoadingShares,
        isLoadingCapital,
        isBuying,
        errorMessage,
        successMessage,
      ];
}
