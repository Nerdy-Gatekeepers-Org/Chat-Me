import 'package:cloud_firestore/cloud_firestore.dart';

class Database {
  final String? uid;
  Database({this.uid});

  final CollectionReference users =
      FirebaseFirestore.instance.collection("users");

  final CollectionReference groups =
      FirebaseFirestore.instance.collection("groups");

  // saving user
  Future saveUser(String name, String email) async {
    return await users.doc(uid).set({
      "name": name,
      "email": email,
      "groups": [],
      "conversations": [],
      "profilepic": "",
      "uid": uid
    });
  }

  //  getting user
  Future getUser(String email) async {
    QuerySnapshot snapshot = await users.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // getting data of a user
  getUserData() async {
    return users.doc(uid).snapshots();
  }

  // getting conversations
  getUserConversations() async {
    CollectionReference conversations =
        users.doc(uid).collection("conversations");

    return conversations;
  }

  // create group
  Future createGroup(String userName, String id, String groupName) async {
    var data = {
      // initial data of the group to be created
      "groupName": groupName,
      "groupIcon": "",
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    };
    DocumentReference docRef =
        await groups.add(data); // creates the group itself

    await docRef.update({
      // initial update: Adding of the first member (admin) and groupId
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": docRef.id,
    });

    DocumentReference userRef = users.doc(uid);

    return await userRef.update({
      "groups": FieldValue.arrayUnion(["${docRef.id}_$groupName"]),
    });
  }

  // Getting the chat
  getChats(String groupId) async {
    return groups
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference docRef = groups.doc(groupId);
    DocumentSnapshot documentSnapshot = await docRef.get();

    return documentSnapshot['admin'];
  }

  // Getting group members

  getGroupInfo(String groupId) async {
    return groups.doc(groupId).snapshots();
  }

  // search a group
  // TODO: Implement RegEx Search
  searchGroup(String grpName) async {
    return groups
        .where('groupName', isGreaterThanOrEqualTo: grpName)
        .where('groupName', isLessThanOrEqualTo: '$grpName\uf8ff')
        .get();
  }

  searchUsers(String name) async {
    return users
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThanOrEqualTo: '$name\uf8ff')
        .where('email', isGreaterThanOrEqualTo: name)
        .where('email', isLessThanOrEqualTo: '$name\uf8ff')
        .get();
  }

// not needed but retain for future reference
  searchGrp(String grpName) async {
    return FirebaseFirestore.instance
        .collection("groups")
        .where('groupName', isGreaterThanOrEqualTo: grpName)
        .where('groupName', isLessThanOrEqualTo: '$grpName\uf8ff')
        .get()
        .then((QuerySnapshot snapshot) {
      List<DocumentSnapshot> documents = snapshot.docs;
      List<DocumentSnapshot> filteredDocs =
          documents.where((doc) => doc['groupName'].contains(grpName)).toList();
      return filteredDocs;
    });
  }

// not needed but retain for future reference
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference docRef = users.doc(uid);
    DocumentSnapshot docSnap = await docRef.get();

    List<dynamic> group = await docSnap['groups'];

    if (group.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }
}
