import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/ui/theme.dart';
import '../widgets/button.dart';
import '../widgets/input_field.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';

class AddSpeechToTextPage extends StatefulWidget {
  const AddSpeechToTextPage({Key? key}) : super(key: key);

  @override
  State<AddSpeechToTextPage> createState() => _AddSpeechToTextPageState();
}

class _AddSpeechToTextPageState extends State<AddSpeechToTextPage> {
  final TextEditingController _scriptTitleController = TextEditingController(); // For user-defined script title
  final TextEditingController _titleController = TextEditingController(); // For recognized speech (content)
  
  bool _isListeningLoading = false; // 녹음 로딩 인디케이터 상태
  bool _isListening = false; // 녹음 상태
  final stt.SpeechToText _speechToText = stt.SpeechToText(); // SpeechToText 객체
  final FlutterTts _flutterTts = FlutterTts(); // FlutterTts 객체
  
  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }
  
  // Speech-to-text 초기화
  void _initSpeech() async {
    await _speechToText.initialize();
  }
  
  // Text-to-speech 초기화
  void _initTts() async {
    await _flutterTts.setLanguage('ko-KR');
    await _flutterTts.setSpeechRate(0.5);
  }
  
  // 녹음 시작
  void _startListening() async {
    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _isListeningLoading = true;
      });
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            setState(() {
              _isListening = false;
              _isListeningLoading = false;
              _titleController.text = result.recognizedWords;
            });
          }
        },
        localeId: 'ko_KR', // 한국어 설정
      );
    } else {
      setState(() {
        _isListening = false;
        _isListeningLoading = false;
      });
      Get.snackbar(
        '오류',
        '음성 인식을 시작할 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  // 녹음 중지
  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
      _isListeningLoading = false;
    });
  }
  
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.theme.scaffoldBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios,
              color: primaryClr),
        ),
        title: Text(
          'Sound to text',
          style: headingStyle.copyWith(
            color: Get.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                '         음성을 스크립트로 변경하세요',
                style: headingStyle,

              ),
              const SizedBox(height: 20),
              // Script Title Input Field
              InputField(
                title: '스크립트 제목',
                hint: '스크립트 제목을 입력하세요',
                controller: _scriptTitleController,
              ),
              const SizedBox(height: 20),
              // 음성 인식 버튼 및 로딩 인디케이터
              Center(
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic_off : Icons.mic,
                        size: 60,
                        color: primaryClr,
                      ),
                      onPressed: _isListening ? _stopListening : _startListening,
                    ),
                    if (_isListeningLoading)
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(color: primaryClr),
                      ),
                    const Text('버튼을 눌러 녹음을 시작하세요'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 인식된 텍스트 표시 영역
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _titleController,
                  style: subTitleStyle,
                  decoration: const InputDecoration(
                    hintText: '인식된 텍스트가 여기에 표시됩니다',
                    border: InputBorder.none,
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 30),
              // 스크립트 저장버튼
              Row(
                children: [
                  Expanded(
                    child: MyButton(
                      label: '스크립트 저장하기',
                      onTap: () {
                        String scriptTitle = _scriptTitleController.text.trim();
                        String scriptContent = _titleController.text.trim();

                        if (scriptTitle.isEmpty) {
                          Get.snackbar(
                            '오류',
                            '스크립트 제목을 입력해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        if (scriptContent.isEmpty) {
                          Get.snackbar(
                            '오류',
                            '스크립트 내용이 없습니다. 먼저 음성 인식을 실행해주세요.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        Get.back(result: {'title': scriptTitle, 'content': scriptContent});
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // 할 일 추가 버튼
              // Row(
              //   children: [
              //     Expanded(
              //       child: MyButton(
              //         label: '할 일 추가하기',
              //         onTap: () {
              //           if (_titleController.text.isNotEmpty) {
              //             // 할 일 추가 기능 구현 예정
              //             Get.back(result: _titleController.text);
              //           } else {
              //             Get.snackbar(
              //               '오류',
              //               '할 일 내용을 입력해주세요',
              //               snackPosition: SnackPosition.BOTTOM,
              //               backgroundColor: Colors.red,
              //               colorText: Colors.white,
              //             );
              //           }
              //         },
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}