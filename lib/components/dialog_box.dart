import 'package:flutter/material.dart';

import 'my_button.dart';


class DialogBox extends StatelessWidget {
  final controller;
  final descController;
  VoidCallback onSave;
  VoidCallback onCancel;
  final Function(DateTime) onDateSelected;

  DateTime? selectedDate;
  DialogBox({
    super.key,
    required this.controller,
    required this.descController,
    required this.onSave,
    required this.onCancel,
    required this.onDateSelected,
    this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // get user input
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Название",
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Описание",
              ),
            ),

            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate) {
                  onDateSelected(picked);
                }
              },
              child: Text(selectedDate != null ? 'Изменить дату' : 'Добавить дату'),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(text: "Сохранить", onPressed: onSave),

                const SizedBox(width: 8),

                MyButton(text: "Отмена", onPressed: onCancel),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
