import 'dart:io';
import 'package:chat_msg/const.dart';
import 'package:chat_msg/models/user_profile.dart';
import 'package:chat_msg/services/alert_service.dart';
import 'package:chat_msg/services/auth_service.dart';
import 'package:chat_msg/services/database_sevice.dart';
import 'package:chat_msg/services/media_service.dart';
import 'package:chat_msg/services/navigation_service.dart';
import 'package:chat_msg/services/storage_service.dart';
import 'package:chat_msg/widgets/custom_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _registerFormKey = GlobalKey();
  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0D47A1),
                  Color(0xFF1976D2),
                  Color(0xFF42A5F5)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Register UI
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Lets Get Going',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Register an account using the form below',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const Text(
                      'You have to fill up all the form to register including profile picture',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _registerFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  File? file =
                                      await _mediaService.getImageFromGallery();
                                  if (file != null) {
                                    setState(() {
                                      selectedImage = file;
                                    });
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor:
                                      Colors.blueAccent.withOpacity(0.1),
                                  child: CircleAvatar(
                                    radius: 55,
                                    backgroundImage: selectedImage != null
                                        ? FileImage(selectedImage!)
                                        : NetworkImage(PLACEHOLDER_PFP)
                                            as ImageProvider,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              CustomFormFields(
                                hintText: 'Name',
                                icon: Icons.person_outline,
                                height: 60,
                                validationRegEx: NAME_VALIDATION_REGEX,
                                onSaved: (value) => name = value,
                              ),
                              const SizedBox(height: 15),
                              CustomFormFields(
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                                height: 60,
                                validationRegEx: EMAIL_VALIDATION_REGEX,
                                onSaved: (value) => email = value,
                              ),
                              const SizedBox(height: 15),
                              CustomFormFields(
                                hintText: 'Password Ex:Test123!',
                                icon: Icons.lock_outline,
                                height: 60,
                                obscureText: true,
                                validationRegEx: PASSWORD_VALIDATION_REGEX,
                                onSaved: (value) => password = value,
                              ),
                              const SizedBox(height: 25),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1976D2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (_registerFormKey.currentState
                                            ?.validate() ??
                                        false && selectedImage != null) {
                                      _registerFormKey.currentState?.save();
                                      bool result = await _authService.signup(
                                          email!, password!);
                                      if (result) {
                                        String? pfpURL =
                                            await _storageService.uploadUserPfp(
                                                file: selectedImage!,
                                                uid: _authService.user!.uid);
                                        if (pfpURL != null) {
                                          await _databaseService
                                              .createUserProfile(
                                            userProfile: UserProfile(
                                              uid: _authService.user!.uid,
                                              name: name,
                                              pfpURL: pfpURL,
                                            ),
                                          );
                                          _alertService.showToast(
                                              text:
                                                  'User registered successfully!',
                                              icon: Icons.check_box_outlined);
                                          _navigationService.goBack();
                                          _navigationService
                                              .pushReplacementNamed('/home');
                                        } else {
                                          _alertService.showToast(
                                              text:
                                                  'Failed to upload profile picture',
                                              icon: Icons.error_outline);
                                        }
                                      } else {
                                        _alertService.showToast(
                                            text:
                                                'Registration failed, please try again!',
                                            icon: Icons.error_outline);
                                      }
                                    }
                                    setState(() {
                                      isLoading = false;
                                    });
                                  },
                                  child: isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Register',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(color: Colors.white70),
                        ),
                        GestureDetector(
                          onTap: () => _navigationService.pushNamed('/login'),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
