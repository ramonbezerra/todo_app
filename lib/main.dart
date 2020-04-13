import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MaterialApp(
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _todoController = TextEditingController();

  List _todoList = [];

  Map<String, dynamic> _lastRemoved;
  int _lastRemovedIndex;

  @override
  void initState() {
    super.initState();
    _readData().then((data) {
      setState(() {
        _todoList = json.decode(data);
      });
    });
  }

  void _addTask() {
    setState(() {
      Map<String, dynamic> newTask = Map();
      newTask["title"] = _todoController.text;
      newTask["ok"] = false;
      _todoController.text = "";
      _todoList.add(newTask);
      _saveData();
    });
  }

  void _checkTask(value, index) {
    setState(() {
      _todoList[index]["ok"] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo App"),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _todoController,
                    decoration: InputDecoration(labelText: "New Task"),
                  ),
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  child: Text("Add"),
                  onPressed: _addTask,
                  textColor: Colors.white,
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: buildItem,
            padding: EdgeInsets.only(top: 10.0),
            itemCount: _todoList.length,
          ))
        ],
      ),
    );
  }

  Widget buildItem(context, index) {
    return Dismissible(
      background: Container(
          color: Colors.red,
          child: Align(
            alignment: Alignment(-0.9, 0.0),
            child: Icon(Icons.delete, color: Colors.white),
          )),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
          value: _todoList[index]["ok"],
          secondary: CircleAvatar(
              child: Icon(_todoList[index]["ok"] ? Icons.check : Icons.error)),
          title: Text(_todoList[index]["title"]),
          onChanged: (value) {
            _checkTask(value, index);
            _saveData();
          }),
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      onDismissed: (direction) {
       setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedIndex = index;
          _todoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Task ${_lastRemoved["title"]} removida."),
            action: SnackBarAction(
              label: "Desfazer", 
              onPressed: () {
                setState(() {
                  _todoList.insert(_lastRemovedIndex, _lastRemoved);
                  _saveData();
                });
              },
            ),
            duration: Duration(seconds: 5)   
          );

          Scaffold.of(context).showSnackBar(snack);
       });
      },
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();

    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();

    return file.writeAsString(data);
  }

  Future<String> _readData() async {
    try {
      final file = await _getFile();

      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
