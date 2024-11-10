import 'package:chat_msg/services/auth_service.dart';
import 'package:chat_msg/services/navigation_service.dart';
import 'package:chat_msg/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
void main() async{
  await setup();
  runApp( Home());
}

Future<void> setup() async{
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}

class Home extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late AuthService _authService;
   Home({super.key}){
     _navigationService=_getIt.get<NavigationService>();
     _authService=_getIt.get<AuthService>();
   }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorKey,
      initialRoute:_authService.user != null?'/home' : '/login',
      routes: _navigationService.routes,
    );
  }
}



