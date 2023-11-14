import 'package:band_names/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final socket = socketService.socket;

    return Scaffold(
      appBar: AppBar(title: Text('Connection Status')),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              socketService.serverStatus == ServerStatus.online
                  ? Icons.wifi_outlined
                  : Icons.wifi_off_outlined,
              size: 200,
              color: Colors.grey.shade500,
            ),
            Text(
              (socketService.serverStatus == ServerStatus.online
                      ? 'Connected'
                      : 'Disconnected')
                  .toUpperCase(),
              style: TextStyle(
                  fontSize: 38,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () {
        socket.emit('message', {'message': 'Sending message from status'});
      }),
    );
  }
}
