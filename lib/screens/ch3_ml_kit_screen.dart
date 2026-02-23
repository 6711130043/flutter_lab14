import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class MLKitScreen extends StatefulWidget {
  const MLKitScreen({super.key});

  @override
  State<MLKitScreen> createState() => _MLKitScreenState();
}

class _MLKitScreenState extends State<MLKitScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDetecting = false;
  List<String> _results = [];

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _processImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    setState(() {
      _isDetecting = true;
      _results = [];
    });

    _imageBytes = await pickedFile.readAsBytes();

    final inputImage = InputImage.fromFilePath(pickedFile.path);
    final tabIndex = _tabController.index;
    List<String> newResults = [];

    try {
      switch (tabIndex) {
        case 0: // OCR
          final textRecognizer =
              TextRecognizer(script: TextRecognitionScript.latin);
          final RecognizedText recognizedText =
              await textRecognizer.processImage(inputImage);
          for (TextBlock block in recognizedText.blocks) {
            newResults.add(block.text);
          }
          textRecognizer.close();
          if (newResults.isEmpty) newResults.add('ไม่พบข้อความ');
          break;
        case 1: // Face Detect
          final options = FaceDetectorOptions(
            enableContours: true,
            enableClassification: true,
          );
          final faceDetector = FaceDetector(options: options);
          final List<Face> faces = await faceDetector.processImage(inputImage);

          newResults.add('พบใบหน้า: ${faces.length} ใบหน้า');
          for (int i = 0; i < faces.length; i++) {
            final face = faces[i];
            if (face.smilingProbability != null) {
              newResults.add(
                  'ใบหน้าที่ ${i + 1} ยิ้ม: ${(face.smilingProbability! * 100).toStringAsFixed(1)}%');
            }
          }
          faceDetector.close();
          break;
        case 2: // Barcode
          final barcodeScanner = BarcodeScanner();
          final List<Barcode> barcodes =
              await barcodeScanner.processImage(inputImage);

          if (barcodes.isEmpty) {
            newResults.add('ไม่พบบาร์โค้ด');
          } else {
            for (final barcode in barcodes) {
              newResults.add(
                  'ประเภท: ${barcode.type.name}\nข้อมูล: ${barcode.rawValue}');
            }
          }
          barcodeScanner.close();
          break;
      }
    } catch (e) {
      newResults.add('เกิดข้อผิดพลาด: $e');
    }

    setState(() {
      _results = newResults;
      _isDetecting = false;
    });
  }

  Widget _buildImagePlaceholder(IconData icon, String text) {
    if (_imageBytes != null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(_imageBytes!, fit: BoxFit.cover),
        ),
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google ML Kit'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'OCR'),
            Tab(text: 'Face Detect'),
            Tab(text: 'Barcode'),
          ],
          onTap: (_) {
            setState(() {
              _results = [];
              _imageBytes = null;
            });
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOCRTab(context),
          _buildFaceDetectTab(context),
          _buildBarcodeTab(context),
        ],
      ),
    );
  }

  Widget _buildOCRTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildImagePlaceholder(Icons.image, 'พื้นที่แสดงรูปภาพ'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isDetecting ? null : _processImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('เลือกรูปภาพเพื่อสแกนข้อความ'),
          ),
          const SizedBox(height: 32),
          if (_isDetecting)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('กำลังประมวลผล...'),
              ],
            )
          else if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผลลัพธ์:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ..._results.map((result) => _ResultCard(text: result)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFaceDetectTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildImagePlaceholder(Icons.face, 'พื้นที่แสดงรูปภาพ'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isDetecting ? null : _processImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('เลือกรูปภาพเพื่อตรวจจับใบหน้า'),
          ),
          const SizedBox(height: 32),
          if (_isDetecting)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('กำลังตรวจจับ...'),
              ],
            )
          else if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผลลัพธ์:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ..._results.map((result) => _ResultCard(text: result)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBarcodeTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildImagePlaceholder(Icons.qr_code_2, 'พื้นที่แสดงรูปภาพ'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isDetecting ? null : _processImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('เลือกรูปภาพเพื่อสแกน Barcode'),
          ),
          const SizedBox(height: 32),
          if (_isDetecting)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('กำลังสแกน...'),
              ],
            )
          else if (_results.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผลลัพธ์:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ..._results.map((result) => _ResultCard(text: result)),
              ],
            ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String text;

  const _ResultCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
