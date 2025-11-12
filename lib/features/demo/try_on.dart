/*import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:ui' as ui;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pose Detector Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PoseDetectorView(),
    );
  }
}

class PoseDetectorView extends StatefulWidget {
  const PoseDetectorView({super.key});

  @override
  State<PoseDetectorView> createState() => _PoseDetectorViewState();
}

class _PoseDetectorViewState extends State<PoseDetectorView> {
  File? _imageFile;
  ui.Image? _image;
  List<Pose> _poses = [];
  bool _isLoading = false;

  // 1. إنشاء PoseDetector
  final PoseDetector _poseDetector =
      PoseDetector(options: PoseDetectorOptions());

  // 2. دالة اختيار الصورة
  Future<void> _pickImage() async {
    setState(() {
      _isLoading = true;
    });

    final ImagePicker picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: ImageSource.gallery);

    if (xfile != null) {
      _imageFile = File(xfile.path);
      // 3. معالجة الصورة
      await _processImage(_imageFile!);
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 4. دالة معالجة الصورة واستخراج النقاط
  Future<void> _processImage(File imageFile) async {
    // تحويل الصورة إلى كائن InputImage
    final InputImage inputImage = InputImage.fromFilePath(imageFile.path);
    
    // استخراج النقاط
    final List<Pose> poses = await _poseDetector.processImage(inputImage);

    // تحميل الصورة كـ ui.Image لرسمها
    final data = await imageFile.readAsBytes();
    final decodedImage = await decodeImageFromList(data);

    setState(() {
      _poses = poses;
      _image = decodedImage;
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google ML Kit Pose Test"),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : (_image == null)
                ? const Text("No image selected.")
                :
                // 5. عرض الصورة مع النقاط المرسومة فوقها
                FittedBox(
                    child: SizedBox(
                      width: _image!.width.toDouble(),
                      height: _image!.height.toDouble(),
                      child: CustomPaint(
                        painter: PosePainter(poses: _poses, image: _image!),
                      ),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

// 6. كلاس الرسام (CustomPainter) لرسم الهيكل العظمي
class PosePainter extends CustomPainter {
  final List<Pose> poses;
  final ui.Image image;

  PosePainter({required this.poses, required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // ارسم الصورة الأصلية أولاً
    canvas.drawImage(image, Offset.zero, Paint());

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    final Paint circlePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.fill;

    // ارسم النقاط (Landmarks) والخطوط
    for (final pose in poses) {
      // ارسم النقاط
      pose.landmarks.forEach((_, landmark) {
        canvas.drawCircle(
          Offset(landmark.x, landmark.y),
          5, // نصف قطر الدائرة
          circlePaint,
        );
      });

      // دالة مساعدة لرسم الخطوط
      void drawLine(PoseLandmarkType type1, PoseLandmarkType type2) {
        final PoseLandmark landmark1 = pose.landmarks[type1]!;
        final PoseLandmark landmark2 = pose.landmarks[type2]!;
        canvas.drawLine(
          Offset(landmark1.x, landmark1.y),
          Offset(landmark2.x, landmark2.y),
          paint,
        );
      }

      // ارسم خطوط الذراعين
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow);
      drawLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist);
      drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow);
      drawLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist);

      // ارسم خطوط الجذع
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder);
      drawLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip);
      drawLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip);
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip);

      // ارسم خطوط الساقين
      drawLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee);
      drawLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle);
      drawLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee);
      drawLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}*/