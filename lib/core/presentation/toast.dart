import 'package:flash/flash.dart';
import 'package:flutter/material.dart';

Future<void> showToast(
  String message,
  BuildContext context,
) async {
  await showFlash(
    context: context,
    duration: const Duration(seconds: 3),
    builder: (context, controller) {
      return Flash.dialog(
        margin: const EdgeInsets.all(8),
        backgroundColor: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        controller: controller,
        // alignment: Alignment.,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    },
  );
}
