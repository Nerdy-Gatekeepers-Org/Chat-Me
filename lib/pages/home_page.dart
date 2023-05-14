import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/pages/auth/login_page.dart';
import 'package:chatapp_firebase/pages/people_page.dart';
import 'package:chatapp_firebase/pages/profile_page.dart';
import 'package:chatapp_firebase/pages/search_page.dart';
import 'package:chatapp_firebase/service/auth_service.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:chatapp_firebase/widgets/group_tile.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "";
  String email = "";
  AuthService auth = AuthService();
  Stream? groups;
  bool _isLoading = false;
  String groupName = "";
  final String _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    gettingUserData();
  }

  // string manipulation to get group names and group ids

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
        groups = snap;
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
                nextScreen(context, const SearchPage());
              },
              icon: const Icon(Icons.search)),
        ],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Groups",
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
              onTap: () {},
              selectedColor: Colors.teal,
              selected: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              leading: const Icon(Icons.group),
              title: const Text(
                "Groups",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ListTile(
              onTap: () {
                nextScreen(context, const PeoplePage());
              },
              selectedColor: Colors.teal,
              selected: false,
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
      body: groupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          popUpDialog(context);
        },
        elevation: 0,
        backgroundColor: Colors.teal,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  void logout() async {
    await HelperFunctions.saveUserLoggedInStatus(false);
    await HelperFunctions.saveUserEmail("");
    await HelperFunctions.saveUserName("");
    auth.logout();
  }

  popUpDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: ((context, setState) {
              return AlertDialog(
                title: const Text(
                  "Create a Group",
                  textAlign: TextAlign.left,
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Colors.teal[700],
                            ),
                          )
                        : TextField(
                            onChanged: (val) {
                              setState(() {
                                groupName = val;
                              });
                            },
                            style: const TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.teal),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red[900]!),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.teal[700]!),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                    child: const Text("CANCEL"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (groupName != "") {
                        setState(() {
                          _isLoading = true;
                        });

                        await Database(uid: _uid)
                            .createGroup(userName, _uid, groupName)
                            .whenComplete(() {
                          setState(() {
                            _isLoading = false;
                          });
                          Navigator.of(context).pop();
                          showSnackbar(context, Colors.green,
                              "Group: $groupName created successfully.");
                        });
                      } else {}
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal[700]),
                    child: const Text("Create"),
                  ),
                ],
              );
            }),
          );
        });
  }

  groupList() {
    return StreamBuilder(
      stream: groups,
      builder: (context, AsyncSnapshot snap) {
        if (snap.hasData) {
          if (snap.data['groups'].length != null &&
              snap.data['groups'].length != 0) {
            return ListView.builder(
              itemCount: snap.data['groups'].length,
              itemBuilder: (context, index) {
                int revIndex = snap.data['groups'].length - index - 1;
                return GroupTile(
                    groupId:
                        HelperFunctions.getId(snap.data['groups'][revIndex]),
                    groupName:
                        HelperFunctions.getName(snap.data['groups'][revIndex]),
                    username: userName);
              },
            );
          } else {
            return noGroupWidget();
          }
        } else {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.teal,
            ),
          );
        }
      },
    );
  }

  noGroupWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              popUpDialog(context);
            },
            child: Icon(
              Icons.add_circle,
              color: Colors.grey[700],
              size: 75,
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
              "You do not have any groups yet. Tap the add icon to create a group.",
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
