import 'package:flutter/material.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;
  bool isDarkMode = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 800));

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeIn,
        ));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.decelerate));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  ThemeData get _theme => isDarkMode
      ? ThemeData.dark().copyWith(
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: Colors.grey[900],
    primaryColor: Colors.blueAccent,
  )
      : ThemeData.light().copyWith(
    scaffoldBackgroundColor: Colors.white,
    cardColor: Colors.white,
    primaryColor: Colors.blueAccent,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Theme(
          data: _theme,
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Welcome"),
              centerTitle: true,
              elevation: 0,
              backgroundColor: Colors.transparent,
              actions: [
                IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () {
                    setState(() {
                      isDarkMode = !isDarkMode;
                    });
                  },
                )
              ],
            ),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [const Color(0xFF1f1f1f), Colors.black]
                      : [Colors.blue.shade100, Colors.blue.shade300],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: _theme.primaryColor,
                                child: const Icon(Icons.chat, size: 40, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Hello 👋',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: _theme.primaryColor,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sign in to join the chat',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 24),

                              /// Username
                              TextField(
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  hintText: 'Username',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              /// Password
                              TextField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  hintText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              /// Remember Me
                              Row(
                                children: [
                                  Checkbox(
                                    value: rememberMe,
                                    onChanged: (val) {
                                      setState(() {
                                        rememberMe = val ?? false;
                                      });
                                    },
                                  ),
                                  const Text("Remember Me"),
                                ],
                              ),
                              const SizedBox(height: 16),

                              /// Join Chat Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    backgroundColor: _theme.primaryColor,
                                  ),
                                  onPressed: () {
                                    if (_usernameController.text
                                        .trim()
                                        .isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ChatScreen(
                                              username:
                                              _usernameController.text
                                                  .trim()),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Join Chat',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              /// Social Login
                              const Text("Or join with"),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _socialButton(
                                      icon: Icons.g_mobiledata,
                                      color: Colors.redAccent),
                                  _socialButton(
                                      icon: Icons.facebook,
                                      color: Colors.blueAccent),
                                  _socialButton(
                                      icon: Icons.apple,
                                      color: Colors.black87),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _socialButton({required IconData icon, required Color color}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
