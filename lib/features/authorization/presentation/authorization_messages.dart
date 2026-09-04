import 'package:flutter/material.dart';

import '../domain/repositories/authorization_repository.dart';

Future<void> showAccessMessage(
  BuildContext context,
  AccessStatus status,
) async {
  if (status == AccessStatus.allowed || status == AccessStatus.noSignedInUser) {
    return;
  }

  final isDisabled = status == AccessStatus.disabled;
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isDisabled ? 'تم تعطيل الحساب' : 'تنبيه'),
      content: Text(
        isDisabled ? 'غير مسموح لك بالدخول' : 'اكمل بياناتك للاستمرار',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('موافق'),
        ),
      ],
    ),
  );
}
