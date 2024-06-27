import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mymusic/components/music_component.dart';
import 'package:mymusic/components/add_music.dart';
import 'package:mymusic/components/music_player_component.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Music',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'My Music'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var list = [];
  int current = -1;
  bool currentReloading = false;
  bool isLoading = false;
  var db = FirebaseFirestore.instance;
  Future<void> _refresh() async {
    setState(() {
      currentReloading = true;
      isLoading = true;
    });
    list.clear();
    await db
        .collection('Music')
        .orderBy('id')
        // .limit(15)
        .get()
        .then((docs) {
      for (var doc in docs.docs) {
        list.add(doc.data());
      }
    });
    setState(() {
      list;
      currentReloading = false;
      isLoading = false;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
  }

  void setCurrent(int cur) {
    setState(() {
      current = current != cur ? cur : -1;
    });
    print(current);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddMusic()));
              },
              icon: const Icon(Icons.add)),
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.black, size: 120),
                  const SizedBox(
                    height: 25,
                  ),
                  const Text('Loading....')
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: list.isEmpty
                        ? const Center(
                            child: Text(
                              'No Data',
                              style: TextStyle(fontSize: 35),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: list.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MusicComponent(
                                content: list[index],
                                onClick: setCurrent,
                              );
                            },
                          ),
                  ),
                  Column(
                    children: [
                      Container(
                        child: current == -1
                            ? const SizedBox(
                                height: 15,
                              )
                            : MusicPlayerComponent(
                                url: list[current - 1]['url'],
                                title: list[current - 1]['title'],
                              ),
                      ),
                    ],
                  )
                ],
              ),
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: currentReloading ? null : _refresh,
      //   tooltip: 'Refresh',
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }
}
