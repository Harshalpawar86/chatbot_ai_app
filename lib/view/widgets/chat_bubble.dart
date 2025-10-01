import 'dart:io';
import 'dart:typed_data';

import 'package:ai_chatbot/view/widgets/chat_bubble_clipper.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:shimmer/shimmer.dart';

// Chat bubble widget
class ChatBubble extends StatelessWidget {
  final String? message;
  final bool isReceiver;
  final Color? backgroundColor;
  final Color? textColor;
  final String? image;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isReceiver,
    this.backgroundColor,
    required this.image,
    this.textColor,
    this.padding,
    this.borderRadius,
  });
  Future downloadImageToGallery(BuildContext context) async {
    if (image != null) {
      File file = File(image!);
      Uint8List bytes = await file.readAsBytes();
      final result = await ImageGallerySaverPlus.saveImage(bytes, quality: 100);
      bool isSuccess = await result['isSuccess'];
      if (context.mounted) {
        if (isSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Image Downloaded")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Failed to  Download Image")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    bool hasValidMessage = message != null && message!.trim().isNotEmpty;
    bool hasValidImage = image != null;

    if (!hasValidMessage && !hasValidImage) {
      content = Shimmer.fromColors(
        baseColor: Colors.blue,
        highlightColor: Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width / 2,
          height: 30,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(33, 150, 243, 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else if (!hasValidMessage && hasValidImage) {
      content = Stack(
        children: [
          Image.file(File(image!)),
          IconButton(
            alignment: Alignment.topRight,
            onPressed: () async {
              await downloadImageToGallery(context);
            },
            icon: Container(
              height: 35,
              width: 35,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 1),
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 1), width: 1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.download, color: Color.fromRGBO(33, 150, 243, 1), size: 25),
            ),
          ),
        ],
      );
    } else if (hasValidMessage && !hasValidImage) {
      content = SelectableText(
        message!,
        selectionColor: isReceiver ? Colors.blueAccent.shade100 : Colors.black,
        style: GoogleFonts.poppins(
          color: const Color.fromRGBO(255, 255, 255, 1),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      );
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.file(File(image!)),
              IconButton(
                alignment: Alignment.topLeft,
                onPressed: () async {
                  await downloadImageToGallery(context);
                },
                icon: Container(
                  height: 35,
                  width: 35,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 1),
                    border: Border.all(color: const Color.fromRGBO(0, 0, 0, 1), width: 1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.blue,
                    size: 25,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SelectableText(
            message!,
            selectionColor: isReceiver
                ? const Color.fromRGBO(130, 177, 255, 1)
                : const Color.fromRGBO(0, 0, 0, 1),
            style: GoogleFonts.poppins(
              color: const Color.fromRGBO(255, 255, 255, 1),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Align(
      alignment: isReceiver ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: ClipPath(
          clipper: ChatBubbleClipper(
            isReceiver: isReceiver,
            radius: borderRadius ?? 12.0,
          ),
          child: Container(
            color:
                backgroundColor ?? (isReceiver ? const Color.fromRGBO(33, 150, 243, 1) : const Color.fromRGBO(96, 125, 139, 1)),
            padding:
                padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: content,
          ),
        ),
      ),
    );
  }
}
