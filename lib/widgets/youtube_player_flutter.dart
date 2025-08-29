import 'package:app_news/screens/video/widgets/video_card.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:app_news/models/video_item.dart';

class YoutubePlaylistPlayerScreen extends StatefulWidget {
  final List<VideoItem> videos;
  final int initialIndex;

  const YoutubePlaylistPlayerScreen({
    super.key,
    required this.videos,
    this.initialIndex = 0,
  });

  @override
  State<YoutubePlaylistPlayerScreen> createState() =>
      _YoutubePlaylistPlayerScreenState();
}

class _YoutubePlaylistPlayerScreenState
    extends State<YoutubePlaylistPlayerScreen> {
  late YoutubePlayerController _controller;
  late int currentIndex;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _initController();
  }

  void _initController() {
    try {
      final videoId =
          YoutubePlayer.convertUrlToId(widget.videos[currentIndex].link) ?? '';
      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
        ),
      );
      
      // Ajouter un listener pour capturer les erreurs
      _controller.addListener(() {
        if (_controller.value.hasError) {
          setState(() {
            _hasError = true;
          });
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }

  void _playVideoAtIndex(int index) {
    setState(() {
      currentIndex = index;
      _hasError = false;
      try {
        final videoId =
            YoutubePlayer.convertUrlToId(widget.videos[currentIndex].link) ?? '';
        _controller.load(videoId);
      } catch (e) {
        setState(() {
          _hasError = true;
        });
      }
    });
  }

  void _playNext() {
    if (currentIndex < widget.videos.length - 1) {
      _playVideoAtIndex(currentIndex + 1);
    }
  }

  void _playPrevious() {
    if (currentIndex > 0) _playVideoAtIndex(currentIndex - 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        title: Text(widget.videos[currentIndex].title),
        backgroundColor: AppColors.primaryColor,
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    "Erreur de lecture vidéo",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text("Impossible de lire cette vidéo"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hasError = false;
                        _initController();
                      });
                    },
                    child: const Text("Réessayer"),
                  ),
                ],
              ),
            )
          : YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                onEnded: (metaData) {
                  // Lecture automatique de la vidéo suivante
                  _playNext();
                },
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    AspectRatio(aspectRatio: 16 / 9, child: player),
                    const SizedBox(height: 8),
                    // Boutons navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _playPrevious,
                          icon: const Icon(Icons.skip_previous),
                          label: const Text("Précédent"),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            _controller.value.isPlaying ? "Pause" : "Lecture",
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _playNext,
                          icon: const Icon(Icons.skip_next),
                          label: const Text("Suivant"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Liste des vidéos
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.videos.length,
                        itemBuilder: (context, index) {
                          final video = widget.videos[index];
                          return YoutubeVideoCard(
                            video: video,
                            onTap: () => _playVideoAtIndex(index),
                            isActive: index == currentIndex,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}