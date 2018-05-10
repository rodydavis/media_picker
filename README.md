# media_picker
![alt text](https://github.com/AppleEducate/app_review/blob/master/screenshots/IMG_0024.PNG)

## Description
Flutter Plugin for Capturing and Selecting Photos and Videos.

## Installing

```
media_picker:
    git:
      url: git://github.com/AppleEducate/media_picker
```
## Import
```
import 'package:media_picker/media_picker.dart';
```

## Example

```

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_picker/media_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Media Picker Demo',
      home: new MyHomePage(title: 'Media Picker Example'),
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
  VideoPlayerController _controller;
  VoidCallback listener;

  void _onImageButtonPressed(ImageSource source) {
    setState(() {
      if (_controller != null) {
        _controller.setVolume(0.0);
        _controller.removeListener(listener);
      }
      if (isVideo) {
        _mediaFile = MediaPicker.pickVideo(source: source).then((onValue) {
          _controller = VideoPlayerController.file(onValue)
            ..addListener(listener)
            ..setVolume(1.0)
            ..initialize()
            ..setLooping(true)
            ..play();
          setState(() {});
        });
      } else {
        _mediaFile = MediaPicker.pickImage(source: source);
      }
    });
  }

  @override
  void deactivate() {
    _controller.setVolume(0.0);
    _controller.removeListener(listener);
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    listener = () {
      setState(() {});
    };
  }

  @override
  Widget build(BuildContext context) {
    Widget _previewImage = new FutureBuilder<File>(
      future: _mediaFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return new Image.file(snapshot.data);
        } else if (snapshot.error != null) {
          return const Text('Error picking image.');
        } else {
          return const Text('You have not yet picked an image.');
        }
      },
    );

    return new Scaffold(
      appBar: new AppBar(
        title: const Text('Media Picker Example'),
      ),
      body: new Center(
        child: isVideo
            ? new Padding(
                padding: const EdgeInsets.all(10.0),
                child: new AspectRatio(
                  aspectRatio: 1280 / 720,
                  child: (_controller != null
                      ? VideoPlayer(
                          _controller,
                        )
                      : Container()),
                ),
              )
            : _previewImage,
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


```
