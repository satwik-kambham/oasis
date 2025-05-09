import 'package:http/http.dart';

Future<String> transcribeAudio(String recordingPath) async {
  final url = Uri.parse('http://192.168.29.209:4123/transcribe');
  final request = MultipartRequest('POST', url)
    ..files.add(await MultipartFile.fromPath('file', recordingPath));
  final response = await request.send();
  final transcription = await response.stream.bytesToString();
  return transcription;
}
