import 'dart:convert';
import 'package:edit_video_app/presentation/pages/music/entities/entitySong.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http show get;
import 'package:http/http.dart' as http;

class MusicService {
  static Future<List<Song>> fetchMusicFromApi() async {
    try {
      final response = await http.get(Uri.parse(
          'https://editor-video-ede7a-default-rtdb.asia-southeast1.firebasedatabase.app/.json'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Song> songs =
            data.map((json) => Song.fromJson(json)).toList();
        return songs;
      } else {
        throw Exception('Failed to load music');
      }
    } catch (e) {
      debugPrint('Error fetching music: $e');
      throw Exception('Failed to load music: $e');
    }
  }
}
