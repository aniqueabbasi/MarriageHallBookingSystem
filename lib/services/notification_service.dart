/// Push/local notification placeholder. The "notifications" feature today
/// is a dummy-data list screen, not a real notification channel — this
/// exists so wiring up real delivery later doesn't require inventing a
/// services/ layer at that point.
abstract class NotificationService {
  Future<void> show({required String title, required String body});
}
