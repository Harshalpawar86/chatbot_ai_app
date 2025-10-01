import 'package:ai_chatbot/controller/local_storage.dart';
import 'package:ai_chatbot/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  List<Map<String, dynamic>> list = [];

  @override
  void initState() {
    super.initState();
    startSplash();
  }

  Future<List<Map<String, dynamic>>> loadData() async {
    List<Map<String, dynamic>> loadedList = await LocalStorage.getData();
    List<Map<String, dynamic>> tempList = [];

    for (var data in loadedList) {
      String? mesg = data['message'];
      String? image = data['image'];
      bool val = (data['isuser'] == 0) ? true : false;
      tempList.add({'message': mesg, 'sentByAI': val, 'image': image});
    }
    return tempList;
  }

  Future<void> startSplash() async {
    final results = await Future.wait([
      loadData(),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    list = results[0] as List<Map<String, dynamic>>;

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ChatScreen(messageMapList: list)),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 5),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: SizedBox(
                      height: size.height / 1.5,
                      width: size.width / 1.5,
                      child: SvgPicture.asset(
                        "assets/svgs/logo.svg",
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              Text(
                "AI Bot",
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
