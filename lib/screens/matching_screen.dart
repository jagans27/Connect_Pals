import 'package:connectuser/provider/ai_provider.dart';
import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/provider/user_provider.dart';
import 'package:connectuser/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/extensions.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  late LoginProvider _loginProvider;
  late AIProvider _aiProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        _aiProvider.getMatchings(email: _loginProvider.userData.email ?? "");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _loginProvider = Provider.of<LoginProvider>(context);
    _aiProvider = Provider.of<AIProvider>(context);

    return Consumer3<AIProvider, LoginProvider, UserProvider>(
      builder: (context, aiProvider, loginprovider, userProvider, child) =>
          Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Match with your pal\'s'),
          backgroundColor: const Color(0xffede0d4),
        ),
        body: Center(
          child: SizedBox(
            width: 600,
            child: Column(
              children: [
                const SizedBox(height: 16.0),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Discover Your \nPerfect Profile Match...",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Color(0xff9c6644),
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (aiProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Center(
                        child: CircularProgressIndicator(
                      color: Color(0xff9c6644),
                      strokeCap: StrokeCap.round,
                    )),
                  )
                else if (aiProvider.matchings == null ||
                    aiProvider.matchings!.isEmpty)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'No matches found...',
                      style: TextStyle(fontSize: 18),
                    ),
                  ))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: aiProvider.matchings!.length,
                      itemBuilder: (context, index) {
                        final user = aiProvider.matchings![index];
                        return Padding(
                          padding: EdgeInsets.only(
                              bottom: index == aiProvider.matchings!.length - 1
                                  ? 20
                                  : 5),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                            ),
                            child: ExpansionTile(
                              title: Text(user.name!),
                              initiallyExpanded: true,
                              backgroundColor: const Color(0xffede0d4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              leading: CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xff9c6644),
                                child: Text(
                                  user.name!.toShortName(),
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 10),
                                ),
                              ),
                              showTrailingIcon: true,
                              trailing: TextButton(
                                onPressed: () async {
                                  if (user.friendshipStatus ==
                                      FriendRequestStatus.none.name) {
                                    bool isSuccess =
                                        await userProvider.sendFriendRequest(
                                      requesterEmail:
                                          loginprovider.userData.email!,
                                      recipientEmail: user.email!,
                                    );

                                    if (isSuccess) {
                                      aiProvider.updateFriendshipStatus(
                                          index: index,
                                          friendRequestStatus:
                                              FriendRequestStatus.none);
                                    }
                                  } else if (user.friendshipStatus ==
                                      FriendRequestStatus.pending.name) {
                                    bool isSuccess =
                                        await userProvider.acceptFriendRequest(
                                            recipientEmail:
                                                loginprovider.userData.email ??
                                                    "",
                                            requesterEmail: user.email ?? "");
                                    if (isSuccess) {
                                      aiProvider.updateFriendshipStatus(
                                          index: index,
                                          friendRequestStatus:
                                              FriendRequestStatus.pending);
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                    overlayColor: Colors.white),
                                child: Text(
                                  user.friendshipStatus ==
                                          FriendRequestStatus.none.name
                                      ? "Request"
                                      : user.friendshipStatus ==
                                              FriendRequestStatus.friends.name
                                          ? ""
                                          : user.friendshipStatus ==
                                                  FriendRequestStatus
                                                      .pending.name
                                              ? "Accept Request"
                                              : "Request Sent",
                                  style: const TextStyle(
                                      color: Color(0xFF7F5539),
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              children: [
                                 Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        user.intro!,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ), 
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 16.0, left: 16),
                                      child: Text(
                                        user.description!,
                                        style: const TextStyle(fontSize: 15),
                                      ), 
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
