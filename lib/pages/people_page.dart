import 'package:chatapp_firebase/pages/home_page.dart';
import 'package:chatapp_firebase/pages/profile_page.dart';
import 'package:chatapp_firebase/pages/search_person_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../helper/helper_function.dart';
import '../service/auth_service.dart';
import '../service/db_service.dart';
import '../widgets/person_tile.dart';
import '../widgets/widgets.dart';
import 'auth/login_page.dart';

class PeoplePage extends StatefulWidget {
  const PeoplePage({super.key});

  @override
  State<PeoplePage> createState() => _PeoplePageState();
}

class _PeoplePageState extends State<PeoplePage> {
  String userName = "";
  String email = "";
  AuthService auth = AuthService();
  Stream? people;
  String groupName = "";
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  gettingUserData() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
    await HelperFunctions.getEmail().then((value) {
      setState(() {
        email = value!;
      });
    });

    // getting snapshots in stream
    await Database(uid: FirebaseAuth.instance.currentUser!.uid)
        .getUserData()
        .then((snap) {
      setState(() {
        people = snap;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                nextScreen(context, const SearchPersonPage());
              },
              icon: const Icon(Icons.search)),
        ],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "People",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
        ),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 50),
          children: <Widget>[
            const Icon(
              Icons.account_circle_outlined,
              size: 150,
              color: Colors.teal,
            ),
            const SizedBox(
              height: 15,
            ),
            Text(
              userName,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 30,
            ),
            const Divider(
              height: 2,
            ),
            ListTile(
              onTap: () {
                nextScreen(context, const HomePage());
              },
              selectedColor: Colors.teal,
              selected: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {},
              selectedColor: Colors.teal,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.chat_bubble_outline_rounded),
              title: const Text(
                "Chats",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreen(context, const ProfilePage());
              },
              selectedColor: Colors.teal,
              selected: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.person_2_outlined),
              title: const Text(
                "Profile",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () async {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Logout",
                        ),
                        content: const Text(
                          "Are you sure?",
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.cancel_outlined),
                            color: Colors.red,
                          ),
                          IconButton(
                            onPressed: () {
                              logout();
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                  (route) => false);
                            },
                            icon: const Icon(Icons.logout_outlined),
                            color: Colors.teal,
                          )
                        ],
                      );
                    });
              },
              selectedColor: Colors.teal,
              selected: false,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.logout_outlined),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      body: peopleList(),
    );
  }

  void logout() async {
    await HelperFunctions.saveUserLoggedInStatus(false);
    await HelperFunctions.saveUserEmail("");
    await HelperFunctions.saveUserName("");
    auth.logout();
  }

  peopleList() {
    return StreamBuilder(
        stream: people,
        builder: (context, AsyncSnapshot snap) {
          if (snap.hasData) {
            if (snap.data['conversations'].length != null &&
                snap.data['conversations'].length != 0) {
              return ListView.builder(
                itemCount: snap.data['conversations'].length,
                itemBuilder: (context, index) {
                  int revIndex = snap.data['groups'].length - index - 1;
                  return PersonTile(
                    personId: HelperFunctions.getId(
                        snap.data['conversations'][revIndex]),
                    personName: HelperFunctions.getName(
                        snap.data['conversations'][revIndex]),
                  );
                },
              );
            } else {
              return noChatsWidget();
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            );
          }
        });
  }

  noChatsWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              nextScreen(context, const SearchPersonPage());
            },
            child: Icon(
              Icons.search_outlined,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
              "You do not have any conversations yet. Search for a user to start chatting!",
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
