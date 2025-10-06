import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/converter_controller.dart';
import '../widgets/file_picker_section.dart';
import '../widgets/conversion_options.dart';
import '../widgets/conversion_progress.dart';
import '../widgets/converted_files_section.dart';

class ConverterView extends GetView<ConverterController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
          controller.conversionType.value == 'pdf_to_image'
              ? 'PDF to Images'
              : 'Images to PDF',
        )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.clearFiles,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File Picker Section
              FilePickerSection(),
              const SizedBox(height: 24),
              
              // Conversion Options (for PDF to Image)
              Obx(() {
                if (controller.conversionType.value == 'pdf_to_image') {
                  return Column(
                    children: [
                      ConversionOptions(),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // Convert Button
              _buildConvertButton(context),
              const SizedBox(height: 24),
              
              // Conversion Progress
              Obx(() {
                if (controller.isConverting.value) {
                  return Column(
                    children: [
                      ConversionProgress(),
                      const SizedBox(height: 24),
                    ],
                  );
                }
                return const SizedBox.shrink();
              }),
              
              // Converted Files Section
              Obx(() {
                if (controller.convertedFiles.isNotEmpty) {
                  return ConvertedFilesSection();
                }
                return const SizedBox.shrink();
              }),
              
              // Footer
              const SizedBox(height: 32),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConvertButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.selectedFiles.isNotEmpty && !controller.isConverting.value
            ? controller.convertFiles
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: controller.isConverting.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Converting...',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.transform, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    controller.conversionType.value == 'pdf_to_image'
                        ? 'Convert PDF to Images'
                        : 'Convert Images to PDF',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    ));
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.code,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Developed by KJ',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
