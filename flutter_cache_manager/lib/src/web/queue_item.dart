class QueueItem {
  final String url;
  final String key;
  final String fileName;
  final Map<String, String>? headers;

  const QueueItem(this.url, this.key, this.fileName, this.headers);
}
