import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/ffmpeg_service.dart';
import 'package:path_provider/path_provider.dart';

class EditorHome extends StatefulWidget {
  const EditorHome({super.key});

  @override
  State<EditorHome> createState() => _EditorHomeState();
}

class _EditorHomeState extends State<EditorHome> {
  File? video1;
  File? video2;
  File? musicFile;
  String status = 'Ready';
  double start = 0.0;
  double end = 5.0;

  final _ff = FFmpegService();

  Future<bool> _req() async {
    if (Platform.isAndroid) {
      final s = await Permission.storage.request();
      return s.isGranted;
    }
    return true;
  }

  Future<void> pickVideo1() async {
    final ok = await _req();
    if (!ok) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res == null) return;
    setState(() => video1 = File(res.files.single.path!));
  }

  Future<void> pickVideo2() async {
    final ok = await _req();
    if (!ok) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.video);
    if (res == null) return;
    setState(() => video2 = File(res.files.single.path!));
  }

  Future<void> pickMusic() async {
    final ok = await _req();
    if (!ok) return;
    final res = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (res == null) return;
    setState(() => musicFile = File(res.files.single.path!));
  }

  void _setStatus(String s) => setState(() => status = s);

  Future<void> trimVideo() async {
    if (video1 == null) return;
    _setStatus('Trimming...');
    final out = await _ff.trim(video1!, start, end);
    _setStatus('Trim done');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $out')));
  }

  Future<void> mergeVideos() async {
    if (video1 == null || video2 == null) return;
    _setStatus('Merging...');
    final out = await _ff.merge(video1!, video2!);
    _setStatus('Merge done');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $out')));
  }

  Future<void> addText() async {
    if (video1 == null) return;
    _setStatus('Adding text...');
    final out = await _ff.addTextOverlay(video1!, 'Monpora - By You');
    _setStatus('Text added');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $out')));
  }

  Future<void> addMusic() async {
    if (video1 == null || musicFile == null) return;
    _setStatus('Mixing music...');
    final out = await _ff.addBackgroundMusic(video1!, musicFile!, 0.6);
    _setStatus('Music mixed');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $out')));
  }

  Future<void> changeSpeed(double speed) async {
    if (video1 == null) return;
    _setStatus('Changing speed...');
    final out = await _ff.changeSpeed(video1!, speed);
    _setStatus('Speed changed');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved: $out')));
  }

  Future<void> showExportPath() async {
    final dir = await getApplicationDocumentsDirectory();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export path'),
        content: Text('Files saved in: ${dir.path}'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monpora Editor')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Status: $status'),
            const SizedBox(height: 10),
            Row(children: [
              ElevatedButton(onPressed: pickVideo1, child: const Text('Pick Video 1')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: pickVideo2, child: const Text('Pick Video 2')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: pickMusic, child: const Text('Pick Music')),
            ]),
            const SizedBox(height: 12),
            if (video1 != null) Text('Video1: ${video1!.path}'),
            if (video2 != null) Text('Video2: ${video2!.path}'),
            if (musicFile != null) Text('Music: ${musicFile!.path}'),
            const SizedBox(height: 12),
            const Text('Trim controls (seconds)'),
            Row(children: [
              const Text('Start:'),
              Expanded(child: Slider(value: start, min: 0, max: 300, onChanged: (v) => setState(() => start = v))),
              Text('${start.toStringAsFixed(1)}s'),
            ]),
            Row(children: [
              const Text('End:'),
              Expanded(child: Slider(value: end, min: 0.5, max: 600, onChanged: (v) => setState(() => end = v))),
              Text('${end.toStringAsFixed(1)}s'),
            ]),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: trimVideo, child: const Text('Trim')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: mergeVideos, child: const Text('Merge')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: addText, child: const Text('Add Text')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: addMusic, child: const Text('Add Background Music')),
            const SizedBox(height: 8),
            const Text('Speed'),
            Row(children: [
              ElevatedButton(onPressed: () => changeSpeed(0.5), child: const Text('0.5x')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => changeSpeed(1.0), child: const Text('1x')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => changeSpeed(1.5), child: const Text('1.5x')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: () => changeSpeed(2.0), child: const Text('2x')),
            ]),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: showExportPath, child: const Text('Where are exported files?')),
          ]),
        ),
      ),
    );
  }
}
