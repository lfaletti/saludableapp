import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'nutrition_info_service.dart';
import 'result_screen.dart';
import 'nutrition_info.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(
    OrientationBuilder(
      builder: (context, orientation) {
        return const MyApp();
      },
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escaneo Nutricional',
      home: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? const MyHomePage(key: Key('homePage'))
              : Center(
                  child: Text(
                    'Enderece el dispositivo para realizar un escaneo.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14, // Adjust the font size as needed
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      cameras[0],
      ResolutionPreset.medium,
    );
    _initializeControllerFuture = _cameraController.initialize();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  Future<void> scanNutritionalTable() async {
    try {
      await _initializeControllerFuture;

      // Capture text
      final XFile imageFile = await _cameraController.takePicture();
      final inputImage = InputImage.fromFile(File(imageFile.path));
      final textRecognizer = GoogleMlKit.vision.textRecognizer();

      // Process
      final RecognizedText recognisedText =
          await textRecognizer.processImage(inputImage);

      String? extractedText = processRecognisedText(recognisedText);

      // Mocking extracted text:
      // String? extractedText = "Proteínas Azúcares INS 296 INS 322";
      // String? extractedText = ""; to test empty results screen

      NutritionInfoService nutritionInfoService = NutritionInfoService();
      List<NutritionInfo> nutritionInfoList =
          await nutritionInfoService.processText(extractedText!);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            //builder: (context) => ResultScreen(nutritionInfoList: nutritionInfoList, scannedText: extractedText ),
            builder: (context) => ResultScreen(
                nutritionInfoList: nutritionInfoList,
                scannedText: recognisedText.text),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  String? processRecognisedText(RecognizedText recognisedText) {
    // order recognized text
    var text = "";
    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        text = text + line.text + "\n";
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escaneo Nutricional'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
              child: const Text(
                'Escanee un producto para obtener informacion sobre los ingredientes. Procure contar con buena luz y enfocar adecuadamente. La app identifica ingredientes pero debe evaluar las cantidades por su cuenta.',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: FutureBuilder<void>(
                future: _initializeControllerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _cameraController.value.aspectRatio,
                      child: RotatedBox(
                        quarterTurns: 0,
                        child: CameraPreview(_cameraController),
                      ),
                    );
                  } else {
                    return Center(
                      child: SizedBox(
                        width: 40.0,
                        height: 40.0,
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                scanNutritionalTable();
              },
              child: const Text('Escanear'),
            ),
            SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }
}
