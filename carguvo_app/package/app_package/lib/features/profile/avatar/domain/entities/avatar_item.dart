class AvatarItem {
  final int id;
  final String url;

  const AvatarItem({required this.id, required this.url});

  factory AvatarItem.fromJson(Map<String, dynamic> json) {
    return AvatarItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AvatarItem && other.id == id && other.url == url);

  @override
  int get hashCode => Object.hash(id, url);
}
