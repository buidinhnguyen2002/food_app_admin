import 'package:final_project_admin/widget/notification_dialog.dart';
import 'package:flutter/material.dart';

void navigation(BuildContext context, String routerName) {
  Navigator.of(context).pushReplacementNamed(routerName);
}

Future<void> showNotification(BuildContext context, String content) async {
  // Navigator.of(context).pop(true);
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      Future.delayed(
        const Duration(seconds: 1, microseconds: 50),
        () {
          Navigator.of(ctx).pop(true);
        },
      );
      return NotificationDialog(content: content);
    },
  );
}

Future<void> showNotificationAndCloseBottomSheet(
    BuildContext context, String content) async {
  Navigator.of(context).pop(true);
  showDialog(
    context: context,
    builder: (BuildContext ctx) {
      Future.delayed(
        const Duration(seconds: 1, microseconds: 50),
        () {
          Navigator.of(ctx).pop(true);
        },
      );
      return NotificationDialog(content: content);
    },
  );
}
