import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class VlcScreen extends StatefulWidget {
  const VlcScreen({Key? key}) : super(key: key);

  @override
  State<VlcScreen> createState() => _VlcScreenState();
}

class _VlcScreenState extends State<VlcScreen> {
  final TextEditingController textController = TextEditingController();
  bool _isPlaying = false;
  late VlcPlayerController vlcController;

  @override
  void initState() {
    super.initState();
    vlcController = VlcPlayerController.network(
      '', 
      autoPlay: false,
      options: VlcPlayerOptions(),
    );
    
  }


  

  @override
  void dispose() {
    
    textController.dispose();
    vlcController.dispose();
    super.dispose();
  }

  Future<void> playStream(String url) async {
    try {
      await vlcController.setMediaFromNetwork(url);
      await vlcController.play();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Error starting stream: $e');
    }
  }

  Future<void> stopStream() async {
    await vlcController.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Stream Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: 'Stream URL',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final url = textController.text;
                if (url.isNotEmpty) {
                  await playStream(url);
                }
              },
              child: const Text('Play Stream'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isPlaying = !_isPlaying;
                    });
                    if (_isPlaying) {
                      vlcController.play();
                    } else {
                      vlcController.pause();
                    }
                  },
                
                  icon: Icon( _isPlaying?Icons.pause:Icons.play_arrow),
                  tooltip: 'Play',
                ),
                // IconButton(
                //   onPressed: () => vlcController.pause(),
                //   icon: const Icon(Icons.pause),
                //   tooltip: 'Pause',
                // ),
                IconButton(
                  onPressed: stopStream,
                  icon: const Icon(Icons.stop),
                  tooltip: 'Stop',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GestureDetector(
                onTap: ()  {
                  
                  if (_isPlaying) {
                     vlcController.pause();
                  } else {
                     vlcController.play();
                  }
                },
                child: VlcPlayer(
                  controller: vlcController,
                  aspectRatio: 16 / 9,
                  placeholder: const Center(child: CircularProgressIndicator()),
                ),
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
 
