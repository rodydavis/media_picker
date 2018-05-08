// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:media_picker/media_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Image Picker Demo',
      home: new MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> _mediaFile;
  bool isVideo = false;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      _mediaFile = isVideo
          ? MediaPicker.pickVideo(source: source)
          : MediaPicker.pickImage(source: source);
    });
  }

  Widget _previewWidget(File data) {
    // File data = await _mediaFile;
    final VideoPlayerController vcontroller =
        new VideoPlayerController.file(data);
    vcontroller.play();
    vcontroller.setLooping(true);
    videoPlayerListener = () {
      if (videoController != null && videoController.value.size != null) {
        videoController.removeListener(videoPlayerListener);
        // Refreshing the state to update video player with the correct ratio.
        if (mounted) setState(() {});
      }
    };
    vcontroller.addListener(videoPlayerListener);
    vcontroller.initialize().then((onValue) {
      if (!mounted) {
        return null;
      }
      setState(() {
        videoController?.dispose();
        videoController = vcontroller;
      });
    });

    return videoController == null && data == null
        ? new Text('Error Loading Data')
        : new SizedBox(
            child: (videoController == null)
                ? new Image.file(data)
                : new Container(
                    child: new Center(
                      child: new AspectRatio(
                          aspectRatio: videoController.value.size != null
                              ? videoController.value.aspectRatio
                              : 1.0,
                          child: new VideoPlayer(videoController)),
                    ),
                    decoration: new BoxDecoration(
                        border: new Border.all(color: Colors.pink)),
                  ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Media Picker Example'),
      ),
      body: new Center(
        child: new FutureBuilder<File>(
          future: _mediaFile,
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return isVideo
                  ? _previewWidget(snapshot.data)
                  : new Image.file(snapshot.data);
            } else if (snapshot.error != null) {
              return const Text('Error picking image or video.');
            } else {
              return const Text('You have not yet picked an image or video.');
            }
          },
        ),
      ),
      floatingActionButton: new Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new FloatingActionButton(
            onPressed: () {
              isVideo = false;
              _onImageButtonPressed(ImageSource.gallery);
            },
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              onPressed: () {
                isVideo = false;
                _onImageButtonPressed(ImageSource.camera);
              },
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.gallery);
              },
              tooltip: 'Pick Video from gallery',
              child: const Icon(Icons.video_library),
            ),
          ),
          new Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: new FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () {
                isVideo = true;
                _onImageButtonPressed(ImageSource.camera);
              },
              tooltip: 'Take a Video',
              child: const Icon(Icons.videocam),
            ),
          ),
        ],
      ),
    );
  }
}
