import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechAvailable = false;
  bool _isListening = false;
  String _recognizedText = '';
  bool _isSpeaking = false;
  String _statusText = 'กำลังเตรียมระบบเสียง...';
  final TextEditingController _ttsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeVoiceServices();
  }

  Future<void> _initializeVoiceServices() async {
    final available = await _speechToText.initialize(
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isListening = false;
          _statusText = 'เกิดข้อผิดพลาด: ${error.errorMsg}';
        });
      },
      onStatus: (status) {
        if (!mounted) return;
        setState(() {
          _isListening = status == 'listening';
          if (status == 'done' || status == 'notListening') {
            _statusText = 'แตะเพื่อเริ่มฟัง';
          }
        });
      },
    );

    await _flutterTts.setLanguage('th-TH');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setStartHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = true);
    });
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() => _isSpeaking = false);
    });

    if (!mounted) return;
    setState(() {
      _speechAvailable = available;
      _statusText =
          available ? 'แตะเพื่อเริ่มฟัง' : 'อุปกรณ์นี้ไม่รองรับ Speech-to-Text';
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _flutterTts.stop();
    _tabController.dispose();
    _ttsController.dispose();
    super.dispose();
  }

  void _startListening() async {
    if (!_speechAvailable) return;

    if (_speechToText.isListening) {
      await _speechToText.stop();
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _statusText = 'แตะเพื่อเริ่มฟัง';
      });
      return;
    }

    await _speechToText.listen(
      localeId: 'th_TH',
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.confirmation,
      ),
      onResult: _onSpeechResult,
    );

    if (!mounted) return;
    setState(() {
      _isListening = true;
      _statusText = 'กำลังฟัง...';
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _recognizedText = result.recognizedWords;
    });
  }

  void _speak() async {
    if (_ttsController.text.isEmpty) return;
    await _flutterTts.stop();
    await _flutterTts.speak(_ttsController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech & Voice AI'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Speech-to-Text'),
            Tab(text: 'Text-to-Speech'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSTTTab(context),
          _buildTTSTab(context),
        ],
      ),
    );
  }

  Widget _buildSTTTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 32),
          GestureDetector(
            onTap: _startListening,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: !_speechAvailable
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : _isListening
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: _isListening
                    ? _buildListeningAnimation()
                    : Icon(
                        _speechAvailable ? Icons.mic : Icons.mic_off,
                        size: 64,
                        color: _speechAvailable
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _statusText,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 40),
          if (_recognizedText.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ข้อความที่ตรวจจับได้:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _recognizedText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTTSTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'พิมพ์ข้อความที่ต้องการให้พูด',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _ttsController,
            decoration: InputDecoration(
              hintText: 'เช่น สวัสดีฉันชื่อ Flutter...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSpeaking ? null : _speak,
              icon: const Icon(Icons.volume_up),
              label: const Text('พูด'),
            ),
          ),
          const SizedBox(height: 40),
          if (_isSpeaking)
            Column(
              children: [
                _buildWaveformAnimation(),
                const SizedBox(height: 16),
                Text(
                  'กำลังพูด...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildListeningAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: List.generate(
        3,
        (index) {
          return Container(
            width: 150 - (index * 40).toDouble(),
            height: 150 - (index * 40).toDouble(),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .onError
                    .withValues(alpha: 0.5 - (index * 0.15)),
                width: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveformAnimation() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          5,
          (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + (index * 50)),
                height: 30 + (index.isEven ? 30 : -10),
                width: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
