import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:connectuser/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectuser/model/user.dart';
import 'package:connectuser/provider/user_provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late UserProvider userProvider;
  late LoginProvider loginProvider;
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider.userData = loginProvider.userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);
    loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chat),
            const SizedBox(width: 5),
            const Text('Chat '),
            if (userProvider.recipientEmail != null)
              Text(
                "with ${userProvider.recipientEmail ?? ""} ",
                style: const TextStyle(fontSize: 15),
              ),
          ],
        ),
        backgroundColor: const Color(0xffede0d4),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Consumer<UserProvider>(
                    builder: (context, provider, child) {
                      final messages =
                          provider.chatMessages[provider.recipientEmail] ?? [];

                      if (messages.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              curve: Curves.easeOut,
                              duration: const Duration(seconds: 1));
                        });
                      }

                      return ListView.builder(
                        reverse: false,
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isCurrentUser =
                              message.senderEmail == provider.userData.email;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                              alignment: isCurrentUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                constraints:
                                    const BoxConstraints(maxWidth: 600),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? const Color(0xffe6ccb2)
                                      : const Color(0xffd4a373),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(message.content),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          maxLines: 1,
                          cursorColor: const Color(0xff9c6644),
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xff9c6644)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            border: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Color(0xff9c6644)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (userProvider.recipientEmail == null) {
                            SnackbarHelper.showSnackbar(
                                "Choose your friend to Send message");
                          } else {
                            userProvider.sendMessage(messageController.text,
                                userProvider.recipientEmail!);
                            messageController.clear();
                          }
                        },
                        color: const Color(0xFF7F5539),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: FriendsList(
              userEmail: loginProvider.userData.email ?? "",
              slectedEmail: userProvider.recipientEmail ?? "",
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsList extends StatefulWidget {
  final String userEmail;
  final String slectedEmail;

  const FriendsList({
    super.key,
    required this.userEmail,
    required this.slectedEmail,
  });

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  late Future<List<User>?> _friendsFuture;

  @override
  void initState() {
    super.initState();
    _friendsFuture = _loadFriends();
  }

  Future<List<User>?> _loadFriends() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.getFriendsList(widget.userEmail);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      color: const Color(0xffede0d4),
      child: FutureBuilder<List<User>?>(
        future: _friendsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff9c6644)),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No friends found.'));
          } else {
            List<User> friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xff9c6644),
                      radius: 15,
                      child: Text(
                        friend.name!.toShortName(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      friend.name!,
                      style: TextStyle(
                          fontWeight:
                              userProvider.recipientEmail == friend.email
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                    ),
                    onTap: () {
                      userProvider.updateRecipientEmail(friend.email!);
                      userProvider.loadInitialMessages(friend.email!);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
