import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Demov2 extends StatefulWidget {
  const Demov2({Key? key}) : super(key: key);
  @override
  State<Demov2> createState() => _Demov2State();
}

class _Demov2State extends State<Demov2> {
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isDoorLocked = true;
  late VlcPlayerController vlcController;

  final String streamUrl = 'rtsp://192.168.20.20:554';
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
          // Show countdown dialog
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CountdownDialog(
                isLocking: !_isDoorLocked,
              );
            },
          );

          setState(() {
            _isDoorLocked = !_isDoorLocked;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Door ${_isDoorLocked ? 'locked' : 'unlocked'} successfully'),
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
        title: const Text('DOOR LOCK Demov2'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              flex: 3,
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
                      placeholder:
                          const Center(child: CircularProgressIndicator()),
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
            Expanded(
              flex: 2,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleDoor,
                        icon:
                            Icon(_isDoorLocked ? Icons.lock_open : Icons.lock),
                        label:
                            Text(_isDoorLocked ? 'Unlock Door' : 'Lock Door'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isDoorLocked ? Colors.green : Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
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
                                color:
                                    _isDoorLocked ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CountdownDialog extends StatefulWidget {
  final bool isLocking;

  const CountdownDialog({
    Key? key,
    required this.isLocking,
  }) : super(key: key);

  @override
  State<CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<CountdownDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdown = 9;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });
        if (_countdown > 0) {
          _startCountdown();
        } else {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
              turns: _controller,
              child: Icon(
                widget.isLocking ? Icons.lock : Icons.lock_open,
                size: 48,
                color: widget.isLocking ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.isLocking ? 'Locking Door...' : 'Unlocking Door...',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              '$_countdown',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
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
