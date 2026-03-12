import 'notification_service.dart';
import 'web_notification_service.dart';

NotificationService createPlatformNotificationService() {
  return WebNotificationService();
}
