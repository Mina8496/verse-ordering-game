import 'package:aner_astaner/features/authorization/domain/repositories/authorization_repository.dart';
import 'package:aner_astaner/features/authorization/presentation/authorization_messages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> isUserApprovedOrAdmin(BuildContext context) async {
  final status = await Get.find<AuthorizationRepository>()
      .checkCurrentUserAccess();
  await showAccessMessage(context, status);
  return status == AccessStatus.allowed;
}
