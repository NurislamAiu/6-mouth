import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PhotoStorageService {
  Future<String> persistPickedPhoto({
    required String sourcePath,
    required String slot,
  }) async {
    final directory = await getApplicationDocumentsDirectory();
    final photosDirectory = Directory(path.join(directory.path, 'photos'));
    if (!await photosDirectory.exists()) {
      await photosDirectory.create(recursive: true);
    }

    final extension = path.extension(sourcePath).isEmpty
        ? '.jpg'
        : path.extension(sourcePath);
    final fileName =
        '${slot}_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destination = path.join(photosDirectory.path, fileName);
    return File(sourcePath).copy(destination).then((file) => file.path);
  }
}
