import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcScreen extends StatefulWidget {
  const VlcScreen({Key? key}) : super(key: key);

  @override
  State<VlcScreen> createState() => _VlcScreenState();
}

class _VlcScreenState extends State<VlcScreen> {
  final TextEditingController httpController = TextEditingController();
  final TextEditingController rtspController = TextEditingController();
  late VlcPlayerController vlcController;

  @override
  void initState() {
    super.initState();
    vlcController = VlcPlayerController.network('', autoPlay: false);
  }

  @override
  void dispose() {
    httpController.dispose();
    rtspController.dispose();
    vlcController.dispose();
    super.dispose();
  }

  void playStream(String url) {
    vlcController.setMediaFromNetwork(url);
    vlcController.play();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VLC Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: httpController,
              decoration: const InputDecoration(
                labelText: 'HTTP Stream URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rtspController,
              decoration: const InputDecoration(
                labelText: 'RTSP Stream URL',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final url = httpController.text.isNotEmpty
                    ? httpController.text
                    : rtspController.text;
                if (url.isNotEmpty) {
                  playStream(url);
                }
              },
              child: const Text('Play Stream'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: VlcPlayer(
                controller: vlcController,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// https://media.w3.org/2010/05/sintel/trailer.mp4
// rtsp://admin:hikvision nvr@192.168.20.36
 