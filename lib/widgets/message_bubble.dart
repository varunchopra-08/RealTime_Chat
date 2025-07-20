import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final msgParts = message.split(': ');
    final username = msgParts.first;
    final text = msgParts.sublist(1).join(': ');

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blueAccent : Colors.grey.shade300,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                username,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16),
            ),
            const SizedBox(height: 4),
            // Reaction Row (optional)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.favorite_border, size: 16, color: Colors.white70),
                SizedBox(width: 4),
                Icon(Icons.emoji_emotions_outlined, size: 16, color: Colors.white70),
              ],
            )
          ],
        ),
      ),
    );
  }
}
