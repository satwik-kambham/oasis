import 'dart:async';

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
  StreamSubscription<RecordState>? _recordSub;
  RecordState _recordState = RecordState.stop;
  List<DropdownMenuEntry<InputDevice>> _inputDevices = [];
  InputDevice? _inputDevice;

  @override
  void initState() {
    _audioRecorder = AudioRecorder();
    _recordSub = _audioRecorder.onStateChanged().listen((recordState) {
      setState(() {
        _recordState = recordState;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordSub?.cancel();
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

      await _audioRecorder.start(
          RecordConfig(
            encoder: AudioEncoder.wav,
            device: _inputDevice,
            sampleRate: 16000,
          ),
          path: path);
    }
  }

  Future<void> _stop() async {
    final path = await _audioRecorder.stop();
  }

  Widget _buildRecordButton() {
    if (_recordState != RecordState.stop) {
      return IconButton(
        icon: const Icon(Icons.stop, size: 30),
        onPressed: () {
          _stop();
        },
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.mic, size: 30),
        onPressed: () {
          _start();
        },
      );
    }
  }

  Widget _refreshInputDevices() {
    return IconButton(
      icon: const Icon(Icons.refresh, size: 30),
      onPressed: () async {
        final inputDevices = await _audioRecorder.listInputDevices();
        setState(() {
          _inputDevices = inputDevices.map<DropdownMenuEntry<InputDevice>>(
            (inputDevice) {
              return DropdownMenuEntry<InputDevice>(
                value: inputDevice,
                label: inputDevice.label,
              );
            },
          ).toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            DropdownMenu(
              dropdownMenuEntries: _inputDevices,
              onSelected: (device) {
                _inputDevice = device;
              },
            ),
            _refreshInputDevices(),
          ],
        ),
        const SizedBox(height: 30),
        _buildRecordButton(),
      ],
    );
  }
}
