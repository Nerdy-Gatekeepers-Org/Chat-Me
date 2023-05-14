import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../pages/chat_page.dart';

class GroupTile extends StatefulWidget {
  final String username;
  final String groupId;
  final String groupName;

  const GroupTile(
      {super.key,
      required this.groupId,
      required this.groupName,
      required this.username});

  @override
  State<GroupTile> createState() => _GroupTileState();
}

class _GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        nextScreen(
            context,
            ChatPage(
                groupId: widget.groupId,
                groupName: widget.groupName,
                userName: widget.username));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal[700],
            child: Text(
              widget.groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          title: Text(
            widget.groupName,
            style: TextStyle(
                color: Colors.blueGrey[800], fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Join the conversation, ${widget.username}!",
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
