import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

String getStatusProperName(String status) {
  switch (status) {
    case "done":
      return "Готово";
    case "active":
      return "В процессе";
    case "todo":
      return "Сделать";
    default:
      return "...";
  }
}


class ToDoTile extends StatelessWidget {
  final String taskName;
  final String taskStatus;
  final String taskDescription;
  final DateTime deadline;


  final bool taskCompleted;
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteFunction;
  Function (BuildContext)? updateFunction;

  ToDoTile({
    super.key,
    required this.taskName,
    required this.taskStatus,
    required this.taskDescription,
    required this.taskCompleted,
    required this.onChanged,
    required this.deleteFunction,
    required this.updateFunction,
    required this.deadline
  });




  Color getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return Colors.red;
      case 'active':
        return Colors.yellow;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String truncateWithEllipsis(int cutoff, String myString) {
    return (myString.length <= cutoff)
        ? myString
        : '${myString.substring(0, cutoff)}...';
  }

  Color getDeadlineColor(DateTime deadline) {
    final now = DateTime.now();
    var difference = deadline.difference(now).inDays;
    difference = difference.abs();

    if (2 < difference && difference <= 4 ) {
      return const Color(0xFFF0F1A5).withOpacity(0.5);
    }
    else if (difference <= 2) {
      return const Color(0xFFF4595B).withOpacity(0.5);
    }
    return const Color(0xFFF4595B).withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: updateFunction,
              icon: Icons.edit,
              backgroundColor: Colors.blue.shade200,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [

            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red.shade300,
              borderRadius: BorderRadius.circular(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: taskStatus != "done" ? getDeadlineColor(deadline) : Colors.transparent,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // task name
              Column(
                children: [
                  Text(
                    truncateWithEllipsis(23, taskName),
                    style: TextStyle(
                      decoration: taskCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  SizedBox(height: 10,),
                  Text(
                    'Сделать до: ${DateFormat('dd.MM.yyyy').format(deadline)}', // Format the date
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Checkbox(
                    value: taskCompleted,
                    onChanged: onChanged,
                    activeColor: Colors.black,
                  ),
                  Container(
                    width: 30,
                    height: 10,
                    decoration: BoxDecoration(
                      color: getColorForStatus(taskStatus),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10)
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
