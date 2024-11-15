import 'dart:io';
import 'package:chat_msg/models/message.dart';
import 'package:chat_msg/models/user_profile.dart';
import 'package:chat_msg/services/auth_service.dart';
import 'package:chat_msg/services/database_sevice.dart';
import 'package:chat_msg/services/media_service.dart';
import 'package:chat_msg/services/storage_service.dart';
import 'package:chat_msg/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../models/chat.dart';

class ChatPage extends StatefulWidget {
  final UserProfile chatUser;

  const ChatPage({super.key, required this.chatUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  late StorageService _storageService;

  ChatUser? currentUser, otherUser;

  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _databaseService = _getIt.get<DatabaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();

    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.chatUser.uid!,
        firstName: widget.chatUser.name,
        profileImage: widget.chatUser.pfpURL);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUser.pfpURL!),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.chatUser.name!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[100]!, Colors.blue[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: StreamBuilder(
          stream: _databaseService.getChatData(currentUser!.id, otherUser!.id),
          builder: (context, snapshot) {
            Chat? chat = snapshot.data?.data();
            List<ChatMessage> messages = [];
            if (chat != null && chat.messages != null) {
              messages = _generateChatMessagesList(chat.messages!);
            }
            return DashChat(
              messages: messages,
              currentUser: currentUser!,
              messageOptions: MessageOptions(
                showCurrentUserAvatar: true,
                currentUserContainerColor: Colors.blue[400],
                showTime: true,
                timeFormat: DateFormat('h:mm a'),
                messagePadding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              inputOptions: InputOptions(
                inputDecoration: InputDecoration(
                  hintText: 'Type a message...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
                alwaysShowSend: true,
                trailing: [_mediaMessageButton()],
              ),
              onSend: _sendMessage,
            );
          }),
    );
  }

  Future<void> _sendMessage(ChatMessage chatMessage) async {
    if (chatMessage.medias?.isNotEmpty ?? false) {
      if (chatMessage.medias!.first.type == MediaType.image) {
        Message message = Message(
          senderID: chatMessage.user.id,
          content: chatMessage.medias!.first.url,
          messageType: MessageType.Image,
          sentAt: Timestamp.fromDate(chatMessage.createdAt),
        );
        await _databaseService.sendChatMessage(
            currentUser!.id, otherUser!.id, message);
      }
    } else {
      Message message = Message(
        senderID: currentUser!.id,
        content: chatMessage.text,
        messageType: MessageType.Text,
        sentAt: Timestamp.fromDate(chatMessage.createdAt),
      );
      await _databaseService.sendChatMessage(
          currentUser!.id, otherUser!.id, message);
    }
  }

  List<ChatMessage> _generateChatMessagesList(List<Message> messages) {
    List<ChatMessage> chatMessages = messages.map((m) {
      if (m.messageType == MessageType.Image) {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          createdAt: m.sentAt!.toDate(),
          medias: [
            ChatMedia(
              url: m.content!,
              fileName: '',
              type: MediaType.image,
            )
          ],
        );
      } else {
        return ChatMessage(
          user: m.senderID == currentUser!.id ? currentUser! : otherUser!,
          text: m.content!,
          createdAt: m.sentAt!.toDate(),
        );
      }
    }).toList();
    chatMessages.sort((a, b) {
      return b.createdAt.compareTo(a.createdAt);
    });
    return chatMessages;
  }

  Widget _mediaMessageButton() {
    return IconButton(
      onPressed: () async {
        File? file = await _mediaService.getImageFromGallery();
        if (file != null) {
          String chatID =
              generateChatID(uid1: currentUser!.id, uid2: otherUser!.id);
          String? downloadURL = await _storageService.uploadImageToChat(
              file: file, chatID: chatID);
          if (downloadURL != null) {
            ChatMessage chatMessage = ChatMessage(
              user: currentUser!,
              createdAt: DateTime.now(),
              medias: [
                ChatMedia(url: downloadURL, fileName: '', type: MediaType.image)
              ],
            );
            _sendMessage(chatMessage);
          }
        }
      },
      icon: const Icon(
        Icons.image_outlined,
        color: Colors.blueAccent,
        size: 28,
      ),
    );
  }
}
