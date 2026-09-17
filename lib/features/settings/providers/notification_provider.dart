import 'package:event_management_system/features/settings/models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier()
    : super(
        List.generate(
          8,
          (index) => NotificationModel(
            id: 'notif_$index',
            text: 'Lorem ipsum dolor sit amet consectetur.',
            time: '4:00 PM',
            isUnread: index < 3,
          ),
        ),
      );

  void markAsRead(String id) {
    state = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isUnread: false);
      }
      return item;
    }).toList();
  }

  void addNewTestNotification() {
    final newNotif = NotificationModel(
      id: 'notif_test_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Test Notification Created! You tapped the test injector!',
      time: 'Now',
      isUnread: true,
    );
    state = [newNotif, ...state];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>((ref) {
      return NotificationNotifier();
    });
