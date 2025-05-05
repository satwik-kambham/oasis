import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

class Recoder extends StatefulWidget {
  final String dir;
  const Recoder({super.key, required this.dir});

  @override
  State<Recoder> createState() => _RecoderState();
}

class _RecoderState extends State<Recoder> {
  late final AudioRecorder _audioRecorder;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (await _audioRecorder.hasPermission()) {
      late String path;

      if (kIsWeb) {
        path = '';
      } else {
        path = p.join(
          widget.dir,
          'audio_${DateTime.now().millisecondsSinceEpoch}.wav',
        );
      }

      debugPrint(path);
      debugPrint((await _audioRecorder.listInputDevices()).toString());

      await _audioRecorder.start(const RecordConfig(encoder: AudioEncoder.wav),
          path: path);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
    debugPrint('Written to $path');
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.mic),
          onPressed: () {
            _start();
          },
        ),
        const SizedBox(
          width: 20,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          onPressed: () {
            _stop();
          },
        ),
      ],
    );
  }
}
