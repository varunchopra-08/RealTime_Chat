import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket socket;

  void connect(
      String username,
      Function(dynamic) onNewMessage,
      Function(dynamic, String) onUserEvent,
      Function(dynamic) onCurrentUsers,
      Function(bool) onTyping,
      ) {
    socket = IO.io(

      'http://10.0.2.2:3000',

      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();

    socket.onConnect((_) {
      socket.emit('add user', username);
    });

    socket.on('current users', (data) {
      onCurrentUsers(data);
    });

    socket.on('new message', (data) => onNewMessage(data));

    socket.on('user joined', (data) => onUserEvent(data, 'joined'));

    socket.on('user left', (data) => onUserEvent(data, 'left'));

    socket.on('typing', (_) => onTyping(true));
    socket.on('stop typing', (_) => onTyping(false));
  }

  void sendMessage(String message) {
    socket.emit('new message', message);
  }

  void startTyping() {
    socket.emit('typing');
  }

  void stopTyping() {
    socket.emit('stop typing');
  }

  void dispose() {
    socket.disconnect();
    socket.dispose();
  }
}
