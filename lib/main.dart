import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Profile image cropper'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File _image;
  int _width;
  int _height;

  void _initGallery() async {
    final picker = ImagePicker();

    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the image dimensions
      File file = File(pickedFile.path);
      img.Image image = img.decodeImage(file.readAsBytesSync());

      print('Image: ${image.width} - ${image.height}');

      setState(() {
        _image = file;
        _width = image.width;
        _height = image.height;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            child: _image == null
                ? null
                : PanZoomImage(image: _image, width: _width, height: _height),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _initGallery,
        child: Icon(Icons.collections),
      ),
    );
  }
}

class PanZoomImage extends StatefulWidget {
  PanZoomImage({
    Key key,
    @required File image,
    @required int width,
    @required int height,
  })  : _image = image,
        super(key: key);

  final File _image;

  @override
  _PanZoomImageState createState() => _PanZoomImageState();
}

class _PanZoomImageState extends State<PanZoomImage> {
  final TransformationController controller = TransformationController();

  double offsetX = 0.0;
  double offsetY = 0.0;
  double scaleX = 0.0;
  double scaleY = 0.0;

  Uint8List finalImage;

  final double size = 500.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
        ),
        Center(
          child: ClipRect(
            child: Container(
              //height: size,
              //width: size,
              child: Stack(
                children: [
                  Center(
                    child: InteractiveViewer(
                      transformationController: controller,
                      panEnabled: true,
                      boundaryMargin: EdgeInsets.all(200),
                      minScale: 2,
                      maxScale: 4,
                      onInteractionStart: (ScaleStartDetails details) {
                        // print('ScaleStart: $details');
                      },
                      onInteractionUpdate: (ScaleUpdateDetails details) {
                        Matrix4 matrix = controller.value;
                        offsetX = matrix.entry(0, 3);
                        offsetY = matrix.entry(1, 3);
                        scaleX = matrix.entry(0, 0);
                        scaleY = matrix.entry(1, 1);

                        // print(
                        // " - offsetX: $offsetX, offsetY: $offsetY, scaleX: $scaleX, scaleY: $scaleY");
                      },
                      onInteractionEnd: (ScaleEndDetails details) {
                        // print('ScaleEnd: $details');
                      },
                      child: Image.file(
                        widget._image,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
