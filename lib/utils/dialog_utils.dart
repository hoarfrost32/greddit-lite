import 'package:flutter/material.dart';

class DialogUtils {
  DialogUtils._();

  static Future<bool?> showDeleteConfirmationDialog({
    required BuildContext context,
    required String title,
    required String content,
    required Future<void> Function() onConfirm,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              child: Text(
                confirmText,
                style: TextStyle(color: Theme.of(dialogContext).colorScheme.error),
              ),
              onPressed: () async {
                Navigator.of(dialogContext).pop(true);
                await onConfirm();
              },
            ),
          ],
        );
      },
    );
  }
}