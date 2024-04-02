import 'dart:ui';

import 'package:photo_manager/photo_manager.dart';

sealed class PhotoWriterError {}

class CouldNotSavePhoto extends PhotoWriterError {
  @override
  String toString() {
    return 'Could not save photo';
  }
}

class Unknown extends PhotoWriterError {
  final Object error;
  Unknown(this.error);

  @override
  String toString() {
    return 'Unknown error: $error';
  }
}

typedef AssetId = String;

class PhotoWriter {
  static Future<AssetId> save(Image image) async {
    try {
      // Save the photo to the gallery
      final rawData = await image.toByteData(format: ImageByteFormat.png);
      if (rawData == null) {
        throw CouldNotSavePhoto();
      }
      final AssetEntity? entity = await PhotoManager.editor.saveImage(
        rawData.buffer.asUint8List(),
        title: 'college_photo',
      );
      if (entity == null) {
        throw CouldNotSavePhoto();
      }
      return entity.id;
    } on PhotoWriterError {
      rethrow;
    } catch (e, _) {
      throw Unknown(e);
    }
  }
}
