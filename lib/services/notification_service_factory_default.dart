import 'notification_service.dart';
import 'noop_notification_service.dart';

NotificationService createPlatformNotificationService() {
  return NoopNotificationService();
}
