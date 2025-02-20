import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Demo extends StatefulWidget {
  const Demo({Key? key}) : super(key: key);
  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isDoorLocked = true;
  late VlcPlayerController vlcController;

  final String streamUrl = 'rtsp://admin:hikvision nvr@192.168.20.36';
  final String baseUrl = 'http://192.168.20.8:4369';
  final String macAddress = '00:1A:2B:3C:4D:5F';

  @override
  void initState() {
    super.initState();
    vlcController = VlcPlayerController.network(
      streamUrl,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    // Listen for player events
    vlcController.addListener(_onPlayerChange);
  }

  void _onPlayerChange() {
    if (vlcController.value.isPlaying && _isLoading) {
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    }
  }

  @override
  void dispose() {
    vlcController.removeListener(_onPlayerChange);
    vlcController.dispose();
    super.dispose();
  }

  Future<void> _toggleDoor() async {
    try {
      final command = _isDoorLocked ? 'open' : 'close';
      final response = await http.get(
        Uri.parse('$baseUrl/$command/$macAddress'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _isDoorLocked = !_isDoorLocked;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Door ${_isDoorLocked ? 'locked' : 'unlocked'} successfully'
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          _showError('Failed to control door');
        }
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error controlling door: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DOOR LOCK DEMO'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPlaying = !_isPlaying;
                      });
                      _isPlaying ? vlcController.play() : vlcController.pause();
                    },
                    child: VlcPlayer(
                      controller: vlcController,
                      aspectRatio: 16 / 9,
                      placeholder: const Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  if (_isLoading)
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.white),
                          SizedBox(height: 16),
                          Text(
                            'Loading Stream...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleDoor,
                  icon: Icon(_isDoorLocked ? Icons.lock_open : Icons.lock),
                  label: Text(_isDoorLocked ? 'Unlock Door' : 'Lock Door'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isDoorLocked ? Colors.green : Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _isDoorLocked
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isDoorLocked ? Icons.lock : Icons.lock_open,
                        color: _isDoorLocked ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status: ${_isDoorLocked ? 'Locked' : 'Unlocked'}',
                        style: TextStyle(
                          color: _isDoorLocked ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
// https://media.w3.org/2010/05/sintel/trailer.mp4
// rtsp://admin:hikvision nvr@192.168.20.36
