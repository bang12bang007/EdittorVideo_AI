import 'package:edit_video_app/assets/colors.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:edit_video_app/presentation/pages/music/entities/entitySong.dart';
import 'package:edit_video_app/presentation/pages/service/service_music.dart';

class SelectMusicPage extends StatefulWidget {
  const SelectMusicPage({super.key});

  @override
  State<SelectMusicPage> createState() => _SelectMusicPageState();
}

class _SelectMusicPageState extends State<SelectMusicPage>
    with WidgetsBindingObserver {
  List<Song> _songs = [];
  bool isLoading = true;

  late final AudioPlayer _audioPlayer;
  String? _currentUrl;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _loading();
    _setupAudioPlayerListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _audioPlayer.pause();
    }
  }

  void _setupAudioPlayerListeners() {
    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        setState(() {
          _position = pos;
        });
      }
    });

    _audioPlayer.durationStream.listen((dur) {
      if (mounted) {
        setState(() {
          _duration = dur ?? Duration.zero;
        });
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          if (state.processingState == ProcessingState.completed) {
            _isPlaying = false;
            _position = Duration.zero;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Dừng và giải phóng tài nguyên AudioPlayer
    _audioPlayer.stop().then((_) {
      _audioPlayer.dispose();
    }).catchError((e) {
      debugPrint('Error disposing audio player: $e');
      _audioPlayer.dispose();
    });
    super.dispose();
  }

  Future<void> _loading() async {
    try {
      final songs = await MusicService.fetchMusicFromApi();
      if (mounted) {
        setState(() {
          _songs = songs;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading songs: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> playOrPauseSong(String url) async {
    try {
      if (_currentUrl == url) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.setUrl(url);
        _currentUrl = url;
        await _audioPlayer.play();
      }
    } catch (e) {
      debugPrint("Error playing song: $e");
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _currentUrl = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _audioPlayer.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Music'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () async {
              await _audioPlayer.stop();
              Navigator.pop(context);
            },
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _songs.length,
                      itemBuilder: (context, index) {
                        final song = _songs[index];
                        final isCurrent = song.url == _currentUrl;
                        return Column(
                          children: [
                            ListTile(
                              leading: Image.network(
                                song.artwork,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.music_note),
                              ),
                              title: Text(song.title),
                              subtitle: Text(song.artist),
                              trailing: IconButton(
                                icon: Icon(
                                  isCurrent && _isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: UtilColors.primaryColor,
                                ),
                                onPressed: () => playOrPauseSong(song.url),
                              ),
                            ),
                            if (isCurrent)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    activeTrackColor: UtilColors.primaryColor,
                                    inactiveTrackColor: Colors.grey[300],
                                    thumbColor: UtilColors.primaryColor,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8.0),
                                    trackHeight: 2,
                                  ),
                                  child: Slider(
                                    min: 0,
                                    max: _duration.inMilliseconds.toDouble(),
                                    value: _position.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                            0.0,
                                            _duration.inMilliseconds
                                                .toDouble()),
                                    onChanged: (value) {
                                      setState(() {
                                        _position = Duration(
                                            milliseconds: value.toInt());
                                      });
                                    },
                                    onChangeEnd: (value) {
                                      _audioPlayer.seek(Duration(
                                          milliseconds: value.toInt()));
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
