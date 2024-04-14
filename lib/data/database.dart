import 'package:hive_flutter/hive_flutter.dart';

class ToDoDataBase {
  List toDoList = [];

  // reference our box
  final _myBox = Hive.box('mybox');

  // run this method if this is the 1st time ever opening this app
  void createInitialData() {
    toDoList = [
      ["Make Tutorial", false, 'todo',  'Описание типа', DateTime.now().add(Duration(days: 7))],
      ["Make Tutorial 222", false, 'todo',  'Описание типа', DateTime.now().add(Duration(days: 7))],
      ["Make Tutorial 333", false, 'todo',  'Описание типа', DateTime.now().add(Duration(days: 7))],
      ["Make Tutorial 444", false, 'todo',  'Описание типа', DateTime.now().add(Duration(days: 7))],
      ["Do Exercise", false, 'active', 'Описание типа', DateTime.now().add(Duration(days: 7))],
      ["Watch Video", false, 'done', 'Описание типа', DateTime.now().add(Duration(days: 7))],
    ];
  }

  // load the data from database
  void loadData() {
    toDoList = _myBox.get("TODOLIST");
  }

  // update the database
  void updateDataBase() {
    _myBox.put("TODOLIST", toDoList);
  }
}
