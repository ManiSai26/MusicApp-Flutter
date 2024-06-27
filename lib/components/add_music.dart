import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class AddMusic extends StatefulWidget {
  @override
  _AddMusicState createState() => _AddMusicState();
}

class _AddMusicState extends State<AddMusic> {
  TextEditingController _artistController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  File? _musicFile;
  File? _coverImageFile;
  final storageRef = FirebaseStorage.instance.ref();
  var db = FirebaseFirestore.instance;
  bool isLoading = false;

  void _pickMusicFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _musicFile = File(result.files.single.path!);
      });
    }
  }

  void _pickCoverImageFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _coverImageFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> _submitDetails() async {
    if (_musicFile == null || _coverImageFile == null) return;
    setState(() {
      isLoading = true;
    });
    // Gather input data
    String artistName = _artistController.text;
    String title = _titleController.text;
    int id = 0;
    await db
        .collection('Music')
        .orderBy('id', descending: true)
        .limit(1)
        .get()
        .then((docs) {
      id = docs.docs[0].data()['id'];
    });
    id += 1;
    final musicRef = storageRef.child(_musicFile!.path.split('/').last);
    await musicRef.putFile(_musicFile!);
    final String musicurl = await musicRef.getDownloadURL();
    final ImageRef = storageRef.child(_coverImageFile!.path.split('/').last);
    await ImageRef.putFile(_coverImageFile!);
    final imageurl = await ImageRef.getDownloadURL();
    // Prepare data object
    Map<String, dynamic> data = {
      'id': id,
      'artist': artistName,
      'title': title,
      'url': musicurl,
      'artwork': imageurl,
    };

    // Convert data to JSON

    // Print JSON data
    print(data);
    await db.collection('Music').doc().set(data);
    setState(() {
      isLoading = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Music'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingAnimationWidget.threeArchedCircle(
                        color: Colors.black, size: 120),
                    Text("Uploading....")
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _artistController,
                    decoration: const InputDecoration(
                      labelText: 'Artist Name',
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: _pickMusicFile,
                    child: Text(_musicFile == null
                        ? 'Pick Music File'
                        : 'Music File Selected'),
                  ),
                  const SizedBox(height: 12.0),
                  ElevatedButton(
                    onPressed: _pickCoverImageFile,
                    child: Text(_coverImageFile == null
                        ? 'Pick Cover Image'
                        : 'Cover Image Selected'),
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _submitDetails,
                    child: const Text('Submit'),
                  ),
                ],
              ),
      ),
    );
  }
}
