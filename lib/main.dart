import 'package:flutter/material.dart';
import 'screens/screen_routes.dart';

void main() {
  runApp(PublicApisApp());
}

class PublicApisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Public APIs Explorer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MainScreen(),
    );
  }
}



// ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Td:\projects-flutter\flutter_isolates_demo\assetsext("Invalid stream URL: $url")),
//       );