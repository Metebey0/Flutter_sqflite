import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttersqfliteexample/utils/dbhelper.dart';
import 'package:fluttersqfliteexample/models/car.dart';
import 'package:sqflite/sqflite.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Car> cars = [];
  List<Car> carsByName = [];

  TextEditingController nameController = TextEditingController();
  TextEditingController milesController = TextEditingController();
  TextEditingController queryController = TextEditingController();
  TextEditingController idUpdateController = TextEditingController();
  TextEditingController nameUpdateController = TextEditingController();
  TextEditingController milesUpdateController = TextEditingController();
  TextEditingController idDeleteController = TextEditingController();

  void _showMessageInScaffold(String message) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text("Car App - SQFLite"),
          bottom: const TabBar(
            tabs: [
              Tab(
                text: "Insert",
              ),
              Tab(
                text: "View",
              ),
              Tab(
                text: "Query",
              ),
              Tab(
                text: "Update",
              ),
              Tab(
                text: "Delete",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: milesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car Miles',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: const Text("Insert Car Details"),
                    onPressed: () {
                      String name = nameController.text;
                      int miles = int.parse(milesController.text);
                      _insert(name, miles);
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: cars.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == cars.length) {
                    return ElevatedButton(
                      child: const Text('Refresh'),
                      onPressed: () {
                        setState(() {
                          _queryAll();
                        });
                      },
                    );
                  }
                  return Container(
                    height: 40,
                    child: Center(
                      child: Text(
                        '[${cars[index].id}] ${cars[index].name} - ${cars[index].miles} miles',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: queryController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Car Name'),
                      onChanged: (text) {
                        if (text.length >= 2) {
                          setState(() {
                            _query(text);
                          });
                        } else {
                          setState(() {
                            carsByName.clear();
                          });
                        }
                      },
                    ),
                    height: 100,
                  ),
                  Expanded(
                    child: Container(
                      height: 300,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: carsByName.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            height: 50,
                            margin: EdgeInsets.all(2),
                            child: Center(
                              child: Text(
                                '[${carsByName[index].id}] ${carsByName[index].name} - ${carsByName[index].miles} miles',
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: idUpdateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: nameUpdateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car Name',
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: milesUpdateController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Car Miles',
                        ),
                      ),
                    ),
                    ElevatedButton(
                      child: const Text("Update Car Details"),
                      onPressed: () {
                        int id = int.parse(idUpdateController.text);
                        String name = nameUpdateController.text;
                        int miles = int.parse(milesUpdateController.text);
                        _update(id, name, miles);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: idDeleteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Car id',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    child: Text('Delete'),
                    onPressed: () {
                      int id = int.parse(idDeleteController.text);
                      _delete(id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insert(String name, int miles) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnName: name,
      DatabaseHelper.columnMiles: miles
    };

    Car car = Car.fromMap(row);
    final id = await dbHelper.insert(car);
    _showMessageInScaffold('inserted row id $id');
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    cars.clear();
    allRows?.forEach((row) => cars.add(Car.fromMap(row)));
    _showMessageInScaffold("Query done.");
    setState(() {});
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    carsByName.clear();
    allRows?.forEach((row) => carsByName.add(Car.fromMap(row)));
  }

  void _update(int id, String name, int miles) async {
    Car car = Car(id, miles, name);
    final rowsAffected = await dbHelper.update(car);
    _showMessageInScaffold("updated $rowsAffected row(s)");
  }

  void _delete(int id) async {
    final rowsDeleted = await dbHelper.delete(id);
    _showMessageInScaffold('deleted $rowsDeleted row(s): row $id');
  }
}
