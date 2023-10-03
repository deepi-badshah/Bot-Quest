import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:quest/openai_service.dart'; // You might need to import this if it's not already imported.
import 'package:quest/pallete.dart';
import 'package:quest/feature_box.dart'; // You might need to import this if it's not already imported.

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController messageController = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = "";
  String recognizedSpeech = ""; // Separate variable for recognized speech
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start = 200;
  int delay = 200;
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    isListening = true;
    setState(() {});
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    isListening = false;
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      recognizedSpeech = result.recognizedWords;
    });
    // print("lastWrds are" + lastWords);
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(
          child: const Text(
            'Bot Quest',
            style: TextStyle(
              fontFamily: 'Cera Pro',
              color: Pallete.mainFontColor,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Pallete.mainFontColor.withOpacity(0.1),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // virtual assistant picture
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 130,
                      width: 150,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.rectangle,
                      ),
                    ),
                  ),
                  Container(
                    height: 130,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/virtualAssistant.png',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // chat bubble
            FadeInRight(
              child: Visibility(
                visible: generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                    top: 30,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Pallete.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      topLeft: Radius.zero,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      generatedContent == null
                          ? "Heyaa! I'm all ears for your questions."
                          : generatedContent!,
                      style: TextStyle(
                        fontFamily: 'Cera Pro',
                        color: Pallete.mainFontColor,
                        fontSize: generatedContent == null ? 25 : 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (generatedImageUrl != null)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(generatedImageUrl!),
                ),
              ),
            SlideInLeft(
              child: Visibility(
                visible: generatedContent == null && generatedImageUrl == null,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 10, left: 22),
                  child: const Text(
                    'Here are a few features',
                    style: TextStyle(
                      fontFamily: 'Cera Pro',
                      color: Pallete.mainFontColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // features list
            Visibility(
              visible: generatedContent == null && generatedImageUrl == null,
              child: Column(
                children: [
                  SlideInLeft(
                    delay: Duration(milliseconds: start),
                    child: const FeatureBox(
                      color: Pallete.firstSuggestionBoxColor,
                      headerText: 'ChatGPT',
                      descriptionText:
                          'A smarter way to stay organized and informed with ChatGPT',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + delay),
                    child: const FeatureBox(
                      color: Pallete.secondSuggestionBoxColor,
                      headerText: 'Dall-E',
                      descriptionText:
                          'Get inspired and stay creative with your personal assistant powered by Dall-E',
                    ),
                  ),
                  SlideInLeft(
                    delay: Duration(milliseconds: start + 2 * delay),
                    child: const FeatureBox(
                      color: Pallete.thirdSuggestionBoxColor,
                      headerText: 'Smart Voice Assistant',
                      descriptionText:
                          'Get the best of both worlds with a voice assistant powered by Dall-E and ChatGPT',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: MediaQuery.of(context)
                    .viewInsets
                    .bottom), // Adjusts for the keyboard
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        color: Pallete.mainFontColor.withOpacity(0.1),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: messageController,
                style: const TextStyle(
                  color: Pallete.mainFontColor,
                ),
                cursorColor: Pallete.mainFontColor.withOpacity(0.1),
                decoration: InputDecoration(
                  hintText: "Whats in your mind...",
                  hintStyle: TextStyle(
                    // color: Colors.white,
                    fontSize: 18,
                    fontStyle: FontStyle.italic, fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor.withOpacity(0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () async {
                setState(() {
                  lastWords = messageController.text;
                });
                final speech = await openAIService.isArtPromptAPI(lastWords);
                if (speech.contains('https')) {
                  generatedImageUrl = speech;
                  generatedContent = null;
                  setState(() {
                    lastWords = "";
                  });
                } else {
                  generatedImageUrl = null;
                  generatedContent = speech;
                  setState(() {});
                  lastWords = "";
                  await systemSpeak(speech);
                }
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            GestureDetector(
              onTap: () async {
                if (await speechToText.hasPermission &&
                    speechToText.isNotListening) {
                  await startListening();
                } else if (speechToText.isListening) {
                  final speech =
                      await openAIService.isArtPromptAPI(recognizedSpeech);
                  if (speech.contains('https')) {
                    generatedImageUrl = speech;
                    generatedContent = null;
                    setState(() {
                      // lastWords = "";
                    });
                  } else {
                    generatedImageUrl = null;
                    generatedContent = speech;
                    setState(() {});
                    await systemSpeak(speech);
                  }
                  await stopListening();
                  recognizedSpeech = "";
                } else {
                  initSpeechToText();
                }
              },
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic_sharp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
