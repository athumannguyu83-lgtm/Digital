import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/profile_photo_validator.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../../domain/entities/user_entity.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthBloc _authBloc = Get.find<AuthBloc>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  UserEntity? _currentUser;
  Uint8List? _profilePhotoBytes;
  bool _isUploadingPhoto = false;
  bool _isLoadingProfilePhoto = false;
  double _photoUploadProgress = 0;

  @override
  void initState() {
    super.initState();
    _authBloc.add(const LoadCurrentUserRequested());
  }

  void _onAuthStateChanged(AuthState state) {
    switch (state.operation) {
      case AuthOperation.loadUser:
        if (state.status == AuthStatus.success) {
          final user = state.currentUser;
          if (user == null || !mounted) return;

          setState(() {
            _currentUser = user;
            _profilePhotoBytes = null;
            _nameController.text = user.name;
            _phoneController.text = user.phone;
            _isLoadingProfilePhoto =
                user.profileImagePath?.isNotEmpty ?? false;
          });

          final imagePath = user.profileImagePath;
          if (imagePath != null && imagePath.isNotEmpty) {
            _authBloc.add(LoadProfilePhotoRequested(imagePath));
          } else {
            setState(() => _isLoadingProfilePhoto = false);
          }
        } else if (state.status == AuthStatus.failure) {
          setState(() => _isLoadingProfilePhoto = false);
        }
        break;
      case AuthOperation.loadPhoto:
        if (!mounted) return;
        setState(() {
          _profilePhotoBytes = state.status == AuthStatus.success
              ? state.profilePhotoBytes
              : null;
          _isLoadingProfilePhoto = false;
        });
        if (state.status == AuthStatus.failure) {
          Get.snackbar(
            'Could not load profile photo',
            state.errorMessage,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
        }
        break;
      case AuthOperation.uploadPhoto:
        if (!mounted) return;
        setState(() => _isUploadingPhoto = false);
        if (state.status == AuthStatus.success) {
          final user = state.currentUser;
          if (user != null) {
            setState(() {
              _currentUser = user;
              _nameController.text = user.name;
              _phoneController.text = user.phone;
            });
          }
          Get.snackbar(
            'Profile photo updated',
            'Your new photo is now on your profile.',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            'Upload failed',
            state.errorMessage,
            backgroundColor: Colors.redAccent,
            colorText: Colors.white,
          );
          _authBloc.add(const LoadCurrentUserRequested());
        }
        break;
      case AuthOperation.updateProfile:
        if (state.status == AuthStatus.success) {
          Get.back();
          Get.snackbar(
            "Success",
            "Profile updated successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
          _authBloc.add(const LoadCurrentUserRequested());
        } else {
          Get.snackbar(
            "Error",
            state.errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        break;
      case AuthOperation.updatePassword:
        if (state.status == AuthStatus.success) {
          Get.back();
          Get.snackbar(
            "Success",
            "Password changed successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            state.errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        break;
      case AuthOperation.deleteAccount:
        if (state.status == AuthStatus.success) {
          Get.offAllNamed('/login');
          Get.snackbar(
            "Account Deleted",
            "Your account has been successfully deleted",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          Get.snackbar(
            "Error",
            state.errorMessage,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        break;
      case AuthOperation.logout:
        if (state.status == AuthStatus.success) {
          Get.offAllNamed('/login');
        }
        break;
      default:
        break;
    }
  }

  Future<void> _chooseProfilePhoto(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (image == null || !mounted) return;

      final imageBytes = await image.readAsBytes();
      final contentType = await ProfilePhotoValidator.validate(imageBytes);
      setState(() {
        _profilePhotoBytes = imageBytes;
        _isUploadingPhoto = true;
        _photoUploadProgress = 0;
      });

      _authBloc.add(
        UploadProfilePhotoRequested(
          imageBytes,
          contentType: contentType,
          onProgress: (progress) {
            if (mounted) {
              setState(() => _photoUploadProgress = progress);
            }
          },
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        Get.snackbar(
          'Could not upload photo',
          error.toString(),
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    }
  }

  void _showProfilePhotoOptions() {
    Get.bottomSheet(
      SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Profile photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take a photo'),
                onTap: () async {
                  Get.back();
                  await _chooseProfilePhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () async {
                  Get.back();
                  await _chooseProfilePhoto(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      bloc: _authBloc,
      listenWhen: (previous, current) =>
          current.status == AuthStatus.success ||
          current.status == AuthStatus.failure,
      listener: (context, state) => _onAuthStateChanged(state),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text("My Profile"),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          bloc: _authBloc,
          buildWhen: (previous, current) =>
              previous.isLoading != current.isLoading,
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // 1. Header: Avatar, Name, and Role
                  _buildProfileHeader(),
                  const SizedBox(height: 20),

                  // 2. Personal Information Card
                  _buildPersonalInfoCard(),

                  const SizedBox(height: 20),

                  // 3. Settings / Actions List
                  _buildSettingsList(),

                  const SizedBox(height: 30),

                  // 4. Logout Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: state.isLoading ? null : _handleLogout,
                        icon: const Icon(Icons.logout, color: Colors.red),
                        label: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.red,
                                ),
                              )
                            : const Text(
                                "Logout",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildProfileHeader() {
    final Uint8List? profilePhoto = _profilePhotoBytes;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blue[100],
                child: _isLoadingProfilePhoto
                    ? const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : profilePhoto == null
                    ? _buildProfileInitial()
                    : ClipOval(
                        child: Image.memory(
                          profilePhoto,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildProfileInitial(),
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: Colors.blueAccent,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: 'Change profile photo',
                    onPressed: _isUploadingPhoto
                        ? null
                        : _showProfilePhotoOptions,
                    icon: _isUploadingPhoto
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                              value: _photoUploadProgress > 0
                                  ? _photoUploadProgress
                                  : null,
                            ),
                          )
                        : const Icon(Icons.edit, color: Colors.white, size: 18),
                    constraints: const BoxConstraints.tightFor(
                      width: 36,
                      height: 36,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          if (_isUploadingPhoto) ...[
            const SizedBox(height: 8),
            Text(
              'Uploading photo ${(_photoUploadProgress * 100).round()}%',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
          const SizedBox(height: 15),
          Text(
            _currentUser?.name ?? 'Loading...',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _currentUser?.role.toUpperCase() ?? 'MEMBER',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInitial() {
    return Text(
      _currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
      style: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInfoTile(
            "Email",
            _currentUser?.email ?? 'Loading...',
            Icons.email,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            "Phone",
            _currentUser?.phone ?? 'Loading...',
            Icons.phone,
          ),
          const SizedBox(height: 16),
          _buildInfoTile(
            "Member Since",
            _currentUser != null
                ? '${_currentUser!.createdAt.day}/${_currentUser!.createdAt.month}/${_currentUser!.createdAt.year}'
                : 'Loading...',
            Icons.calendar_today,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showEditProfileDialog,
              icon: const Icon(Icons.edit, size: 20),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsList() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _profileTile(
            "Change Password",
            Icons.lock_outline,
            _showChangePasswordDialog,
          ),
          _profileTile(
            "Delete Account",
            Icons.delete_outline,
            _showDeleteAccountDialog,
            isDestructive: true,
          ),
          _profileTile("Help & Support", Icons.help_outline, () {
            Get.snackbar(
              "Help & Support",
              "Contact support at support@vicoba.com",
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          }),
          _profileTile("Terms of Service", Icons.description_outlined, () {
            Get.snackbar(
              "Terms of Service",
              "Terms and conditions will be displayed here",
              backgroundColor: Colors.blue,
              colorText: Colors.white,
            );
          }),
        ],
      ),
    );
  }

  Widget _profileTile(
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          BlocBuilder<AuthBloc, AuthState>(
            bloc: _authBloc,
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        _authBloc.add(
                          UpdateProfileRequested(
                            name: _nameController.text,
                            phone: _phoneController.text,
                          ),
                        );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save"),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    Get.dialog(
      AlertDialog(
        title: const Text("Change Password"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Current Password",
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "New Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Confirm New Password",
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          BlocBuilder<AuthBloc, AuthState>(
            bloc: _authBloc,
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading,
            builder: (context, state) {
              return ElevatedButton(
                onPressed: state.isLoading
                    ? null
                    : () {
                        if (_newPasswordController.text !=
                            _confirmPasswordController.text) {
                          Get.snackbar(
                            "Error",
                            "Passwords do not match",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (_newPasswordController.text.length < 6) {
                          Get.snackbar(
                            "Error",
                            "Password must be at least 6 characters",
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        _authBloc.add(
                          UpdatePasswordRequested(
                            currentPassword: _currentPasswordController.text,
                            newPassword: _newPasswordController.text,
                          ),
                        );
                      },
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Change Password"),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.defaultDialog(
      title: "Delete Account",
      middleText:
          "Are you sure you want to delete your account? This action cannot be undone.",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _authBloc.add(const DeleteAccountRequested());
      },
      textCancel: "Cancel",
    );
  }

  void _handleLogout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to log out of your account?",
      textConfirm: "Yes, Logout",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        _authBloc.add(const LogoutRequested());
      },
      textCancel: "Cancel",
    );
  }
}
