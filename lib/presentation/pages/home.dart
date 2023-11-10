import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:band_names/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Ramstein', votes: 5),
    Band(id: '3', name: 'Bon Jovi', votes: 5),
    Band(id: '4', name: 'Heroes del Silencio', votes: 5),
    Band(id: '5', name: 'Chocolate MC', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Band Name'),
      ),
      body: ListView.builder(
        itemBuilder: (_, index) => _bandTile(bands[index]),
        itemCount: bands.length,
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), onPressed: addNewBand),
    );
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: Key(band.id),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => bands.remove(band),
      background: Container(
        color: Colors.red,
        child: Align(
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
        onTap: () => print("Band Name: ${band.name}"),
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

    bands.add(Band(id: DateTime.now().toString(), name: bandName, votes: 0));
    setState(() {});
  }
}
