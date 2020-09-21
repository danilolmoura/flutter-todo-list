import 'dart:convert';

import 'package:todo_list/models/Item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TODO List',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  var items = new List<Item>();

  HomePage() {
    items = [];
  }
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var totalPicesCtrl = TextEditingController();
  var piecePriceCtrl = TextEditingController();

  _HomePageState() {
    load();
  }

  void add() {
    if (totalPicesCtrl.text.isEmpty) return;

    setState(() {
      widget.items.add(
        Item(title: totalPicesCtrl.text, done: false),
      );
      totalPicesCtrl.clear();
    });
    save();
  }

  void remove(int index) {
    setState(() {
      widget.items.removeAt(index);
    });
    save();
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getString('data');

    if (data != null) {
      Iterable decoded = jsonDecode(data);
      List<Item> result = decoded.map((x) => Item.fromJson(x)).toList();

      setState(() {
        widget.items = result;
      });
    }
  }

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString('data', jsonEncode(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TextFormField(
          controller: totalPicesCtrl,
          keyboardType: TextInputType.number,
          style: TextStyle(color: Colors.white, fontSize: 18),
          decoration: InputDecoration(
            labelText: "New Task",
            labelStyle: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (BuildContext ctx, int index) {
          final item = widget.items[index];
          return Dismissible(
            child: CheckboxListTile(
              title: Text(item.title),
              value: item.done,
              onChanged: (value) {
                setState(() {
                  item.done = value;
                });
                save();
              },
            ),
            key: Key(item.title),
            background: Container(
              color: Colors.red.withOpacity(0.2),
            ),
            onDismissed: (direction) {
              remove(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: add,
        child: Icon(Icons.plus_one),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
