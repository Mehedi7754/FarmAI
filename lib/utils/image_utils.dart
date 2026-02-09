import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as p;

class ImageUtils {
  static Future<File?> compressImage(File file) async {
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = p.join(dir.absolute.path, "${DateTime.now().millisecondsSinceEpoch}.jpg");

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 768,
      minHeight: 768,
      format: CompressFormat.jpeg,
    );

    if (result == null) return null;
    return File(result.path);
  }
}
