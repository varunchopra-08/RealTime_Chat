import 'package:flutter/material.dart';

class UserList extends StatelessWidget {
  final List<String> users;

  const UserList({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (_, i) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              users[i][0].toUpperCase(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            users[i],
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          trailing: Icon(Icons.circle, size: 10, color: Colors.green.shade400),
        );
      },
    );
  }
}
