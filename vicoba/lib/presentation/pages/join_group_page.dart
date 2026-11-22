import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/group/group_bloc.dart';
import '../bloc/group/group_event.dart';
import '../bloc/group/group_state.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _JoinGroupScreenState createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isButtonEnabled = false;

  final GroupBloc _groupBloc = Get.find<GroupBloc>();

  @override
  void initState() {
    super.initState();
    _codeController.addListener(() {
      setState(() {
        _isButtonEnabled = _codeController.text.trim().length >= 5;
      });
    });
  }

  void _joinGroup() {
    _groupBloc.add(JoinGroupByCodeRequested(_codeController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GroupBloc, GroupState>(
      bloc: _groupBloc,
      listenWhen: (previous, current) =>
          current.status == GroupStatus.success ||
          current.status == GroupStatus.failure,
      listener: (context, state) {
        if (state.operation == GroupOperation.join) {
          if (state.status == GroupStatus.success) {
            Get.snackbar(
              "Success",
              "You have successfully joined ${state.joinedGroup?.name ?? 'the group'}!",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
            _codeController.clear();
          } else {
            Get.snackbar(
              "Error",
              state.errorMessage,
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.redAccent,
              colorText: Colors.white,
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Join Vicoba"),
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Enter Group Code",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Ask your group administrator for the unique group code to join the circle.",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Styled Input Field
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: "e.g. VIC-123456",
                  prefixIcon: Icon(
                    Icons.group_add_outlined,
                    color: Colors.green,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Interactive Join Button
              BlocBuilder<GroupBloc, GroupState>(
                bloc: _groupBloc,
                buildWhen: (previous, current) =>
                    previous.isLoading != current.isLoading,
                builder: (context, state) {
                  return SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: (_isButtonEnabled && !state.isLoading)
                          ? _joinGroup
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        disabledBackgroundColor: Colors.grey[300],
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Join Group",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
