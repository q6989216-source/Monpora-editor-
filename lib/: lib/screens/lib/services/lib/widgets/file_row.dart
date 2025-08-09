import 'dart:io';
import 'package:flutter/material.dart';

class FileRow extends StatelessWidget {
  final File file;
  final String label;
  final VoidCallback? onTap;
  const FileRow({super.key, required this.file, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text('$label: ${file.path}', overflow: TextOverflow.ellipsis)),
        IconButton(onPressed: onTap, icon: const Icon(Icons.play_arrow))
      ],
    );
  }
}
