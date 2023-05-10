import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/service/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  bool _isLoading = false;
  // QuerySnapshot? searchSnapshot;
  bool _searchStarted = false;
  String userName = "";
  User user = FirebaseAuth.instance.currentUser!;

  List _allResults = [];
  List _resultList = [];

  @override
  void initState() {
    super.initState();
    getCurrentUserIdandName();

    searchController.addListener(onSearchChanged);
  }

  onSearchChanged() {
    searchResultList();
    setState(() {
      if (searchController.text != "") {
        _searchStarted = true;
      } else {
        _searchStarted = false;
      }
    });
  }

  searchResultList() {
    var showResults = [];
    if (searchController.text != "") {
      for (var clientSnapshot in _allResults) {
        var groupName = clientSnapshot['groupName'].toString().toLowerCase();

        if (groupName.contains(searchController.text.toLowerCase())) {
          showResults.add(clientSnapshot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultList = showResults;
    });
  }

  getClientStream() async {
    setState(() {
      _isLoading = true;
    });
    await Database().groups.get().then((value) => setState(() {
          _isLoading = false;
          _allResults = value.docs;
        }));

    searchResultList();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.removeListener(onSearchChanged);
    searchController.dispose();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    setState(() {
      _isLoading = true;
    });
    await getClientStream();
  }

  getCurrentUserIdandName() async {
    await HelperFunctions.getUserName().then((value) {
      setState(() {
        userName = value!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        title: CupertinoSearchTextField(
          backgroundColor: Colors.white,
          controller: searchController,
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.teal,
              ),
            )
          : groupList(),
    );
  }

  // not needed but retain for future reference
  initiateSearch() async {
    if (searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      await Database(uid: user.uid)
          .searchGroup(searchController.text)
          .then((snapshot) {
        setState(() {
          // searchSnapshot = snapshot;
          _isLoading = false;
          _searchStarted = true;
        });
      });
    }
  }

  groupList() {
    return _searchStarted
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: _resultList.length,
            itemBuilder: (context, index) {
              return groupTile(
                userName,
                _resultList[index]['groupId'],
                _resultList[index]['groupName'],
                HelperFunctions.getName(_resultList[index]['admin']),
                _resultList[index]['members'],
              );
            },
          )
        : Container();
  }

  Widget groupTile(String userName, String groupId, String groupName,
      String admin, List<dynamic> members) {
    bool isJoined = members.contains("${user.uid}_$userName");

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      leading: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.teal[700],
        child: Text(
          groupName.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        groupName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin: ${HelperFunctions.getName(admin)}"),
      trailing: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return InkWell(
            onTap: () {
              setState(() {
                isJoined = !isJoined;
              });

              print("Flutter: ${isJoined.toString()}");
            },
            child: isJoined
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "Joined",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.teal,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: const Text(
                      "Join Now",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
