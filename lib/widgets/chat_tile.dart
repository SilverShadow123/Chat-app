import 'package:chat_msg/models/user_profile.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserProfile userProfile;
  final Function onTap;

  const ChatTile({Key? key, required this.userProfile, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => onTap(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(userProfile.pfpURL!),
        radius: 30,
      ),
      title: Text(
        userProfile.name!,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18),
      ),
      subtitle: Text(
        'Tap to chat',
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: Icon(
        Icons.chat_bubble_outline,
        color: Colors.blue[400],
      ),
    );
  }
}
