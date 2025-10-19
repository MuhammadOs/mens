import 'package:flutter_riverpod/flutter_riverpod.dart';

// Data model to hold notification settings
class NotificationSettings {
  final bool newOrdersPush;
  final bool promotionsPush;
  final bool newOrdersEmail;
  final bool promotionsEmail;

  NotificationSettings({
    this.newOrdersPush = true,
    this.promotionsPush = true,
    this.newOrdersEmail = false,
    this.promotionsEmail = true,
  });

  NotificationSettings copyWith({
    bool? newOrdersPush,
    bool? promotionsPush,
    bool? newOrdersEmail,
    bool? promotionsEmail,
  }) {
    return NotificationSettings(
      newOrdersPush: newOrdersPush ?? this.newOrdersPush,
      promotionsPush: promotionsPush ?? this.promotionsPush,
      newOrdersEmail: newOrdersEmail ?? this.newOrdersEmail,
      promotionsEmail: promotionsEmail ?? this.promotionsEmail,
    );
  }
}

// Provider for the notifier
final notificationsNotifierProvider = NotifierProvider<NotificationsNotifier, NotificationSettings>(
  NotificationsNotifier.new,
);

class NotificationsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    // In a real app, you would load these settings from SharedPreferences or a backend.
    return NotificationSettings();
  }

  // Methods to update each setting
  void toggleNewOrdersPush(bool value) {
    state = state.copyWith(newOrdersPush: value);
    _saveSettings();
  }

  void togglePromotionsPush(bool value) {
    state = state.copyWith(promotionsPush: value);
    _saveSettings();
  }
  
  void toggleNewOrdersEmail(bool value) {
    state = state.copyWith(newOrdersEmail: value);
    _saveSettings();
  }
  
  void togglePromotionsEmail(bool value) {
    state = state.copyWith(promotionsEmail: value);
    _saveSettings();
  }
  
  void _saveSettings() {
    // TODO: Implement logic to save the 'state' object to persistent storage.
    print("Settings saved: New Orders Push = ${state.newOrdersPush}");
  }
}