import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'my_button.dart';

class DialogBox extends StatefulWidget {
  final controller;
  final descController;
  dynamic mediaFile;
  VoidCallback onSave;
  VoidCallback onCancel;
  final Function(DateTime) onDateSelected;
  final Function(String) onFileSelected;
  DateTime? selectedDate;
  String? pickedPath;


  DialogBox({
    super.key,
    required this.controller,
    required this.descController,
    required this.onSave,
    required this.onCancel,
    required this.onDateSelected,
    required this.onFileSelected,
    this.selectedDate,
  });

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  VideoPlayerController? _videoController;
  String? _errorText;

  Future<void> _getMedia(ImageSource source) async {
    final pickedFile = await ImagePicker().pickMedia(
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 88,);

    if (pickedFile != null) {
      if (pickedFile.path.endsWith('.mp4')) {
        _videoController = VideoPlayerController.file(File(pickedFile.path))
          ..initialize().then((_) {
            setState(() {}); // Обновление состояния для отображения видео
            _videoController!.play(); // Автовоспроизведение видео
          });
        widget.mediaFile = _videoController;
      } else {
        widget.mediaFile = File(pickedFile.path);
      }
      widget.pickedPath = pickedFile.path;
      widget.onFileSelected(widget.pickedPath!);
      debugPrint("PICKED FILE PATH=${pickedFile.path}");
      setState(() {

      });
      // setState(() {
      //   widget.mediaFile = null;
      //   widget.pickedPath = null;
      // });
    }
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      content: Container(
        height: 550,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Название",
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: widget.descController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Описание",
              ),
            ),
            ElevatedButton(
              onPressed: () => _getMedia(ImageSource.gallery),
              child: const Text('Выбрать мультимедиа'),
            ),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: widget.mediaFile != null
                  ? widget.mediaFile is VideoPlayerController
                      ? VideoPlayer(widget.mediaFile)
                      : Image.file(
                          widget.mediaFile,
                          fit: BoxFit.cover,
                        )
                  : SizedBox(),
            ),
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: widget.selectedDate ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != widget.selectedDate) {
                  widget.onDateSelected(picked);
                  setState(() {
                    widget.selectedDate = picked;
                  });
                }
              },
              child: Text('Сделать до: ${widget.selectedDate != null ? DateFormat('dd.MM.yyyy').format(widget.selectedDate!) : "нет даты"}'),
            ),
            if (_errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_errorText!, style: TextStyle(color: Colors.red, fontSize: 14)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MyButton(text: "Сохранить", onPressed: () {
                  if (widget.selectedDate == null) {
                    setState(() {
                      _errorText = 'Пожалуйста, выберите дату.';
                    });
                  } else {
                    setState(() {
                      widget.selectedDate = null;
                      widget.pickedPath = null;
                      widget.mediaFile = null;
                      _errorText = null;
                    });
                    widget.onSave();
                  }
                }),
                const SizedBox(width: 8),
                MyButton(text: "Отмена", onPressed: () {
                  setState(() {
                    widget.mediaFile = null;
                    widget.pickedPath = null;
                    widget.selectedDate = null;
                    _errorText = null;
                  });
                  widget.onCancel();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
