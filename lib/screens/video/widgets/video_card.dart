import 'package:app_news/models/video_item.dart';
import 'package:flutter/material.dart';

class YoutubeVideoCard extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;
  final bool isActive;

  const YoutubeVideoCard({
    super.key,
    required this.video,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail avec indicateur de lecture
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                      image: video.thumbnailUrl != null
                          ? DecorationImage(
                              image: NetworkImage(video.thumbnailUrl!),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                // Gestion silencieuse des erreurs d'image
                              },
                            )
                          : null,
                    ),
                    child: video.thumbnailUrl == null
                        ? const Center(
                            child: Icon(Icons.videocam, size: 30, color: Colors.grey),
                          )
                        : null,
                  ),
                  // Badge de lecture
                  if (isActive)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'En cours',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Icône play overlay
                  const Positioned.fill(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_filled,
                        color: Colors.white54,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Contenu texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre avec indicateur actif
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive ? Colors.amber : Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (video.description != null && video.description!.isNotEmpty)
                      Text(
                        video.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.2,
                        ),
                      ),
                    const SizedBox(height: 6),
                    // Métadonnées
                    Row(
                      children: [
                        // Source
                        if (video.source != null)
                          Text(
                            video.source!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        const Spacer(),
                        // Indicateur visuel
                        Icon(
                          Icons.play_circle_outline,
                          size: 18,
                          color: isActive ? Colors.amber : Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}