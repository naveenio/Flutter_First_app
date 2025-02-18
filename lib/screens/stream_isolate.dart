import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class StreamIso extends StatefulWidget {
  const StreamIso({super.key});

  @override
  State<StreamIso> createState() => _StreamIsoState();
}

class _StreamIsoState extends State<StreamIso> {
  final TextEditingController _urlController = TextEditingController();
  List<VlcPlayerController> _vlcControllers = [];
  List<String> _streamUrls = [];

  late VlcPlayerController vlcController;

  void _addStream(String url) {
    if (url.isEmpty) return;

    final receivePort = ReceivePort();
    Isolate.spawn(complexTask, (url: url, sendPort: receivePort.sendPort));
    receivePort.listen((newController) {
      debugPrint('Result 3: $newController');
      setState(() {
        _vlcControllers.add(newController);
        _streamUrls.add(url);
      });
    });
  }
  // void _removeStream(int index) {
  //   setState(() {
  //     _vlcControllers[index].dispose();
  //     _vlcControllers.removeAt(index);
  //     _streamUrls.removeAt(index);
  //   });
  // }

  void _removeStream(int index) {
    final controllerToDispose = _vlcControllers[index];

    setState(() {
      _vlcControllers.removeAt(index);
      _streamUrls.removeAt(index);

      controllerToDispose.dispose();
    });
  }

  @override
  void dispose() {
    for (var controller in _vlcControllers) {
      controller.dispose();
    }
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isolate -Stream Player'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'Enter stream URL',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addStream(_urlController.text),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _streamUrls.length,
              itemBuilder: (context, index) {
                return _buildPlayerCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(int index) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: VlcPlayer(
              controller: _vlcControllers[index],
              aspectRatio: 16 / 9,
              placeholder: const Center(child: CircularProgressIndicator()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(_vlcControllers[index].value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow),
                  onPressed: () => _togglePlayPause(index),
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () => _toggleStop(index),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => _removeStream(index),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      _streamUrls[index],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _togglePlayPause(int index) async {
    if (_vlcControllers[index].value.isPlaying) {
      await _vlcControllers[index].pause();
    } else {
      await _vlcControllers[index].play();
    }
  }

  void _toggleStop(int index) async {
    if (_vlcControllers[index].value.isPlaying) {
      await _vlcControllers[index].stop();
    } else {}
  }
}

complexTask(({String url, SendPort sendPort}) data) {
  final newController = VlcPlayerController.network(
    data.url,
    autoPlay: true,
    options: VlcPlayerOptions(),
  );

  data.sendPort.send(newController);
}
