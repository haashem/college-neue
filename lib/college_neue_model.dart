import 'package:college_neue/utilties/image_college.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:ui' as ui;

import 'package:rxdart/rxdart.dart';

class CollegeNeueModel {
  final previewImage = ValueNotifier<ui.Image?>(null);

  Size canvasSize = Size.zero;

  Future<void> add() async {
    assert(canvasSize != Size.zero,
        'Canvas size must be set before adding images');
  }

  void clear() {}

  void save() {}

  void dispose() {
    previewImage.dispose();
  }

  // Displaying photos picker
  Stream<List<AssetEntity>> get photos => const Stream.empty();

  Future<List<AssetEntity>> loadPhotos() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.hasAccess) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        onlyAll: true,
      );
      final List<AssetEntity> entities = await paths.first.getAssetListPaged(
        page: 0,
        size: 50,
      );
      return entities;
    } else {
      return [];
    }
  }

  void selectImage(AssetEntity asset) {}
}
