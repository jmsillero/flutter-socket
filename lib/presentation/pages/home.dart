import 'dart:io';

import 'package:band_names/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    super.initState();
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', (data) {
      bands = (data as List).map((e) => Band.fromMap(e)).toList();
      setState(() {});
    });
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Name'),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context).pushNamed('status'),
              icon: const Icon(Icons.wifi))
        ],
      ),
      body: Column(
        children: [
          _Chart(
            bands: bands,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, index) => _bandTile(bands[index]),
              itemCount: bands.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: addNewBand, child: const Icon(Icons.add)),
    );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context);

    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) =>
          socketService.socket.emit('remove-band', {'id': band.id}),
      background: Container(
        color: Colors.red,
        child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delete band',
              style: TextStyle(color: Colors.white),
            )),
      ),
      child: ListTile(
        leading: CircleAvatar(child: Text(band.name.substring(0, 2))),
        title: Text(band.name),
        trailing: Text(band.votes.toString()),
        onTap: () => socketService.socket.emit('vote-band', {"id": band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('Add new band'),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  MaterialButton(
                      child: Text('Add'),
                      onPressed: () => addBandToList(textController.text))
                ],
              ));
    }

    return showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text('New Band Name'),
              content: CupertinoTextField(controller: textController),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  child: const Text('Add'),
                  onPressed: () => addBandToList(textController.text),
                ),
                CupertinoDialogAction(
                  isDestructiveAction: true,
                  child: const Text('Dismiss'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ));
  }

  addBandToList(String bandName) {
    Navigator.of(context).pop();

    if (bandName.isEmpty) return;

    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.emit('add-band', {"name": bandName});
  }
}

class _Chart extends StatelessWidget {
  final List<Band> bands;
  const _Chart({
    required this.bands,
  });

  @override
  Widget build(BuildContext context) {
    final Map<String, double> dataMap = {};

    for (var e in bands) {
      dataMap.putIfAbsent(e.name, () => e.votes.toDouble());
    }

    return Container(
      height: 250,
      child: PieChart(
        dataMap: dataMap,
        chartType: ChartType.ring,
      ),
    );
  }
}
