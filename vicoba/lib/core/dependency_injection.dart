import 'package:get/get.dart';
import '../data/datasources/firebase_auth_datasource.dart';
import '../data/datasources/firebase_loan_datasource.dart';
import '../data/datasources/firebase_contribution_datasource.dart';
import '../data/datasources/firebase_group_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/loan_repository_impl.dart';
import '../data/repositories/contribution_repository_impl.dart';
import '../data/repositories/group_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/loan_repository.dart';
import '../domain/repositories/contribution_repository.dart';
import '../domain/repositories/group_repository.dart';
import '../domain/usecases/register_user_usecase.dart';
import '../domain/usecases/login_user_usecase.dart';
import '../domain/usecases/get_user_role_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/update_profile_usecase.dart';
import '../domain/usecases/update_password_usecase.dart';
import '../domain/usecases/delete_account_usecase.dart';
import '../domain/usecases/upload_profile_photo_usecase.dart';
import '../domain/usecases/send_password_reset_email_usecase.dart';
import '../domain/usecases/get_profile_photo_usecase.dart';
import '../domain/usecases/submit_loan_usecase.dart';
import '../domain/usecases/get_user_loans_usecase.dart';
import '../domain/usecases/get_pending_loans_usecase.dart';
import '../domain/usecases/approve_loan_usecase.dart';
import '../domain/usecases/reject_loan_usecase.dart';
import '../domain/usecases/make_contribution_usecase.dart';
import '../domain/usecases/get_user_contributions_usecase.dart';
import '../domain/usecases/get_contributions_by_filter_usecase.dart';
import '../domain/usecases/get_total_contributions_usecase.dart';
import '../domain/usecases/get_user_groups_usecase.dart';
import '../domain/usecases/join_group_by_code_usecase.dart';
import '../domain/usecases/create_group_usecase.dart';
import '../domain/usecases/join_group_usecase.dart';
import '../domain/usecases/get_group_members_usecase.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/loan/loan_bloc.dart';
import '../presentation/bloc/contribution/contribution_bloc.dart';
import '../presentation/bloc/group/group_bloc.dart';

class DependencyInjection {
  static void init() {
    // Data Sources
    Get.lazyPut(() => FirebaseAuthDataSource());
    Get.lazyPut(() => FirebaseLoanDataSource());
    Get.lazyPut(() => FirebaseContributionDataSource());
    Get.lazyPut(() => FirebaseGroupDataSource());

    // Repositories
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<FirebaseAuthDataSource>()),
    );
    Get.lazyPut<LoanRepository>(
      () => LoanRepositoryImpl(Get.find<FirebaseLoanDataSource>()),
    );
    Get.lazyPut<ContributionRepository>(
      () => ContributionRepositoryImpl(
        Get.find<FirebaseContributionDataSource>(),
      ),
    );
    Get.lazyPut<GroupRepository>(
      () => GroupRepositoryImpl(Get.find<FirebaseGroupDataSource>()),
    );

    // Use Cases - Auth
    Get.lazyPut(() => RegisterUserUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => LoginUserUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => GetUserRoleUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => GetCurrentUserUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => UpdateProfileUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => UpdatePasswordUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => DeleteAccountUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => UploadProfilePhotoUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => SendPasswordResetEmailUseCase(Get.find<AuthRepository>()));
    Get.lazyPut(() => GetProfilePhotoUseCase(Get.find<AuthRepository>()));

    // Use Cases - Loan
    Get.lazyPut(() => SubmitLoanUseCase(Get.find<LoanRepository>()));
    Get.lazyPut(() => GetUserLoansUseCase(Get.find<LoanRepository>()));
    Get.lazyPut(() => GetPendingLoansUseCase(Get.find<LoanRepository>()));
    Get.lazyPut(() => ApproveLoanUseCase(Get.find<LoanRepository>()));
    Get.lazyPut(() => RejectLoanUseCase(Get.find<LoanRepository>()));

    // Use Cases - Contribution
    Get.lazyPut(
      () => MakeContributionUseCase(Get.find<ContributionRepository>()),
    );
    Get.lazyPut(
      () => GetUserContributionsUseCase(Get.find<ContributionRepository>()),
    );
    Get.lazyPut(
      () => GetContributionsByFilterUseCase(Get.find<ContributionRepository>()),
    );
    Get.lazyPut(
      () => GetTotalContributionsUseCase(Get.find<ContributionRepository>()),
    );

    // Use Cases - Group
    Get.lazyPut(() => GetUserGroupsUseCase(Get.find<GroupRepository>()));
    Get.lazyPut(() => JoinGroupByCodeUseCase(Get.find<GroupRepository>()));
    Get.lazyPut(() => CreateGroupUseCase(Get.find<GroupRepository>()));
    Get.lazyPut(() => JoinGroupUseCase(Get.find<GroupRepository>()));
    Get.lazyPut(() => GetGroupMembersUseCase(Get.find<GroupRepository>()));

    // BLoCs
    Get.lazyPut(
      () => AuthBloc(
        Get.find<LoginUserUseCase>(),
        Get.find<RegisterUserUseCase>(),
        Get.find<GetUserRoleUseCase>(),
        Get.find<LogoutUseCase>(),
        Get.find<GetCurrentUserUseCase>(),
        Get.find<UpdateProfileUseCase>(),
        Get.find<UpdatePasswordUseCase>(),
        Get.find<DeleteAccountUseCase>(),
        Get.find<UploadProfilePhotoUseCase>(),
        Get.find<SendPasswordResetEmailUseCase>(),
        Get.find<GetProfilePhotoUseCase>(),
      ),
    );
    Get.lazyPut(
      () => LoanBloc(
        Get.find<SubmitLoanUseCase>(),
        Get.find<GetUserLoansUseCase>(),
        Get.find<GetPendingLoansUseCase>(),
        Get.find<ApproveLoanUseCase>(),
        Get.find<RejectLoanUseCase>(),
      ),
    );
    Get.lazyPut(
      () => ContributionBloc(
        Get.find<MakeContributionUseCase>(),
        Get.find<GetUserContributionsUseCase>(),
        Get.find<GetContributionsByFilterUseCase>(),
        Get.find<GetTotalContributionsUseCase>(),
      ),
    );
    Get.lazyPut(
      () => GroupBloc(
        Get.find<GetUserGroupsUseCase>(),
        Get.find<CreateGroupUseCase>(),
        Get.find<JoinGroupByCodeUseCase>(),
        Get.find<JoinGroupUseCase>(),
        Get.find<GetGroupMembersUseCase>(),
      ),
    );
  }
}
