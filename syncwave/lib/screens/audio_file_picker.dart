import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';


class AudioFilePicker extends StatelessWidget {
  final Function(String?) onFileSelected;

  const AudioFilePicker({Key? key, required this.onFileSelected})
      : super(key: key);

  Future<void> _pickAudioFile(BuildContext context) async {
    // Pick an audio file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.isNotEmpty) {
      // Get the path of the selected file
      String? filePath = result.files.single.path;
      onFileSelected(filePath);
    } else {
      // If no file was selected
      onFileSelected(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _pickAudioFile(context),
      child: const Text('Select Audio File'),
    );
  }
}
