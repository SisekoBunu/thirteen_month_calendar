import 'dart:io';

import 'android_notification_service.dart';
import 'notification_service.dart';
import 'noop_notification_service.dart';

NotificationService createPlatformNotificationService() {
  if (Platform.isAndroid) {
    return AndroidNotificationService();
  }

  return NoopNotificationService();
}
