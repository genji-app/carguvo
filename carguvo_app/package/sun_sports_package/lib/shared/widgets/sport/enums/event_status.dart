enum EventStatus { active, suspended, hidden, autoSuspended, autoHidden }

extension EventStatusX on EventStatus {
  bool get canBet => this == EventStatus.active;

  bool get isVisible =>
      this != EventStatus.hidden && this != EventStatus.autoHidden;

  bool get isHidden =>
      this == EventStatus.hidden || this == EventStatus.autoHidden;

  bool get isSuspended =>
      this == EventStatus.suspended || this == EventStatus.autoSuspended;

  String get displayText {
    switch (this) {
      case EventStatus.active:
        return '';
      case EventStatus.suspended:
      case EventStatus.autoSuspended:
        return 'Tạm ngưng';
      case EventStatus.hidden:
      case EventStatus.autoHidden:
        return 'Hủy';
    }
  }

  static EventStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'ACTIVE':
      case '0':
        return EventStatus.active;
      case 'SUSPENDED':
      case '1':
        return EventStatus.suspended;
      case 'HIDDEN':
      case '2':
        return EventStatus.hidden;
      case 'AUTOSUSPENDED':
      case 'AUTO_SUSPENDED':
      case '3':
        return EventStatus.autoSuspended;
      case 'AUTOHIDDEN':
      case 'AUTO_HIDDEN':
      case '4':
        return EventStatus.autoHidden;
      default:
        return EventStatus.active;
    }
  }
}
