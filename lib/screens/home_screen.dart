import 'package:connectuser/provider/login_provider.dart';
import 'package:connectuser/screens/chat_screen.dart';
import 'package:connectuser/screens/login_screen.dart';
import 'package:connectuser/screens/matching_screen.dart';
import 'package:connectuser/screens/member_screen.dart';
import 'package:connectuser/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final bool isSignin;
  const HomeScreen({super.key, this.isSignin = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isChatSelected = false;

  late LoginProvider _loginProvider;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.isSignin) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MatchingScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _loginProvider = Provider.of<LoginProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectPal'),
        backgroundColor: const Color(0xffede0d4),
        actions: [
          FilledButton(
            onPressed: () {
              setState(() {
                _isChatSelected = false;
              });
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Row(
              children: [
                Text(
                  'Members',
                  style: TextStyle(color: Color(0xff9c6644)),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.group,
                  color: Color(0xff9c6644),
                  size: 15,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          FilledButton(
            onPressed: () {
              setState(() {
                _isChatSelected = true;
              });
            },
            style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5))),
            child: const Row(
              children: [
                Text(
                  'Chat',
                  style: TextStyle(color: Color(0xff9c6644)),
                ),
                SizedBox(width: 5),
                Icon(
                  Icons.chat_bubble_rounded,
                  color: Color(0xff9c6644),
                  size: 15,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          PopupMenuButton<int>(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: const Color(0xff9c6644),
              child: Text(
                _loginProvider.userData.name!.toShortName(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
            color: const Color(0xff9c6644),
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                  value: 0,
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.logout_outlined,
                        color: Colors.white,
                      ),
                      SizedBox(width: 3),
                      Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  )),
            ],
          ),
          const SizedBox(width: 20)
        ],
      ),
      body: _isChatSelected ? const ChatScreen() : const MemberScreen(),
    );
  }
}
