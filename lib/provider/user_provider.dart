import 'dart:convert';
import 'package:connectuser/model/user.dart';
import 'package:connectuser/service/internet_connectivity_service/iinternet_connectivity_service.dart';
import 'package:connectuser/service/api_service/user_service/iuser_service.dart';
import 'package:connectuser/utils/constants.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:connectuser/widgets/snackbar_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:connectuser/utils/service_result.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class UserProvider extends ChangeNotifier {
  final IInternetConnectivityService internetConnectivityService;
  final IUserService userService;
  late User userData;
  List<User> searchedUsers = [];
  List<String> messages = [];
  late io.Socket socket;
  bool isLoading = false;
  Map<String, List<Message>> chatMessages = {};
  String? recipientEmail;

  UserProvider({
    required this.internetConnectivityService,
    required this.userService,
  }) {
    _initSocket();
  }

  void _initSocket() {
    socket = io.io(
      Constants.apiBaseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setReconnectionAttempts(5)
          .enableAutoConnect()
          .build(),
    );

    socket.onConnect((_) {
      print('Connected to WebSocket');
      print('Socket ID: ${socket.id}');
      socket.emit('join', {'user_id': userData.email});
    });

    socket.onConnectError((err) => print('Connect Error: $err'));
    socket.onError((err) => print('Socket Error: $err'));

    socket.on('new_message', (data) {
      print("New message from WebSocket: $data");
      final newMessage = Message.fromJson(data);

      chatMessages.putIfAbsent(newMessage.senderEmail, () => []);
      chatMessages[newMessage.senderEmail]!.add(newMessage);
      notifyListeners();
    });

    socket.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  void updateRecipientEmail(String email) {
    recipientEmail = email;
    notifyListeners();
  }

  Future<bool> sendMessage(String content, String recipientEmail) async {
    if (content.isNotEmpty) {
      final message = {
        'sender_email': userData.email,
        'recipient_email': recipientEmail,
        'content': content,
      };

      try {
        final response = await Dio().post(
          '${Constants.apiBaseUrl}/chat/send',
          data: json.encode(message),
        );

        if (response.statusCode == 201) {
          final newMessage = Message.fromJson({
            ...message,
            'timestamp': DateTime.now().toIso8601String(),
          });

          chatMessages.putIfAbsent(recipientEmail, () => []);
          chatMessages[recipientEmail]!.add(newMessage);
          notifyListeners();

          socket.emit('send_message', message);

          return true;
        } else {
          SnackbarHelper.showSnackbar(
              'Failed to send message. Please try again.');
          return false;
        }
      } catch (e) {
        SnackbarHelper.showSnackbar(
            'An error occurred while sending the message.');
        return false;
      }
    }
    return false;
  }

  Future<void> loadInitialMessages(String recipientEmail) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await Dio().post(
        '${Constants.apiBaseUrl}/chat/messages',
        data: {
          'sender_email': userData.email,
          'recipient_email': recipientEmail,
        },
      );

      if (response.statusCode == 200) {
        if (response.data['status'] == 'success') {
          print("Fetching Data");

          chatMessages[recipientEmail] = (response.data['data'] as List)
              .map((msg) => Message.fromJson(msg))
              .toList();
        } else {
          chatMessages[recipientEmail] = [];
          SnackbarHelper.showSnackbar(response.data['message']);
        }
      } else {
        chatMessages[recipientEmail] = [];
        SnackbarHelper.showSnackbar(
            'Failed to load messages. Please try again.');
      }
    } catch (e) {
      SnackbarHelper.showSnackbar("An error occurred while loading messages.");
      chatMessages[recipientEmail] = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchUsers(
      {required String query, required String email}) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await userService.searchUsers(query: query, email: email);

      if (result.status == Status.success) {
        searchedUsers = result.data!;
      } else {
        searchedUsers = [];
        SnackbarHelper.showSnackbar(result.message);
      }
    } catch (e) {
      SnackbarHelper.showSnackbar("An error occurred while searching.");
      searchedUsers = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendFriendRequest({
    required String requesterEmail,
    required String recipientEmail,
  }) async {
    try {
      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        final result = await userService.sendFriendRequest(
          requesterEmail: requesterEmail,
          recipientEmail: recipientEmail,
        );
        if (result.status == Status.success) {
          SnackbarHelper.showSnackbar('Friend request sent successfully.');
          return true;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return false;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return false;
      }
    } catch (ex) {
      ex.logError();
      return false;
    }
  }

  Future<bool> acceptFriendRequest({
    required String requesterEmail,
    required String recipientEmail,
  }) async {
    try {
      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        final result = await userService.acceptFriendRequest(
          requesterEmail: requesterEmail,
          recipientEmail: recipientEmail,
        );
        if (result.status == Status.success) {
          SnackbarHelper.showSnackbar('Friend request accepted.');
          return true;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return false;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return false;
      }
    } catch (ex) {
      ex.logError();
      return false;
    }
  }

  Future<List<User>?> getFriendsList(String email) async {
    try {
      print("--_-Getting friendship list...");

      bool internetStatus =
          await internetConnectivityService.getNetworkConnectivityStatus();

      if (internetStatus) {
        final result = await userService.getFriendsList(email);
        if (result.status == Status.success) {
          return result.data;
        } else {
          SnackbarHelper.showSnackbar(result.message);
          return null;
        }
      } else {
        SnackbarHelper.showSnackbar("No Internet connectivity");
        return null;
      }
    } catch (ex) {
      ex.logError();
      return null;
    }
  }
}

class Message {
  final String senderEmail;
  final String recipientEmail;
  final String content;
  final DateTime timestamp;

  Message({
    required this.senderEmail,
    required this.recipientEmail,
    required this.content,
    required this.timestamp,
  });

  static Message fromJson(Map<String, dynamic> json) {
    return Message(
      senderEmail: json['sender_email'],
      recipientEmail: json['recipient_email'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "sender_email": senderEmail,
      "recipient_email": recipientEmail,
      "content": content,
      "timestamp": timestamp,
    };
  }
}
