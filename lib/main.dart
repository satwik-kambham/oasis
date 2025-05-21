import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';

import 'package:oasis/widgets/recoder.dart';
import 'package:oasis/chat_state.dart';

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
        home: ChangeNotifierProvider(
          create: (context) => ChatState(),
          child: const MyHomePage(title: 'Oasis'),
        ));
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
  final _wsChannel =
      WebSocketChannel.connect(Uri.parse('ws://192.168.29.209:4123/ws'));
  StreamSubscription<dynamic>? _wsSub;
  final _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _wsSub = _wsChannel.stream.listen((message) async {
      if (message is Uint8List) {
        late String path;

        if (kIsWeb) {
          path = '';
        } else {
          path = p.join(
            _dir,
            'tts.wav',
          );
        }

        File file = File(path);
        file.writeAsBytesSync(message, flush: true);

        await _audioPlayer.play(DeviceFileSource(path));
      } else if (message is String) {
        context.read<ChatState>().setResult(message);
      }
    });
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
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
          if (Platform.isAndroid) {
            await Permission.manageExternalStorage.request();
          }
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
        child: Column(
          children: <Widget>[
            Text('Transcript: ${context.watch<ChatState>().transcript}'),
            Recoder(
              dir: _dir,
            ),
            IconButton(
              icon: const Icon(Icons.send, size: 30),
              onPressed: () {
                _wsChannel.sink.add(context.read<ChatState>().transcript);
              },
            ),
            Text('${context.watch<ChatState>().result}'),
          ],
        ),
      ),
    );
  }
}
