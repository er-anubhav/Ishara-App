import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opencv_4/factory/pathfrom.dart';
import 'package:opencv_4/opencv_4.dart';
//uncomment when image_picker is installed
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'opencv_4 Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  Uint8List? _byte, salida;
  String _versionOpenCV = 'OpenCV';
  bool _visible = false;
  //uncomment when image_picker is installed
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _getOpenCVVersion();
  }

  Future<void> testOpenCV({
    required String pathString,
    required CVPathFrom pathFrom,
    required double thresholdValue,
    required double maxThresholdValue,
    required int thresholdType,
  }) async {
    try {
      //test with threshold
      _byte = await Cv2.threshold(
        pathFrom: pathFrom,
        pathString: pathString,
        maxThresholdValue: maxThresholdValue,
        thresholdType: thresholdType,
        thresholdValue: thresholdValue,
      );

      setState(() {
        _byte;
        _visible = false;
      });
    } on PlatformException catch (e) {
      debugPrint(e.message);
    }
  }

  /// metodo que devuelve la version de OpenCV utilizada
  Future<void> _getOpenCVVersion() async {
    String? versionOpenCV = await Cv2.version();
    setState(() {
      _versionOpenCV = 'OpenCV: ${versionOpenCV!}';
    });
  }

  Future<void> _testFromAssets() async {
    testOpenCV(
      pathFrom: CVPathFrom.ASSETS,
      pathString: 'assets/Test.JPG',
      thresholdValue: 150,
      maxThresholdValue: 200,
      thresholdType: Cv2.THRESH_BINARY,
    );
    setState(() {
      _visible = true;
    });
  }

  Future<void> _testFromUrl() async {
    testOpenCV(
      pathFrom: CVPathFrom.URL,
      pathString:
          'https://mir-s3-cdn-cf.behance.net/project_modules/max_1200/16fe9f114930481.6044f05fca574.jpeg',
      thresholdValue: 150,
      maxThresholdValue: 200,
      thresholdType: Cv2.THRESH_BINARY,
    );
    setState(() {
      _visible = true;
    });
  }

  Future<void> _testFromCamera() async {
    //uncomment when image_picker is installed
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    testOpenCV(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: _image!.path,
      thresholdValue: 150,
      maxThresholdValue: 200,
      thresholdType: Cv2.THRESH_BINARY,
    );

    setState(() {
      _visible = true;
    });
  }

  Future<void> _testFromGallery() async {
    //uncomment when image_picker is installed
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    testOpenCV(
      pathFrom: CVPathFrom.GALLERY_CAMERA,
      pathString: _image!.path,
      thresholdValue: 150,
      maxThresholdValue: 200,
      thresholdType: Cv2.THRESH_BINARY,
    );

    setState(() {
      _visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        Text(
                          _versionOpenCV,
                          style: TextStyle(fontSize: 23),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 5),
                          child: _byte != null
                              ? Image.memory(
                                  _byte!,
                                  width: 300,
                                  height: 300,
                                  fit: BoxFit.fill,
                                )
                              : SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.grey[800],
                                  ),
                                ),
                        ),
                        Visibility(
                            maintainAnimation: true,
                            maintainState: true,
                            visible: _visible,
                            child: CircularProgressIndicator()),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: TextButton(
                            onPressed: _testFromAssets,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.teal, disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                            ),
                            child: Text('test assets'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: TextButton(
                            onPressed: _testFromUrl,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.teal, disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                            ),
                            child: Text('test url'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: TextButton(
                            onPressed: _testFromGallery,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.teal, disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                            ),
                            child: Text('test gallery'),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 40,
                          child: TextButton(
                            onPressed: _testFromCamera,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: Colors.teal, disabledForegroundColor: Colors.grey.withValues(alpha: 0.38),
                            ),
                            child: Text('test camara'),
                          ),
                        ),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
