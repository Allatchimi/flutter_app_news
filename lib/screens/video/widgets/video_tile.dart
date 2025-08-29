import 'package:flutter/material.dart';
import '../../../models/video_item.dart';

class VideoTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;
  final bool isGrid;

  const VideoTile({
    super.key,
    required this.video,
    required this.onTap,
    required this.isGrid,
  });

  @override
  Widget build(BuildContext context) {
    if (isGrid) {
      return InkWell(
        onTap: onTap,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: const EdgeInsets.all(4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
          child: AspectRatio(
            aspectRatio: 3 / 4, // Ratio 3:4 (largeur:hauteur)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image prend 70% de l'espace
                Expanded(
                  flex: 7,
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child:
                        (video.thumbnailUrl != null &&
                            video.thumbnailUrl!.isNotEmpty)
                        ? Image.network(
                            video.thumbnailUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.videocam, size: 40),
                              );
                            },
                          )
                        : const Center(child: Icon(Icons.videocam, size: 40)),
                  ),
                ),
                // Texte prend 30% de l'espace
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
   // MODE LISTE AMÉLIORÉ
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1.5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 100,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                  image: (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                      ? DecorationImage(
                          image: NetworkImage(video.thumbnailUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: (video.thumbnailUrl == null || video.thumbnailUrl!.isEmpty)
                    ? const Center(
                        child: Icon(Icons.videocam, size: 30, color: Colors.grey),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Contenu texte
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
                    const SizedBox(height: 4),
                    // Métadonnées (source + durée si disponible)
                    Row(
                      children: [
                        if (video.source != null)
                          Text(
                            video.source!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (video.source != null) const SizedBox(width: 8),
                        const Icon(Icons.play_circle_outline, size: 16, color: Colors.blue),
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