import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SegundaRota extends StatefulWidget {
  @override
  _SegundaRotaState createState() => _SegundaRotaState();
}

class _SegundaRotaState extends State<SegundaRota> {
  final _toDoController = TextEditingController();

  Map<String, dynamic> _lastRemove;
  int _lastRemovePos;

  List _toDoList = [];

  @override
  void initState() {
    super.initState();

    _realData().then((data){
      setState(() {
        _toDoList = json.decode(data);
      });
    });
  }

  void _addToDo(){
    setState(() {
      Map<String, dynamic> newToDo = Map();
      newToDo["title"] = _toDoController.text;
      _toDoController.text = "";
      newToDo["ok"] = false;
      _toDoList.add((newToDo));
      _saveData();
    });
  }

  Future<Null> _refresh() async{
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _toDoList.sort((a, b){
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
      });
      _saveData();
    });
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: RefreshIndicator(onRefresh: _refresh,
          child: ListView.builder(
              padding: EdgeInsets.only(top: 10.0),
              itemCount: _toDoList.length,
              itemBuilder: buildItem),
          ),
    );
  }

  Widget buildItem(context, index){
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment(-0.86, 0.0),
          child: Icon(Icons.delete, color: Colors.white),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_toDoList[index]["title"]),
        value: _toDoList[index]["ok"],
        secondary: CircleAvatar(
            child: Icon(_toDoList[index]["ok"]?
            Icons.check : Icons.error)),
        onChanged: (c){
          setState(() {
            _toDoList[index]["ok"] = c;
            _saveData();
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemove = Map.from(_toDoList[index]);
          _lastRemovePos = index;
          _toDoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text("Tarefa \"${_lastRemove["title"]}\" removida!"),
            action: SnackBarAction(
              label: "Desfazer",
              onPressed: (){
                setState(() {
                  _toDoList.insert(_lastRemovePos, _lastRemove);
                  _saveData();
                });
              },
            ),
            duration: Duration(
                seconds: 2
            ),
          );
          Scaffold.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async{
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async{
    String data = json.encode(_toDoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> _realData() async{
    try{
      final file = await _getFile();

      return file.readAsString();
    } catch(e){
      return null;
    }
  }
}
