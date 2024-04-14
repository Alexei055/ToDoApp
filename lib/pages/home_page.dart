import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:todoapp/components/todo_tile.dart';

import '../components/dialog_box.dart';
import '../data/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _myBox = Hive.box('mybox');
  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    if (_myBox.get("TODOLIST") == null) {
      db.createInitialData();
    } else {
      db.loadData();
    }

    super.initState();
  }

  final _controller = TextEditingController();
  final _descController = TextEditingController();

  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList[index][1] = !db.toDoList[index][1];
      db.toDoList[index][2] = db.toDoList[index][2] != 'done' ? 'done' : 'todo';
    });
    db.updateDataBase();
  }

  void saveNewTask() {
    setState(() {

      db.toDoList.add([
        _controller.text,
        false,
        'todo',
        _descController.text,
        _selectedDeadline
      ]);
      _controller.clear();
      _descController.clear();
    });

    Navigator.of(context).pop();
    db.updateDataBase();
  }

  DateTime? _selectedDeadline;

  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          descController: _descController,
          onSave: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
          onDateSelected: (newDate) {
            setState(() {
              _selectedDeadline = newDate;
            });
          },
          selectedDate: _selectedDeadline,
        );
      },
    );
  }

  Future<void> showEditDialog(
      BuildContext context,
      String currentName,
      String currentStatus,
      String currentDescription,
      DateTime currentDeadline,
      Function(String, String, String, DateTime) onConfirm) async {
    TextEditingController nameController =
        TextEditingController(text: currentName);
    TextEditingController descriptionController =
        TextEditingController(text: currentDescription);
    String selectedStatus = currentStatus;
    DateTime selectedDeadline = currentDeadline;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text("Редактировать задачу"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Имя задачи"),
                ),
                const SizedBox(height: 10,),
                DropdownButton<String>(
                  value: selectedStatus,
                  onChanged: (String? newValue) {
                    setDialogState(() {
                      selectedStatus = newValue!;
                    });
                  },
                  items: <String>['todo', 'active', 'done']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(getStatusProperName(value)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10,),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: "Описание"),
                ),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? newDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDeadline,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (newDate != null) {
                      selectedDeadline = newDate;
                    }
                  },
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(currentDeadline),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Отмена"),
              ),
              TextButton(
                onPressed: () {
                  onConfirm(nameController.text, selectedStatus,
                      descriptionController.text, selectedDeadline);
                  Navigator.of(context).pop();
                },
                child: const Text("Сохранить"),
              ),
            ],
          );
        });
      },
    );
  }

  void showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Удалить задачу"),
          content: const Text("Вы уверены, что хотите удалить эту задачу?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(context).pop(); // Закрывает диалоговое окно
              },
            ),
            TextButton(
              child: const Text("Удалить"),
              onPressed: () {
                setState(() {
                  db.toDoList.removeAt(index);
                });
                db.updateDataBase();

                Navigator.of(context).pop(); // Закрывает диалоговое окно после удаления
              },
            ),
          ],
        );
      },
    );
  }


  void updateTask(BuildContext context, int index) {
    showEditDialog(context, db.toDoList[index][0], db.toDoList[index][2],
        db.toDoList[index][3], db.toDoList[index][4], (String newName,
            String newStatus, String newDescription, DateTime newDeadline) {
      setState(() {
        db.toDoList[index] = [
          newName,
          db.toDoList[index][1],
          newStatus,
          newDescription,
          newDeadline
        ];
        if (newStatus == "done") {
          db.toDoList[index][1] = true;
        } else {
          db.toDoList[index][1] = false;
        }
        db.updateDataBase();
      });
    });
  }


  void showToDoDetails(
      String name,
      bool isChecked,
      String status,
      String description,
      DateTime? deadline,
      dynamic Function(bool?)? onChanged) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                name,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Статус: $status',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                'Описание: $description',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                'Сделать до: ${deadline != null ? DateFormat('dd.MM.yyyy').format(deadline) : 'отсутсвует'}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('To Do'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => showToDoDetails(
                db.toDoList[index][0],
                db.toDoList[index][1],
                db.toDoList[index][2],
                db.toDoList[index][3],
                db.toDoList[index][4],
                (bool? newValue) => checkBoxChanged(newValue, index)),
            child: ToDoTile(
              taskName: db.toDoList[index][0],
              taskCompleted: db.toDoList[index][1],
              taskStatus: db.toDoList[index][2],
              taskDescription: db.toDoList[index][3],
              deadline: db.toDoList[index][4],
              onChanged: (value) => checkBoxChanged(value, index),
              deleteFunction: (context) => showDeleteDialog(context, index),
              updateFunction: (context) => updateTask(context, index),
            ),
          );
        },
      ),
    );
  }
}
