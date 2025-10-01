import 'dart:io';

import 'package:ai_chatbot/controller/gemini_service.dart';
import 'package:ai_chatbot/controller/local_storage.dart';
import 'package:ai_chatbot/view/splash_screen.dart';
import 'package:ai_chatbot/view/widgets/chat_bubble.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final List<Map<String, dynamic>> messageMapList;
  const ChatScreen({super.key, required this.messageMapList});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  bool readOnly = false;
  bool loader = false;
  File? selectedImage;

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> messageMap = widget.messageMapList;
    Size size = MediaQuery.of(context).size;
    double width = size.width;
    double height = size.height;
    return Container(
      color: Colors.blue,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size(width, 80),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Colors.blue,
                border: Border(
                  bottom: BorderSide(
                    color: Color.fromRGBO(13, 71, 161, 1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                spacing: 15,
                children: [
                  SvgPicture.asset("assets/svgs/logo.svg"),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "AI Name",
                          style: GoogleFonts.poppins(
                            fontSize: 25,
                            color: const Color.fromRGBO(255, 255, 255, 1),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          "Always Online !!",
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: const Color(0xFF43EE7D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Color.fromRGBO(255, 255, 255, 1),
                      size: 35,
                    ),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          onTap: () async {
                            await LocalStorage.deleteAllData();
                            messageMap = [];
                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const SplashScreen();
                                  },
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Delete all chats",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    bottom: 10,
                    left: 12,
                    right: 12,
                  ),
                  child: Container(
                    width: width,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(150, 199, 231, 246),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color.fromRGBO(3, 169, 244, 1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: messageMap.length,
                            reverse: true,
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              int rev = messageMap.length - 1 - index;
                              return ChatBubble(
                                message: messageMap[rev]['message'],
                                image: messageMap[rev]['image'],
                                isReceiver: messageMap[rev]['sentByAI']
                                    ? true
                                    : false,
                              );
                              // return const SizedBox();
                            },
                          ),
                        ),
                        (loader)
                            ? ChatBubble(
                                message: null,
                                isReceiver: true,
                                image: null,
                              )
                            // ? const SizedBox()
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
              (selectedImage == null)
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(
                        bottom: 9,
                        right: 9,
                        left: 9,
                      ),
                      child: Container(
                        width: width,
                        height: 200,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(150, 199, 231, 246),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color.fromRGBO(3, 169, 244, 1),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Container(
                              alignment: Alignment.topRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    selectedImage = null;
                                  });
                                },
                                style: const ButtonStyle(
                                  backgroundColor: WidgetStatePropertyAll(
                                    Colors.red,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close_outlined,
                                  size: 20,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: height / 4),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                    right: 15,
                    bottom: 10,
                  ),
                  child: TextFormField(
                    onTapAlwaysCalled: false,
                    readOnly: readOnly,
                    controller: _messageController,
                    cursorColor: Colors.blueGrey.shade800,
                    textInputAction: TextInputAction.newline,
                    maxLines: 20,
                    minLines: 1,
                    keyboardType: TextInputType.multiline,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromRGBO(55, 71, 79, 1),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(68, 138, 255, 1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          width: 2,
                          color: Color.fromRGBO(41, 121, 255, 1),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color.fromRGBO(68, 138, 255, 1),
                        ),
                      ),
                      suffixIcon: IconButton(
                        iconSize: 35,
                        onPressed: () async {
                          List<ConnectivityResult> result = await Connectivity()
                              .checkConnectivity();
                          if (result[0] == ConnectivityResult.none) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "No Internet!!!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }
                          }
                          if (_messageController.text.isNotEmpty) {
                            String msg = _messageController.text;
                            _messageController.clear();
                            setState(() {
                              messageMap.add({
                                'message': msg,
                                'image': null,
                                // 'ext': null,
                                'sentByAI': false,
                              });
                              readOnly = true;
                              loader = true;
                            });
                            Map<String, String?>? response =
                                await GeminiService().sendRequest(
                                  question: msg,
                                  selectedImage: selectedImage,
                                );
                            if (response != null) {
                              selectedImage = null;
                              messageMap.add({
                                'message': response['message'],
                                'image': response['image'],
                                'sentByAI': true,
                              });
                              setState(() {
                                readOnly = false;
                                loader = false;
                              });
                              await LocalStorage.saveMessageLocally(
                                message: msg,
                                image: null,
                                isUser: true,
                              );
                              await LocalStorage.saveMessageLocally(
                                message: response['message'],
                                image: response['image'],
                                isUser: false,
                              );
                            } else {
                              setState(() {
                                readOnly = false;
                                loader = false;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Something went wrong..."),
                                  ),
                                );
                              }
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please Enter Message.."),
                                ),
                              );
                            }
                          }
                        },
                        icon: SvgPicture.asset(
                          "assets/svgs/send.svg",
                          fit: BoxFit.fill,
                          height: 35,
                          width: 35,
                        ),
                      ),
                      prefixIcon: IconButton(
                        iconSize: 35,
                        onPressed: () async {
                          XFile? file = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (file != null) {
                            setState(() {
                              selectedImage = File(file.path);
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.image_outlined,
                          size: 35,
                          color: Color.fromRGBO(67, 97, 238, 1.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
