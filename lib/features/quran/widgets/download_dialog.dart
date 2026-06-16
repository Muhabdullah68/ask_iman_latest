import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/quran_download_service.dart';
import 'pdf_viewer_screen.dart';

class DownloadDialog extends StatelessWidget {
  final String id;
  final String title;
  final String audioUrl;
  final String? pdfUrl;

  const DownloadDialog({
    super.key,
    required this.id,
    required this.title,
    required this.audioUrl,
    this.pdfUrl,
  });

  @override
  Widget build(BuildContext context) {
    final service = QuranDownloadService();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Download $title',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDarkest,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your favorite recitations and PDFs offline.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 24),
          _DownloadTile(
            id: id,
            title: 'Audio Recitation',
            subtitle: 'High quality MP3 audio',
            icon: Icons.music_note_rounded,
            isDownloaded: service.isDownloaded(id, DownloadType.audio),
            onDownload: () {
              service.download(id: id, url: audioUrl, type: DownloadType.audio);
              Navigator.pop(context);
            },
            onDelete: () => service.deleteFile(id, DownloadType.audio),
          ),
          if (pdfUrl != null) ...[
            const SizedBox(height: 12),
            _DownloadTile(
              id: id,
              title: 'Quran PDF',
              subtitle: 'Clear Mushaf pages',
              icon: Icons.picture_as_pdf_rounded,
              isDownloaded: service.isDownloaded(id, DownloadType.pdf),
              onDownload: () {
                service.download(id: id, url: pdfUrl!, type: DownloadType.pdf);
                Navigator.pop(context);
              },
              onDelete: () => service.deleteFile(id, DownloadType.pdf),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDownloaded;
  final VoidCallback onDownload;
  final VoidCallback onDelete;

  const _DownloadTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDownloaded,
    required this.onDownload,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDownloaded ? AppColors.gold : Colors.grey.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDownloaded ? AppColors.gold.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDownloaded ? AppColors.goldDark : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (isDownloaded)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon == Icons.picture_as_pdf_rounded)
                  IconButton(
                    icon: const Icon(Icons.visibility_outlined, color: AppColors.primaryDark),
                    onPressed: () async {
                      final path = await QuranDownloadService().getFilePath(id, DownloadType.pdf);
                      if (context.mounted) {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => PdfViewerScreen(title: title, localPath: path),
                        ));
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: onDelete,
                ),
              ],
            )
          else
            ElevatedButton(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text(
                'Download',
                style: TextStyle(fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}
