import 'package:chat_msg/models/user_profile.dart';
import 'package:chat_msg/pages/chat_page.dart';
import 'package:chat_msg/services/alert_service.dart';
import 'package:chat_msg/services/auth_service.dart';
import 'package:chat_msg/services/database_sevice.dart';
import 'package:chat_msg/services/navigation_service.dart';
import 'package:chat_msg/widgets/chat_tile.dart';
import 'package:chat_msg/widgets/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  late DatabaseService _databaseService;

  bool _isDarkMode = false;
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _navigationService = _getIt.get<NavigationService>();
    _alertService = _getIt.get<AlertService>();
    _databaseService = _getIt.get<DatabaseService>();
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      _searchText = searchText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Messages',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isDarkMode ? Colors.grey[850]! : Colors.blue[400]!,
                _isDarkMode ? Colors.black : Colors.blue[50]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleDarkMode,
            icon: Icon(
              _isDarkMode ? Icons.brightness_7 : Icons.brightness_3,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 15),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.blue[50]!],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 50,
                            color: Colors.orangeAccent,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Log Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Are you sure you want to log out?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.grey[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "No",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  "Yes",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );

              if (shouldLogout == true) {
                bool result = await _authService.logout();
                if (result) {
                  _alertService.showToast(
                    text: 'Successfully logged out!',
                    icon: Icons.check_box_outlined,
                  );
                  _navigationService.pushReplacementNamed('/login');
                }
              }
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: SearchWidget(onSearchTextChanged: _onSearchTextChanged),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _isDarkMode ? Colors.grey[850]! : Colors.blue[100]!,
              _isDarkMode ? Colors.black : Colors.blue[50]!,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
        child: _chatsList(),
      ),
    );
  }

  Widget _chatsList() {
    return StreamBuilder(
      stream: _databaseService.getUserProfiles(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Unable to load data',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 16,
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blueAccent),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          final users = snapshot.data!.docs;
          final filteredUsers = users.where((userDoc) {
            final user = userDoc.data();
            final userName = user.name!.toLowerCase();
            return userName.contains(_searchText.toLowerCase());
          }).toList();

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              UserProfile user = filteredUsers[index].data();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.white,
                  shadowColor: Colors.blue.withOpacity(0.3),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ChatTile(
                      userProfile: user,
                      onTap: () async {
                        final chatExists =
                            await _databaseService.checkChatExists(
                          _authService.user!.uid,
                          user.uid!,
                        );
                        if (!chatExists) {
                          await _databaseService.createNewChat(
                            _authService.user!.uid,
                            user.uid!,
                          );
                        }
                        _navigationService.push(
                          MaterialPageRoute(
                            builder: (context) => ChatPage(chatUser: user),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        }
        return const Center(
          child: Text(
            'No users found',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }
}
