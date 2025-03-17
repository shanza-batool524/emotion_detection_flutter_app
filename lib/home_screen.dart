import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CameraController? cameraController;
  CameraImage? cameraImage;
  String output = '';
  late Interpreter interpreter;  // Interpreter for running the model

  @override
  void initState() {
    super.initState();
    loadModel();
    loadCamera();
  }

  // Load the model using tflite_flutter
  loadModel() async {
    try {
      interpreter = await Interpreter.fromAsset('model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  // Load the camera
  loadCamera() async {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    await cameraController!.initialize().then((value) {
      if (!mounted) return;
      setState(() {
        cameraController!.startImageStream((imageStream) {
          cameraImage = imageStream;
          runModel();
        });
      });
    });
  }

  // Process camera frames and run the model
  runModel() async {
    if (cameraImage != null) {
      // Preprocess image (you can resize, normalize, etc.)
      var inputImage = await convertCameraImageToTensor(cameraImage!);

      var outputTensor = List.filled(2, 0.0).reshape([1, 2]);

      interpreter.run(inputImage, outputTensor);

      setState(() {
        output = outputTensor[0][0].toString(); // Assuming it's a single value output
      });
    }
  }

  // Convert CameraImage to Tensor
  Future<List<List<List<List<double>>>>> convertCameraImageToTensor(CameraImage image) async {
    // Resize image, normalize, etc. depending on the model requirements
    // Example preprocessing might go here, such as resizing or normalization
    // You can use 'image' to convert it to an acceptable format for the model

    // In this case, I'm assuming you need a 224x224 image, but check your model's input requirements
    var bytesList = image.planes.map((plane) {
      return plane.bytes;
    }).toList();

    // Your image processing goes here (this is a placeholder)
    // Make sure you correctly convert the image data to the expected tensor format for your model

    // Placeholder for the conversion process
    return List.generate(1, (index) => List.generate(224, (i) => List.generate(224, (j) => [0.0])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Emotion Detection App"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: cameraController!.value.isInitialized
                  ? AspectRatio(
                aspectRatio: cameraController!.value.aspectRatio,
                child: CameraPreview(cameraController!),
              )
                  : Text(output, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController?.dispose();
    super.dispose();
  }
}
