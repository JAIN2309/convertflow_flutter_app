import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import '../controllers/converter_controller.dart';

class FilePickerSection extends GetView<ConverterController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Files',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        // File Picker Button
        Obx(() => GestureDetector(
          onTap: controller.isLoading.value ? null : controller.pickFiles,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                if (controller.isLoading.value)
                  const CircularProgressIndicator()
                else
                  Icon(
                    controller.conversionType.value == 'pdf_to_image'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                const SizedBox(height: 16),
                Text(
                  controller.isLoading.value
                      ? 'Loading...'
                      : controller.conversionType.value == 'pdf_to_image'
                          ? 'Tap to select PDF file'
                          : 'Tap to select image files',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.conversionType.value == 'pdf_to_image'
                      ? 'Supported: PDF files'
                      : 'Supported: JPG, PNG, WEBP, BMP',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        )),
        
        // Selected Files List
        const SizedBox(height: 16),
        Obx(() {
          if (controller.selectedFiles.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Files (${controller.selectedFiles.length})',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const SizedBox(height: 12),
                ...controller.selectedFiles.map((file) => _buildFileItem(context, file)),
              ],
            );
          }
          return const SizedBox.shrink();
        }),
        
        // Status Message
        const SizedBox(height: 12),
        Obx(() {
          if (controller.statusMessage.value.isNotEmpty) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.statusMessage.value,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildFileItem(BuildContext context, file) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(file.path),
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path.basename(file.path),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                Text(
                  _getFileSize(file),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              // Remove from both lists for web compatibility
              if (kIsWeb) {
                final fileName = path.basename(file.path);
                controller.selectedFileBytes.remove(fileName);
              }
              controller.selectedFiles.remove(file);
            },
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.webp':
      case '.bmp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileSize(file) {
    try {
      if (kIsWeb) {
        // On web, get file size from controller's selectedFileBytes
        final fileName = path.basename(file.path);
        final bytes = controller.selectedFileBytes[fileName]?.length ?? 0;
        return _formatBytes(bytes);
      } else {
        // On mobile, use lengthSync
        final bytes = file.lengthSync();
        return _formatBytes(bytes);
      }
    } catch (e) {
      return 'Unknown size';
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
