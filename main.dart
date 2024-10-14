import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  String videoUrl = 'https://fatmux.com/video/g.mp4'; // Sunucudaki video linki
  File? _videoFile;

  @override
  void initState() {
    super.initState();
    _downloadAndPlayVideo();
  }

  Future<void> _downloadAndPlayVideo() async {
    // Videoyu cihazın dosya sistemine indir
    final dir = await getApplicationDocumentsDirectory();
    final videoFile = File('${dir.path}/downloaded_video.mp4');

    // Eğer önceki video varsa, sil
    if (await videoFile.exists()) {
      await videoFile.delete(); // Eski video siliniyor
    }

    // Videoyu internetten indir
    final response = await http.get(Uri.parse(videoUrl));
    await videoFile.writeAsBytes(response.bodyBytes);

    // İndirilen video dosyasını oynatıcıya bağla
    _controller = VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
        _controller.play(); // Otomatik olarak videoyu oynat
      });

    setState(() {
      _videoFile = videoFile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(), // Video yüklenene kadar gösterilen öğe
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose(); // Bellek sızıntısını önlemek için denetleyiciyi boşalt
  }
}
