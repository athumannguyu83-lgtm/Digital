# Clean Architecture Implementation for Vicoba App

## Overview
This document describes the clean architecture implementation for the Vicoba Flutter application. The app has been refactored from a monolithic structure to a clean, layered architecture following SOLID principles.

## Architecture Layers

### 1. Domain Layer (`lib/domain/`)
**Purpose**: Contains business logic and is independent of any external dependencies.

#### Entities (`lib/domain/entities/`)
- `user_entity.dart`: Core user business object
- `loan_entity.dart`: Core loan business object
- These are pure Dart classes with no dependencies on frameworks or external libraries

#### Repositories (`lib/domain/repositories/`)
- `auth_repository.dart`: Abstract interface for authentication operations
- `loan_repository.dart`: Abstract interface for loan operations
- Define contracts that the data layer must implement

#### Use Cases (`lib/domain/usecases/`)
- `register_user_usecase.dart`: User registration business logic
- `login_user_usecase.dart`: User login business logic
- `get_user_role_usecase.dart`: Get user role business logic
- `logout_usecase.dart`: Logout business logic
- `submit_loan_usecase.dart`: Loan submission business logic
- `get_user_loans_usecase.dart`: Get user loans business logic
- `get_pending_loans_usecase.dart`: Get pending loans for admin
- `approve_loan_usecase.dart`: Loan approval business logic
- `reject_loan_usecase.dart`: Loan rejection business logic
- Each use case represents a single business operation

### 2. Data Layer (`lib/data/`)
**Purpose**: Handles data management and external service integration.

#### Data Sources (`lib/data/datasources/`)
- `firebase_auth_datasource.dart`: Firebase authentication implementation
- `firebase_loan_datasource.dart`: Firebase Firestore loan data implementation
- These classes directly interact with Firebase services

#### Models (`lib/data/models/`)
- `user_model.dart`: Data transfer object for user data
- `loan_model.dart`: Data transfer object for loan data
- Include methods to convert between Firebase data and domain entities
- `toMap()`: Convert to Firebase-compatible format
- `fromMap()`: Create from Firebase data
- `toEntity()`: Convert to domain entity

#### Repositories (`lib/data/repositories/`)
- `auth_repository_impl.dart`: Concrete implementation of AuthRepository
- `loan_repository_impl.dart`: Concrete implementation of LoanRepository
- Bridge between data sources and domain layer

### 3. Presentation Layer (`lib/presentation/`)
**Purpose**: Handles UI and user interaction.

#### BLoCs (`lib/presentation/bloc/`)
- `auth/`: `AuthBloc` with `auth_event.dart` / `auth_state.dart` — manages authentication and profile state
- `loan/`: `LoanBloc` with `loan_event.dart` / `loan_state.dart` — manages loan requests and approvals
- `contribution/`: `ContributionBloc` with `contribution_event.dart` / `contribution_state.dart` — manages contributions, totals, and filters
- Built with `flutter_bloc`; each feature folder contains the bloc, events, and states
- Communicate with use cases from the domain layer
- Pages dispatch events (`bloc.add(...)`) and react via `BlocBuilder`/`BlocListener`

#### Pages (`lib/presentation/pages/`)
- `login_page.dart`: Login screen
- `signup_page.dart`: Registration screen
- `admin/`: Admin-specific pages
  - `admin_dashboard_page.dart`: Admin dashboard
- `users/`: User-specific pages
  - `member_dashboard_page.dart`: Member dashboard
  - `loan_request_page.dart`: Loan request form
  - `loan_pending_page.dart`: Pending loans view
- Other pages for contributions, groups, profiles, etc.

#### Widgets (`lib/presentation/widgets/`)
- Reusable UI components (to be added as needed)

### 4. Core Layer (`lib/core/`)
**Purpose**: Cross-cutting concerns and dependency injection.

#### Dependency Injection (`lib/core/dependency_injection.dart`)
- Uses GetX (`Get.lazyPut`) for dependency injection of data sources, repositories, use cases, and BLoCs
- Initializes all dependencies in the correct order
- Ensures single instances of repositories, use cases, and BLoCs
- Wiring between layers

## Dependency Flow

```
Presentation Layer (Controllers)
    ↓
Domain Layer (Use Cases)
    ↓
Domain Layer (Repository Interfaces)
    ↓
Data Layer (Repository Implementations)
    ↓
Data Layer (Data Sources)
    ↓
External Services (Firebase)
```

## Key Benefits

1. **Separation of Concerns**: Each layer has a specific responsibility
2. **Testability**: Business logic can be tested without UI or external dependencies
3. **Maintainability**: Changes in one layer don't affect others
4. **Scalability**: Easy to add new features or change implementations
5. **Reusability**: Use cases and repositories can be reused across different UI components

## Migration Notes

### What Changed
- **Old Structure**: Flat structure with mixed concerns
  - `lib/models/` (now in `lib/data/models/`)
  - `lib/services/` (split into data sources and repositories)
  - `lib/admin/`, `lib/users/` (now in `lib/presentation/pages/`)

- **New Structure**: Layered clean architecture
  - Clear separation between business logic, data management, and UI
  - Repository pattern for data access
  - Use case pattern for business operations
  - Dependency injection for loose coupling

### Compatibility
- Existing Firebase integration maintained
- BLoC (flutter_bloc) state management replaces GetX controllers
- GetX retained for navigation (`Get.to`, `Get.snackbar`, `Get.dialog`) and dependency injection (`Get.lazyPut`)
- UI components updated to dispatch bloc events and rebuild via `BlocBuilder`/`BlocListener`
- Firebase configuration unchanged

## Future Enhancements

1. **Add Error Handling**: Implement comprehensive error handling across layers
2. **Add Logging**: Add logging for debugging and monitoring
3. **Add Caching**: Implement local caching for offline support
4. **Add Testing**: Write unit tests for use cases and repositories
5. **Add Validation**: Implement input validation at the domain layer
6. **Add Widgets**: Create reusable widgets in the presentation layer

## Usage Example

### Login Flow
1. User enters credentials in `LoginPage`
2. `LoginRequested` event is dispatched to `AuthBloc`
3. `LoginUserUseCase.execute()` processes the business logic
4. `AuthRepository.login()` handles data operations
5. `FirebaseAuthDataSource` interacts with Firebase
6. `AuthBloc` emits `AuthState`; `BlocListener` fetches the user role and navigates

### Loan Request Flow
1. User fills loan form in `LoanRequestPage`
2. `SubmitLoanRequested` event is dispatched to `LoanBloc`
3. `SubmitLoanUseCase.execute()` validates and processes
4. `LoanRepository.submitLoan()` saves to database
5. `FirebaseLoanDataSource` writes to Firestore
6. `LoanBloc` emits `LoanState`; `BlocListener` shows success/error feedback

## File Structure

```
lib/
├── core/
│   └── dependency_injection.dart
├── data/
│   ├── datasources/
│   │   ├── firebase_auth_datasource.dart
│   │   └── firebase_loan_datasource.dart
│   ├── models/
│   │   ├── loan_model.dart
│   │   └── user_model.dart
│   └── repositories/
│       ├── auth_repository_impl.dart
│       └── loan_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── loan_entity.dart
│   │   └── user_entity.dart
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   └── loan_repository.dart
│   └── usecases/
│       ├── approve_loan_usecase.dart
│       ├── get_pending_loans_usecase.dart
│       ├── get_user_loans_usecase.dart
│       ├── get_user_role_usecase.dart
│       ├── login_user_usecase.dart
│       ├── logout_usecase.dart
│       ├── reject_loan_usecase.dart
│       ├── register_user_usecase.dart
│       └── submit_loan_usecase.dart
├── firebase_options.dart
├── main.dart
└── presentation/
    ├── bloc/
    │   ├── auth/
    │   │   ├── auth_bloc.dart
    │   │   ├── auth_event.dart
    │   │   └── auth_state.dart
    │   ├── contribution/
    │   │   ├── contribution_bloc.dart
    │   │   ├── contribution_event.dart
    │   │   └── contribution_state.dart
    │   └── loan/
    │       ├── loan_bloc.dart
    │       ├── loan_event.dart
    │       └── loan_state.dart
    ├── pages/
    │   ├── admin/
    │   │   └── admin_dashboard_page.dart
    │   ├── users/
    │   │   ├── loan_pending_page.dart
    │   │   ├── loan_request_page.dart
    │   │   └── member_dashboard_page.dart
    │   ├── contribution_page.dart
    │   ├── join_group_page.dart
    │   ├── login_page.dart
    │   ├── profile_page.dart
    │   ├── repayment_page.dart
    │   ├── signup_page.dart
    │   ├── vicoba_group_page.dart
    │   └── view_group_page.dart
    └── widgets/
```

## Conclusion

This clean architecture implementation provides a solid foundation for the Vicoba application's future growth. The separation of concerns and dependency inversion make the codebase more maintainable, testable, and scalable. The existing functionality has been preserved while establishing patterns for future development.