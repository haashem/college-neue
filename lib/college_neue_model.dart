import 'dart:async';

import 'package:college_neue/utilties/image_college.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:ui' as ui;

import 'package:rxdart/rxdart.dart';

class CollegeNeueModel {
  final previewImage = ValueNotifier<ui.Image?>(null);
  final photosCount = ValueNotifier<int>(0);

  final _subscriptions = CompositeSubscription();
  final _images = BehaviorSubject<List<ui.Image>>.seeded([]);
  Size canvasSize = Size.zero;

  void bindMainView() {
    final subscription = _images.stream
        .doOnData((event) {
          photosCount.value = event.length;
        })
        .asyncMap((images) => images.isEmpty
            ? Future.value()
            : ImageUtils.collage(images, canvasSize))
        .listen((collegeImage) => previewImage.value = collegeImage);

    _subscriptions.add(subscription);
  }

  Future<void> add() async {
    assert(canvasSize != Size.zero,
        'Canvas size must be set before adding images');
    final byteData = await rootBundle.load('assets/IMG_1907.jpg');
    final codec = await ui.instantiateImageCodec(byteData.buffer.asUint8List());
    final frameInfo = await codec.getNextFrame();
    final newImage = frameInfo.image;

    _images.add(_images.value..add(newImage));
  }

  void clear() {
    _images.add([]);
  }

  void save() {}

  void dispose() {
    previewImage.dispose();
    photosCount.dispose();
    _subscriptions.dispose();
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
