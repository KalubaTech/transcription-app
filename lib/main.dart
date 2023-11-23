import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:get/get.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:text2pdf/text2pdf.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Transcription App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController editController = TextEditingController();
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';


  export(String content)async{
    await Text2Pdf.generatePdf(content);
  }


  @override
  void initState() {
    super.initState();
    _initSpeech();


  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {

    });
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      editController.text = _lastWords;
    });
  }

  PageController _pageController = PageController();

  // create instance of ExportDelegate



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transcription App', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: PageView(
        controller: _pageController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      // If listening is active show the recognized words
                      _speechToText.isListening
                          ? '$_lastWords'
                          : _speechEnabled
                          ? 'Tap the microphone to start listening...'
                          : 'Speech not available',
                    ),
                  ),
                ),
                RippleAnimation(
                  repeat: true,
                  ripplesCount: 2,
                  color: Colors.green,
                  child: TouchRippleEffect(
                    onTap:
                      // If not yet listening for speech start, otherwise stop
                      _speechToText.isNotListening ? _startListening : _stopListening,
                    borderRadius: BorderRadius.circular(100),
                    rippleColor: Colors.green.withOpacity(0.2),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey,
                            blurRadius: 2
                          )
                        ]
                      ),
                      padding: EdgeInsets.all(30),
                      child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic, size: 50,color: Colors.green),
                    ),
                  ),
                ),
                SizedBox(height: 30,)
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20),
            child: Container(
              child: Column(
                children: [
                  Expanded(
                      child: TextField(
                          controller: editController,
                          maxLines: 15,
                          decoration: InputDecoration(
                            border: InputBorder.none
                          ),
                        ),
                  ),
                  TouchRippleEffect(
                    onTap: (){
                      export(editController.text);
                    },
                    rippleColor: Colors.greenAccent,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green
                      ),
                      child: Center(child: Text('Export', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),))
                    ),
                  )
                ]
              ),
            ),
          )
        ],
      ),
    );
  }
}