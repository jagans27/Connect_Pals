
import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/provider/user_provider.dart';
import 'package:connectuser/utils/constants.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:connectuser/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  late UserProvider userProvider;
  late LoginProvider loginProvider;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        userProvider.searchUsers(
            query: "", email: loginProvider.userData.email ?? "");
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: false);
    loginProvider = Provider.of<LoginProvider>(context, listen: false);
    return Consumer2<UserProvider, LoginProvider>(
      builder: (context, userProvider, loginprovider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Search your pal\'s'),
            backgroundColor: const Color(0xffede0d4),
          ),
          body: Center(
            child: SizedBox(
              width: 600,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: searchController,
                          labelText: "Search",
                          maxLength: 50,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        icon: const Icon(Icons.search),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF7F5539),
                        ),
                        onPressed: () async {
                          String query = searchController.text.trim();
                          await userProvider.searchUsers(
                              query: query,
                              email: loginprovider.userData.email ?? "");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  if (userProvider.isLoading) 
                    const CircularProgressIndicator()
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: userProvider.searchedUsers.length,
                        itemBuilder: (context, index) {
                          final user = userProvider.searchedUsers[index];
                          return Padding(
                            padding: EdgeInsets.only(
                                bottom: userProvider.searchedUsers.length - 1 ==
                                        index
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
                                        userProvider.searchUsers(
                                            query: searchController.text,
                                            email:
                                                loginprovider.userData.email ??
                                                    "");
                                      }
                                    } else if (user.friendshipStatus ==
                                        FriendRequestStatus.pending.name) {
                                      bool isSuccess = await userProvider
                                          .acceptFriendRequest(
                                              recipientEmail: loginprovider
                                                      .userData.email ??
                                                  "",
                                              requesterEmail: user.email ?? "");
                                      if (isSuccess) {
                                        userProvider.searchUsers(
                                            query: searchController.text,
                                            email:
                                                loginprovider.userData.email ??
                                                    "");
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
        );
      },
    );
  }
}
