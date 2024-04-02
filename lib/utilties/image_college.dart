import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageUtils {
  static Future<ui.Image> collage(List<ui.Image> images, ui.Size size) async {
    final rows = images.length < 3 ? 1 : 2;
    final columns = (images.length / rows).round();
    final tileSize = ui.Size(
      size.width / columns,
      size.height / rows,
    );

    final recorder = ui.PictureRecorder();
    final canvas =
        Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white);

    for (var index = 0; index < images.length; index++) {
      final image = images[index];
      final targetRect = Rect.fromLTWH(
        (index % columns) * tileSize.width,
        (index ~/ columns) * tileSize.height,
        tileSize.width,
        tileSize.height,
      );
      final scaledImage = await ImageUtils.scaled(image, tileSize);
      canvas.drawImage(scaledImage, targetRect.topLeft, Paint());
    }

    final picture = recorder.endRecording();
    final img = picture.toImage(size.width.toInt(), size.height.toInt());
    return img;
  }

  static Future<ui.Image> scaled(ui.Image image, ui.Size newSize) async {
    final size = Size(image.width.toDouble(), image.height.toDouble());

    if (size == newSize) {
      return image;
    }

    final ratio = max(newSize.width / size.width, newSize.height / size.height);
    final width = size.width * ratio;
    final height = size.height * ratio;

    final scaledRect = Rect.fromLTWH(
      (newSize.width - width) / 2.0,
      (newSize.height - height) / 2.0,
      width,
      height,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, scaledRect);

    canvas.scale(ratio);
    canvas.drawImage(image, scaledRect.topLeft, Paint());

    final picture = recorder.endRecording();
    final img =
        picture.toImage(scaledRect.width.toInt(), scaledRect.height.toInt());
    return img;
  }
}
