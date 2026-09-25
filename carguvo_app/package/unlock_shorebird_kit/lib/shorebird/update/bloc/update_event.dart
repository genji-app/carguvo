abstract class UpdateEvent {
  const UpdateEvent();
}

class UpdateCheckRequested extends UpdateEvent {
  const UpdateCheckRequested();
}

class UpdateDownloadRequested extends UpdateEvent {
  const UpdateDownloadRequested();
}

