import 'dart:async';

import 'package:college_neue/college_neue_model.dart';
import 'package:college_neue/utilties/fade_button.dart';
import 'package:college_neue/utilties/show_alert_dialog.dart';
import 'package:college_neue/utilties/stream_listenable_builder.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class PhotoGalleryPage extends StatefulWidget {
  final CollegeNeueModel model;
  const PhotoGalleryPage({super.key, required this.model});

  @override
  State<PhotoGalleryPage> createState() => _PhotoGalleryPageState();
}

class _PhotoGalleryPageState extends State<PhotoGalleryPage> {
  late final model = widget.model;

  @override
  void initState() {
    super.initState();
    model.bindPhotoPicker();
  }

  @override
  void dispose() {
    model.unbindPhotoPicker();
    super.dispose();
  }

  void _streamListener(
      BuildContext context, AsyncSnapshot<List<AssetEntity>> snapshot) {
    if (snapshot.hasError && snapshot.error != null) {
      switch (snapshot.error) {
        case CollegeNeueModelError.permissionNotGranted:
          showAlertDialog(context,
              title: 'No access to Camera Roll',
              message: 'You can grant access in Settings app');
        default:
          showAlertDialog(context,
              title: 'Error', message: snapshot.error!.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo Gallery'),
      ),
      body: StreamListenableBuilder<List<AssetEntity>>(
        stream: model.photos,
        listener: _streamListener,
        builder: (context, snapshot) {
          return switch (snapshot) {
            (final AsyncSnapshot<List<AssetEntity>> snapshot)
                when snapshot.hasData =>
              GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) => FadeButton(
                    child: AssetEntityImage(
                      snapshot.data![index],
                      isOriginal: false,
                      thumbnailSize: const ThumbnailSize.square(200),
                      thumbnailFormat: ThumbnailFormat.jpeg,
                      fit: BoxFit.cover,
                    ),
                    onPressed: () {
                      model.selectImage(snapshot.data![index]);
                    }),
              ),
            (final AsyncSnapshot s) when s.hasError =>
              Center(child: Text('Error: ${s.error}')),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
    );
  }
}
