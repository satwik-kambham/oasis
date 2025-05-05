import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:oasis/widgets/recoder.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oasis',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String _dir = '';

  @override
  void initState() {
    super.initState();
  }

  Future<String> _loadState() async {
    final prefs = SharedPreferencesAsync();
    final recordingDir = await prefs.getString('recordings_dir') ?? '';

    return recordingDir;
  }

  @override
  Widget build(BuildContext context) {
    if (_dir.isEmpty && !kIsWeb) {
      _loadState().then((recordingDir) async {
        if (recordingDir.isEmpty) {
          await Permission.manageExternalStorage.request();
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Recoding directory not set!'),
                actions: [
                  TextButton(
                    child: const Text('Choose'),
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final recordingDir =
                          await FilePicker.platform.getDirectoryPath() ?? '';
                      debugPrint('Setting Recording Dir: $recordingDir');
                      final prefs = SharedPreferencesAsync();
                      await prefs.setString('recording_dir', recordingDir);
                      setState(() {
                        _dir = recordingDir;
                      });
                      navigator.pop();
                    },
                  ),
                ],
              );
            },
            barrierDismissible: false,
          );
        } else {
          setState(() {
            _dir = recordingDir;
          });
        }
      });
    }

    return Scaffold(
      body: Center(
        child: Recoder(
          dir: _dir,
        ),
      ),
    );
  }
}
