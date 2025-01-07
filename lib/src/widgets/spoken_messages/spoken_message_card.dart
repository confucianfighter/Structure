import 'package:flutter/material.dart';
import '../../data_store.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'package:dart_openai/dart_openai.dart';
import 'dart:io';
import 'package:media_kit/media_kit.dart';
import 'package:Structure/src/utils/audio_helper.dart';

class SpokenMessageCard extends StatefulWidget {
  final SpokenMessage message;

  const SpokenMessageCard({
    super.key,
    required this.message,
  });

  @override
  _SpokenMessageCardState createState() => _SpokenMessageCardState();
}

class _SpokenMessageCardState extends State<SpokenMessageCard> {
  bool _isEditing = false;
  final bool _isRecording = false;
  
  Player? _player;
  final List<String> voiceStyles = [
    'alloy',
    'echo',
    'fable',
    'onyx',
    'nova',
    'shimmer',
  ];
  late SpokenMessage _message;
  @override
  initState() {
    super.initState();
    _message = widget.message;
    if (_message.speed < .25) _message.speed = .25;
    if (_message.speed > 4) _message.speed = 4;
    if (_message.voice == "") _message.voice = 'nova';
    print('message.speed is ${_message.speed}');
    _player = Player();
    _player!.setVolume(100);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for prompt and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.message.text,
                    decoration: const InputDecoration(labelText: 'Prompt'),
                    onChanged: (value) {
                      setState(() {
                        _message.text = value;
                      });
                      Data().store.box<SpokenMessage>().put(_message);
                    },
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.play_arrow),
                    onPressed: () async {
                      playAudio();
                    }),
                IconButton(
                  icon: _isEditing
                      ? const Icon(Icons.edit)
                      : const Icon(Icons.done),
                  onPressed: () => setState(() {
                    _isEditing = !_isEditing;
                  }),
                ),
                IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => Data()
                        .store
                        .box<WritingPrompt>()
                        .remove(widget.message.id)),
                IconButton(
                    icon: _isRecording
                        ? const Icon(Icons.record_voice_over)
                        : const Icon(Icons.record_voice_over_outlined),
                    onPressed: () async {
                      await recordTTS(_message);
                    })
              ],
            ),
            const SizedBox(height: 8.0),
            Text('Speech Speed: ${_message.speed.toStringAsFixed(2)}x'),

            Slider(
              value: _message.speed,
              min: 0.25,
              max: 4.0,
              divisions: 15,
              label: _message.speed.toStringAsFixed(2),
              onChanged: (double value) {
                setState(() {
                  _message.speed = value;
                  Data().store.box<SpokenMessage>().put(_message);
                });
              },
            ),
            Text('Gain: ${_message.gain.toStringAsFixed(2)}x'),

            Slider(
              value: _message.gain,
              min: 0.0,
              max: 5.00,
              divisions: 50,
              label: _message.gain.toStringAsFixed(2),
              onChanged: (double value) {
                setState(() {
                  _message.gain = value;
                  Data().store.box<SpokenMessage>().put(_message);
                  Settings? settings = Settings.get();
                  if(settings == null) print("couldn't find settings.");
                  settings?.openai_tts_gain = value;
                  Settings.set(settings!);
                });
              },
            ),
            // Category
            Text(
              'Category: ${widget.message.category.target?.name ?? "Uncategorized"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            DropdownButton<String>(
              value: _message.voice,
              onChanged: (String? newValue) {
                setState(() {
                  if (newValue != null) {
                    _message.voice = newValue;
                    Data().store.box<SpokenMessage>().put(_message);
                  }
                });
              },
              items: voiceStyles.map<DropdownMenuItem<String>>((String voice) {
                return DropdownMenuItem<String>(
                  value: voice,
                  child: Text(voice),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: _message.category.target?.name ?? "",
              onChanged: (String? newValue) {
                setState(() {
                  final category = Data().store.box<SpokenMessageCategory>().query(SpokenMessageCategory_.name.equals(newValue ?? "")).build().findFirst();
                  if (newValue != null) {
                    _message.category.target = category;
                    Data().store.box<SpokenMessage>().put(_message);
                  }
                });
              },
              items: Data().store.box<SpokenMessageCategory>().getAll().map<DropdownMenuItem<String>>((SpokenMessageCategory category) {
                return DropdownMenuItem<String>(
                  value: category.name,
                  child: Text(category.name),
                );
              }).toList(),
            ),
            // Last answered (optional)
            if (widget.message.lastTimeUsed != null)
              Text(
                'Last Used: ${widget.message.lastTimeUsed!.toLocal()}',
                style: const TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> playAudio() async {
    print("playing audio.");
    String path = ('${getAudioFilePath(_message)}.mpeg');

    final file = File(path);
    final exists = await file.exists();
    if (exists) {
      print("file $path exists. Attempting to adjust gain");
      path = await adjustAudioGain(path, _message.gain);
      final file = File(path);
      if (await file.exists()) {
        print("adjusted file $path exists!");
        await _player!.open(Media(path));
        _player!.play();
      }
    }
  }

  Future<void> recordTTS(SpokenMessage message) async {
    final settings = Data()
        .store
        .box<Settings>()
        .query()
        .order(Settings_.dateModifiedMillis, flags: Order.descending)
        .build()
        .findFirst();
    String path = settings!.homeFolderPath.replaceAll('\\', '/');
    print('home folder path string is: $path');
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    print("OPENAI_API_KEY = $apiKey");
    String fileName = "";
    if (message.audioFilePath != null && message.audioFilePath!.isNotEmpty) {
      fileName = message.audioFilePath ?? "";
    } else {
      fileName = Uuid().v4();
      message.audioFilePath = '$fileName.mpeg';
      Data().store.box<SpokenMessage>().put(message);
    }

    print('filename: $fileName');
    String text = message.text ?? "";
    if (text.trim() == "") return;
    if(_message.category.target != null && _message.category.target!.message_prefix.isNotEmpty)
    {
      text = "${_message.category.target!.message_prefix} $text";
    }
    // print text to file to test if path works
    try {
      // Generate a unique filename

      // Create the speech and save it to the specified file
      File speechFile = await OpenAI.instance.audio.createSpeech(
        model: 'tts-1',
        input: text,
        voice: _message.voice,
        speed: _message.speed,
        // Choose the desired voice
        responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
        outputDirectory: Directory(path),
        outputFileName: fileName,
      );

      print('Audio file saved at: ${speechFile.path}');
    } catch (e) {
      print('An error occurred: $e');
    }
  }

  String getAudioFilePath(SpokenMessage message) {
    final settings = Data()
        .store
        .box<Settings>()
        .query()
        .order(Settings_.dateModifiedMillis, flags: Order.descending)
        .build()
        .findFirst();
    String path = settings!.homeFolderPath.replaceAll('\\', '/');
    print('home folder path string is: $path');
    String fileName = "";
    if (message.audioFilePath != null && message.audioFilePath!.isNotEmpty) {
      fileName = message.audioFilePath ?? "";
    } else {
      fileName = Uuid().v4();
      message.audioFilePath = fileName;
      Data().store.box<SpokenMessage>().put(message);
    }
    path = '$path/$fileName';
    print(path);
    return path;
  }
}
