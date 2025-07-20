import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../services/socket_service.dart';
import '../widgets/message_bubble.dart';
import '../widgets/user_list.dart';
import '../widgets/typing_indicator.dart';
import 'dart:async';
import 'dart:ui';

class ChatScreen extends StatefulWidget {
  final String username;

  const ChatScreen({super.key, required this.username});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final SocketService socketService = SocketService();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<String> messages = [];
  List<String> users = [];
  bool isTyping = false;
  bool isDarkMode = false;
  bool showEmojiPicker = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    socketService.connect(
      widget.username,
      _onNewMessage,
      _onUserEvent,
      _onCurrentUsers,
      _onTyping,
    );
  }

  void _onNewMessage(dynamic data) {
    setState(() {
      if (data is Map && data['username'] != null && data['message'] != null) {
        messages.add('${data['username']}: ${data['message']}');
      } else if (data is String) {
        messages.add(data);
      }
    });
    _scrollToBottom();
  }

  void _onCurrentUsers(dynamic data) {
    setState(() {
      users = List<String>.from(data);
    });
  }

  void _onUserEvent(dynamic data, String event) {
    setState(() {
      if (event == 'joined') {
        if (!users.contains(data['username'])) {
          users.add(data['username']);
        }
        messages.add('${data['username']} joined');
      } else if (event == 'left') {
        users.remove(data['username']);
        messages.add('${data['username']} left');
      }
    });
    _scrollToBottom();
  }

  void _onTyping(bool typing) {
    setState(() {
      isTyping = typing;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    socketService.sendMessage(text);
    setState(() {
      messages.add('${widget.username}: $text');
    });
    _msgController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    socketService.dispose();
    _msgController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  Widget chatWidget() {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.black, Colors.grey.shade900]
                : [Colors.blue.shade100, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text("No messages yet"))
                  : ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (_, i) {
                  final isMe =
                  messages[i].startsWith('${widget.username}:');
                  return AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                              sigmaX: 5, sigmaY: 5),
                          child: MessageBubble(
                            message: messages[i],
                            isMe: isMe,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (isTyping) const TypingIndicator(),

            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  margin: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.emoji_emotions_outlined),
                        onPressed: () {
                          setState(() {
                            showEmojiPicker = !showEmojiPicker;
                          });
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          decoration: const InputDecoration(
                            hintText: 'Type a message…',
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 8),
                          ),
                          onChanged: (text) {
                            socketService.startTyping();
                            _typingTimer?.cancel();
                            _typingTimer = Timer(const Duration(seconds: 1), () {
                              socketService.stopTyping();
                            });
                          },
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send,
                            color: isDarkMode
                                ? Colors.lightBlueAccent
                                : Colors.blueAccent),
                        onPressed: sendMessage,
                      ),
                    ],
                  ),
                ),
                if (showEmojiPicker)
                  SizedBox(
                    height: 250,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        _msgController.text += emoji.emoji;
                      },
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 28 *
                            (Theme.of(context).platform == TargetPlatform.iOS ? 1.30 : 1.0),
                        bgColor: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                        indicatorColor: Colors.blueAccent,
                      ),
                    ),
                  )

              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Chat as ${widget.username}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF4facfe),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  widget.username[0].toUpperCase(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blueAccent),
                ),
              ),
            )
          ],
          elevation: 4,
          shadowColor: Colors.black26,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                children: [
                  Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color:
                      isDarkMode ? Colors.black54 : Colors.grey.shade100,
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(2, 0))
                      ],
                    ),
                    child: UserList(users: users),
                  ),
                  Expanded(flex: 3, child: chatWidget()),
                ],
              );
            } else {
              return Column(
                children: [
                  SizedBox(height: 100, child: UserList(users: users)),
                  Expanded(child: chatWidget()),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
