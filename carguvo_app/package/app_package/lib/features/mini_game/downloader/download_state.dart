enum DownloadState {
  undownloaded(0),
  downloading(1),
  downloaded(2),
  cached(3);

  final int value;
  const DownloadState(this.value);
}
