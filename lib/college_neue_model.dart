import 'dart:async';

import 'package:college_neue/utilties/image_college.dart';
import 'package:college_neue/utilties/photo_writer.dart';
import 'package:flutter/material.dart';
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
    selectedPhotosSubject = PublishSubject<ui.Image>();
    final newPhotosSubscriptions = selectedPhotosSubject.stream
        .map((image) => _images.value + [image])
        .listen(_images.add);
    _subscriptions.add(newPhotosSubscriptions);
  }

  void clear() {
    _images.add([]);
  }

  final _savedPhotoIdSubject = PublishSubject<String>();
  Stream<String> get savedPhotoId => _savedPhotoIdSubject.stream;

  void save() {
    final collegeImage = previewImage.value;
    if (collegeImage == null) {
      return;
    }

    final subscription = PhotoWriter.save(collegeImage)
    .asStream()
    .listen((id) {
      _savedPhotoIdSubject.add(id);
      clear();
    }, onError: _savedPhotoIdSubject.addError);

    _subscriptions.add(subscription);
  }

  void dispose() {
    previewImage.dispose();
    photosCount.dispose();
    _subscriptions.dispose();
  }

  // Displaying photos picker
  var selectedPhotosSubject = PublishSubject<ui.Image>();
  final _photos = PublishSubject<List<AssetEntity>>();
  Stream<List<AssetEntity>> get photos => _photos.stream;

  void bindPhotoPicker() {
    loadPhotos().then((items) => _photos.add(items));
  }

  void unbindPhotoPicker() {
    selectedPhotosSubject.close();
  }

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

  void selectImage(AssetEntity asset) {
    asset.file.then((file) async {
      final byteData = await file!.readAsBytes();
      final codec = await ui.instantiateImageCodec(byteData);
      final frameInfo = await codec.getNextFrame();
      final image = frameInfo.image;
      selectedPhotosSubject.add(image);
    });
  }
}
