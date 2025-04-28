import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../theme/colors.dart';
import '../../theme/themes.dart';

class ProcessDialog extends StatelessWidget {
  const ProcessDialog({super.key, required this.title, required this.text});
  final String? text;
  final String? title;

  static void show({required BuildContext context, required String title, required String text}) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return ProcessDialog(
          title: title,
          text: text,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      height: height * 0.05,
      width: width * 0.2,
      child: AlertDialog(
        title: Center(
          child: Text(
            title!,
            style: const TextStyle(
              fontFamily: primaryFont,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: primaryTheme,
                size: 35,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              text!,
              style: const TextStyle(
                color: primaryTheme,
                fontFamily: primaryFont,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
