import 'package:chat_msg/const.dart';
import 'package:chat_msg/services/alert_service.dart';
import 'package:chat_msg/services/auth_service.dart';
import 'package:chat_msg/services/navigation_service.dart';
import 'package:chat_msg/widgets/custom_form_fields.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey();
  String? email, password;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildUI(context),
    );
  }

  Widget buildUI(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width,
                child: Column(
                  children: [
                    Text(
                      'Hi, Welcome Back!',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Hello again, you have been missed',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                    Container(
                      height: MediaQuery.sizeOf(context).height * 0.40,
                      margin: EdgeInsets.symmetric(
                        vertical: MediaQuery.sizeOf(context).height * 0.05,
                      ),
                      child: Form(
                          key: _loginFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CustomFormFields(
                                hintText: 'Email',
                                height: MediaQuery.sizeOf(context).height * 0.1,
                                validationRegEx: EMAIL_VALIDATION_REGEX,
                                onSaved: (value) {
                                  setState(() {
                                    email = value;
                                  });
                                },
                              ),
                              CustomFormFields(
                                hintText: 'Password',
                                height: MediaQuery.sizeOf(context).height * 0.1,
                                validationRegEx: PASSWORD_VALIDATION_REGEX,
                                obscureText: true,
                                onSaved: (value) {
                                  setState(() {
                                    password = value;
                                  });
                                },
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width,
                                child: MaterialButton(
                                  onPressed: () async {
                                    if (_loginFormKey.currentState
                                            ?.validate() ??
                                        false) {
                                      _loginFormKey.currentState?.save();
                                      bool reasult = await _authService.login(
                                          email!, password!);
                                      if (reasult) {
                                        _navigationService
                                            .pushReplacementNamed("/home");
                                      } else {
                                        _alertService.showToast(text: 'Failed to login, Please try again!',icon: Icons.error_outline);
                                      }
                                    }
                                  },
                                  color: Colors.blue,
                                  child: Text(
                                    'Login',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              )
                            ],
                          )),
                    ),
                    BottomAppBar(
                        child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Dont ya have an account? '),
                        GestureDetector(
                          onTap: (){
                            _navigationService.pushNamed('/register');
                          },
                            child: Text('Sign Up')),
                      ],
                    ))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
