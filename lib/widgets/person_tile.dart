
import 'package:flutter/material.dart';


class PersonTile extends StatefulWidget {
  final String personId;
  final String personName;

  const PersonTile({
    super.key,
    required this.personId,
    required this.personName,
  });

  @override
  State<PersonTile> createState() => _PersonTileState();
}

class _PersonTileState extends State<PersonTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.teal,
            child: Text(
              widget.personName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          title: Text(
            widget.personName,
            style: TextStyle(
                color: Colors.blueGrey[800], fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Talk to ${widget.personName}!",
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}
