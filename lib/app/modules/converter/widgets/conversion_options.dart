import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/converter_controller.dart';

class ConversionOptions extends GetView<ConverterController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Output Format',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 16),
        
        // Format Selection
        Obx(() => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Image Format',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: controller.imageFormats.map((format) {
                  final isSelected = controller.selectedImageFormat.value == format;
                  return GestureDetector(
                    onTap: () => controller.changeImageFormat(format),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        format,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _buildFormatInfo(context),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildFormatInfo(BuildContext context) {
    return Obx(() {
      final format = controller.selectedImageFormat.value;
      String description;
      IconData icon;
      Color color;

      switch (format) {
        case 'PNG':
          description = 'Lossless compression, supports transparency, larger file size';
          icon = Icons.high_quality;
          color = Colors.blue;
          break;
        case 'JPG':
          description = 'Lossy compression, smaller file size, no transparency';
          icon = Icons.compress;
          color = Colors.orange;
          break;
        case 'WEBP':
          description = 'Modern format, excellent compression, supports transparency';
          icon = Icons.new_releases;
          color = Colors.green;
          break;
        case 'BMP':
          description = 'Uncompressed format, largest file size, highest quality';
          icon = Icons.storage;
          color = Colors.red;
          break;
        default:
          description = 'Select a format to see details';
          icon = Icons.info;
          color = Colors.grey;
      }

      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                description,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
