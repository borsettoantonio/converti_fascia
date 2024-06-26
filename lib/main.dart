import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../providers/db_provider.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'providers/paziente_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String testo = '';

  @override
  void initState() {
    super.initState();
    onStart();
  }

  Future<void> onStart() async {
    if (kIsWeb || Platform.isWindows || Platform.isLinux) {
      // Initialize FFI
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    var db = DB();
    var dbInput = await db.openDbInput(message);
    if (testo != '') {
      return;
    }
    var dbOutput = await db.openDbOutput();

    var pazInput = await db.getPazienti(dbInput);
    var pazOutput = Conversione.converti(pazInput);
    await db.scriviPazienti(dbOutput, pazOutput);

    await dbInput.close();
    await dbOutput.close();
    message('Conversione conclusa');
  }

  void message(String txt) {
    setState(() {
      testo = txt;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Converti DB'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(testo, style: const TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
