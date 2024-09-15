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
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt _getIt = GetIt.instance;
  final GlobalKey<FormState> _registerFormkey = GlobalKey();
  late AuthService _authService;
  late MediaService _mediaService;
  late NavigationService _navigationService;
  late StorageService _storageService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  String? email, password, name;
  File? selectedImage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = _getIt.get<MediaService>();
    _navigationService = _getIt.get<NavigationService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SafeArea(
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Column(children: [
              headerText(),
              if (!isLoading) _registerForm(),
              if (!isLoading) bottomLogin(),
              if (isLoading)
                const Expanded(
                    child: Center(
                  child: CircularProgressIndicator(),
                ))
            ])));
  }

  Widget headerText() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        children: [
          Text(
            'Lets Get Going',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'Register an account using the form below',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.60,
      margin: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.05,
      ),
      child: Form(
          key: _registerFormkey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              pfpSelectionField(),
              customFields(),
              _registerButton(),
            ],
          )),
    );
  }

  Widget bottomLogin() {
    return BottomAppBar(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Alredy have an account? '),
        GestureDetector(
            onTap: () {
              _navigationService.goBack();
            },
            child: Text('Login')),
      ],
    ));
  }

  Widget customFields() {
    return Column(
      children: [
        CustomFormFields(
            hintText: 'Name',
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: NAME_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                name = value;
              });
            }),
        CustomFormFields(
            hintText: 'Email',
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: EMAIL_VALIDATION_REGEX,
            onSaved: (value) {
              setState(() {
                email = value;
              });
            }),
        CustomFormFields(
            hintText: 'Password',
            height: MediaQuery.sizeOf(context).height * 0.1,
            validationRegEx: PASSWORD_VALIDATION_REGEX,
            obscureText: true,
            onSaved: (value) {
              setState(() {
                password = value;
              });
            }),
      ],
    );
  }

  Widget pfpSelectionField() {
    return GestureDetector(
      onTap: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            selectedImage = file;
          });
        }
      },
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.15,
        backgroundImage: selectedImage != null
            ? FileImage(selectedImage!)
            : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
      ),
    );
  }

  Widget _registerButton() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: MaterialButton(
        color: Colors.blue,
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          try {
            if ((_registerFormkey.currentState?.validate() ?? false) &&
                selectedImage != null) {
              _registerFormkey.currentState?.save();
              bool result = await _authService.signup(email!, password!);
              if (result) {
                String? pfpURL = await _storageService.uploadUserPfp(file: selectedImage!, uid: _authService.user!.uid);
                if(pfpURL!=null){
                  await _databaseService.createUserProfile(userProfile: UserProfile(uid: _authService.user!.uid, name: name, pfpURL: pfpURL));
                  _alertService.showToast(text: 'User registered successfully!',icon: Icons.check_box_outlined);
                  _navigationService.goBack();
                  _navigationService.pushReplacementNamed('/home');
                }else{
                  throw Exception('Unable to upload user profile picture');
                }
              }else{
                throw Exception('Unable to register user');
              }

              print(result);
            }
          } catch (e) {
            _alertService.showToast(text: 'Failed to register, Please try again!',icon: Icons.error_outline);
          }
          setState(() {
            isLoading = false;
          });
        },
        child: Text(
          'Register',
        ),
      ),
    );
  }
}
