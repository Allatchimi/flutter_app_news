import 'package:app_news/models/video_item.dart';
import 'package:app_news/screens/video/widgets/video_widget.dart';
import 'package:app_news/services/video_service.dart';
import 'package:app_news/utils/app_colors.dart';
import 'package:app_news/utils/onboarding_util/topic_urls.dart';
import 'package:app_news/widgets/generic_app_bar.dart';
import 'package:app_news/widgets/youtube_player_flutter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {

  static final String tchadInfoUrl = TopicUrls.videoUrls['TCHADINFOS'] ?? '';
  static final String manaraUrl = TopicUrls.videoUrls['MANARA'] ?? '';
  static final String alwihidaUrl = TopicUrls.videoUrls['ALWIHDAINFO'] ?? '';
     
  late Future<List<VideoItem>> manaraVideo;
  late Future<List<VideoItem>> alwihdaVideos;
  late Future<List<VideoItem>> tchadinfosVideos;
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadData(forceRefresh: false);
  }

  Future<void> _loadData({required bool forceRefresh}) async {
    if (forceRefresh) {
      final box = await Hive.openBox('youtube_cache');

    }
    setState(() {
      manaraVideo = VideoService.fetchVideos(manaraUrl);
      alwihdaVideos = VideoService.fetchVideos(alwihidaUrl);
      tchadinfosVideos = VideoService.fetchVideos(tchadInfoUrl);

    });
  }

void _playVideo(String link, List<VideoItem> videoList) {
  final index = videoList.indexWhere((v) => v.link == link);
  if (index != -1) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => YoutubePlaylistPlayerScreen(
          videos: videoList,
          initialIndex: index,
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GenericAppBar(
        title: "Les Vidéos",
        backgroundColor: AppColors.secondaryColor,
        extraActions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(forceRefresh: true), // Refresh forcé
            tooltip: "Forcer le rafraîchissement",
          ),
          IconButton(
            icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => isGridView = !isGridView),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(forceRefresh: false), // Refresh simple
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              VideoDeSite(
                isGridView: isGridView,
                videosFuture: manaraVideo,
                playVideo:  _playVideo,
                nomSite: "Manara TV",),
              const SizedBox(height: 20),
              VideoDeSite(
                isGridView: isGridView,
                videosFuture: alwihdaVideos,
                playVideo: _playVideo,
                nomSite: "Alwihda Info",
              ),
              const SizedBox(height: 20),
              VideoDeSite(
                isGridView: isGridView,
                videosFuture: tchadinfosVideos,
                playVideo: _playVideo,
                nomSite: "Tchad Infos",
              ),
              const SizedBox(height: 20),
              const Text(
                "Avertissement",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              Divider(
                color: AppColors.secondaryColor,
                thickness: 2,
                height: 20,
              ),
              const Text(
                "Powered by Mahamat Allatchimi",
                style: TextStyle(fontSize: 12, color: AppColors.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


