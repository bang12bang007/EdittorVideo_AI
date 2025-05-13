class Song {
  final String title;
  final String artist;
  final String artwork;
  final String url;
  final String id; // in seconds

  Song({
    required this.title,
    required this.artist,
    required this.artwork,
    required this.url,
    required this.id,
  });
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      artwork: json['artwork'] ?? '',
      url: json['url'] ?? '',
      id: json['id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'artist': artist,
      'artwork': artwork,
      'url': url,
      'id': id,
    };
  }
}
