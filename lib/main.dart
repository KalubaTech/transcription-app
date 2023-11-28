import 'dart:io';
import 'dart:ui';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:social_media_recorder/audio_encoder_type.dart';
import 'package:social_media_recorder/screen/social_media_recorder.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:get/get.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';
import 'package:touch_ripple_effect/touch_ripple_effect.dart';
import 'package:text2pdf/text2pdf.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:transcriber/styles/colors.dart';


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

  final FlutterTts flutterTts = FlutterTts();
  var position = Duration().obs;

  @override
  void initState() {
    super.initState();
    _initSpeech();

    flutterTts.speak('Welcome to UNILUS Transcription App.');

    // Listen to the position stream
    player.positionStream.listen((Duration duration) {
      // Handle position updates here
      position.value = duration;
    });

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
  final player = AudioPlayer();

  _changeSeek(double dur){

  }
  _playAudio(data){
    print(data);
  }

  Duration convertToDuration(String timeString) {
    List<String> parts = timeString.split(':');
    if (parts.length == 2) {
      int minutes = int.tryParse(parts[0]) ?? 0;
      int seconds = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: minutes, seconds: seconds);
    } else {
      // Handle invalid format
      return Duration.zero;
    }
  }


  var playingIndex = 0.obs;
  int counter = 0;
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: ()async {
          counter++;
          Future.delayed(Duration(seconds: 2), () => counter = 0);
          if (counter == 2) {
            if (_bottomNavIndex != 0) {
              setState(() {
                _bottomNavIndex = 0;
                _pageController.animateToPage(
                    0, duration: Duration(microseconds: 200),
                    curve: Curves.easeIn);
              });
              return false;
            } else {
              return true;
            }
          } else {
            Fluttertoast.showToast(msg: 'Tap to exit');
            return false;
          }
        },
      child: Scaffold(
        bottomNavigationBar: AnimatedBottomNavigationBar(
          iconSize: 26,
          backgroundColor: Karas.primary,
          icons: [Icons.keyboard_voice,Icons.picture_as_pdf,Icons.record_voice_over,Icons.info,],
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.center,
          notchSmoothness: NotchSmoothness.verySmoothEdge,
          activeColor: Colors.white,
          inactiveColor: Colors.grey,
          onTap: (index) => setState((){
            _bottomNavIndex = index;
            _pageController.animateToPage(index, duration: Duration(microseconds: 200), curve: Curves.bounceInOut);
          }),
          //other params
        ),
      appBar: AppBar(
        backgroundColor: Karas.primary,
        foregroundColor: Karas.secorary,
        title: Text('Transcription App', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (page){
          setState(() {
            _bottomNavIndex = page;
          });
        },
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // Adjust the sigma values for the blur effect
                    child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(image: AssetImage('assets/unilus.jpg'))
                    ),
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
          ),
          Container(
              decoration: BoxDecoration(
                image: DecorationImage(image: AssetImage('assets/background_chat.jpg', ),fit: BoxFit.cover)
              ),
            child:Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: 20),
                          Expanded(
                            child: Container(
                              child: GetStorage().hasData('recordings')?ListView.builder(
                                  clipBehavior: Clip.none,
                                  itemCount: GetStorage().read('recordings').length,
                                  itemBuilder: (context,index){
                                    final data = GetStorage().read('recordings')[index];

                                    Duration duration = Duration(seconds: int.parse(data['dur'].toString().split(':')[1]));
                                    bool isPlaying = false;
                                    bool isLoading = false;
                                    bool isPause = false;
                                    List d = GetStorage().read('recordings');
                                    return InkWell(
                                      onLongPress: (){
                                        Get.defaultDialog(
                                          title: 'Delete Voice Note?',
                                          titlePadding: EdgeInsets.only(top: 20),
                                          titleStyle: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                                          content: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child:TouchRippleEffect(
                                                    onTap: (){
                                                      Get.back();
                                                      d.removeAt(index);
                                                      GetStorage().write('recordings',d);
                                                      Fluttertoast.showToast(msg: 'Deleted successfuly');
                                                      setState(() {

                                                      });
                                                      },
                                                    rippleColor: Colors.greenAccent,
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Container(
                                                        decoration: BoxDecoration(
                                                            color: Colors.green,
                                                            borderRadius: BorderRadius.circular(10)
                                                        ),
                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                                        child: Center(
                                                          child: Text('Confirm', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                                        )
                                                    ),
                                                  )
                                                ),
                                                SizedBox(width: 10,),
                                                Expanded(
                                                  child: TouchRippleEffect(
                                                    onTap: (){
                                                      Get.back();
                                                    },
                                                    rippleColor: Colors.greenAccent,
                                                    borderRadius: BorderRadius.circular(10),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.green,
                                                        borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                                      child: Center(
                                                        child: Text('Cancel', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                                      )
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        );
                                      },
                                      child: Obx(
                                          ()=> BubbleNormalAudio(
                                          color: Color(0xFFE8E8EE),
                                          duration: duration.inSeconds.toDouble(),
                                          position: playingIndex.value==index?position.value.inSeconds.toDouble():0,
                                          isPlaying: d[index]['isPlaying'],
                                          isLoading: isLoading,
                                          isPause: isPause,
                                          onSeekChanged: _changeSeek,
                                          onPlayPauseButtonClick: (){
                                            player.setFilePath(data['file']);

                                            !d[index]['isPlaying'] ? player.play():player.pause();
                                            d[index].update('isPlaying', (value) => !value);
                                            GetStorage().write('recordings', d);

                                            setState(() {
                                              !isPlaying;
                                              playingIndex.value = index;
                                            });
                                          },
                                          sent: true,
                                          delivered: true,
                                        ),
                                      ),
                                    );
                                  }
                              ):Container(),
                            ),
                          ),
                        ],
                      ),
                    )
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: SocialMediaRecorder(
                    backGroundColor: Colors.transparent,
                    recordIcon: Icon(Icons.mic,size: 40,color: Colors.green,),
                    sendRequestFunction: (f,s) {
                      if(GetStorage().hasData('recordings')){
                        List records = GetStorage().read('recordings');
                        records.add({'file':f.path,'dur':s,'isPlaying':false});
                        GetStorage().write('recordings', records);
                        GetStorage().write('recordings', records);
                      }else{
                        GetStorage().write('recordings', [{'file':f.path,'dur':s, 'isPlaying':false}]);
                      }

                      setState(() {

                      });
                    },

                    encode: AudioEncoderType.AAC,

                  ),
                ),
              ],
            )
          ),
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
                    child: Text('About App', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  height: 200,
                ),
                Spacer(),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                    child: Text('UNILUS@2023', style: TextStyle(color: Colors.grey, fontSize: 12),)
                )
              ],
            ),
          )
        ],
      ),
    )
    );
  }
}