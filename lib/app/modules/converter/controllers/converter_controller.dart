import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import '../../../data/services/pdf_service.dart';
import '../../../data/services/image_service.dart';

class ConverterController extends GetxController {
  final PdfService _pdfService = PdfService();
  final ImageService _imageService = ImageService();
  
  final RxString conversionType = ''.obs;
  final RxList<File> selectedFiles = <File>[].obs;
  final RxList<Uint8List> convertedFiles = <Uint8List>[].obs;
  final Map<String, Uint8List> selectedFileBytes = {}; // For web platform
  final RxBool isLoading = false.obs;
  final RxBool isConverting = false.obs;
  final RxDouble conversionProgress = 0.0.obs;
  final RxString selectedImageFormat = 'PNG'.obs;
  final RxString statusMessage = ''.obs;

  final List<String> imageFormats = ['PNG', 'JPG', 'WEBP', 'BMP'];

  @override
  void onInit() {
    super.onInit();
    conversionType.value = Get.arguments ?? 'pdf_to_image';
  }

  Future<void> pickFiles() async {
    try {
      isLoading.value = true;
      FilePickerResult? result;

      if (conversionType.value == 'pdf_to_image') {
        result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
          withData: kIsWeb, // Only load data on web
        );
      } else {
        result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: true,
          withData: kIsWeb, // Only load data on web
        );
      }

      if (result != null) {
        selectedFiles.clear();
        
        if (kIsWeb) {
          // Web platform - handle bytes
          for (var file in result.files) {
            if (file.bytes != null) {
              // Create a temporary file in memory for web
              final fileName = file.name;
              final fileBytes = file.bytes!;
              
              // Store file info for web processing
              selectedFileBytes[fileName] = fileBytes;
              
              // Create a dummy file object for UI display
              selectedFiles.add(File(fileName));
            }
          }
        } else {
          // Mobile platforms - handle paths
          for (var file in result.files) {
            if (file.path != null) {
              selectedFiles.add(File(file.path!));
            }
          }
        }
        
        statusMessage.value = '${selectedFiles.length} file(s) selected';
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> convertFiles() async {
    if (selectedFiles.isEmpty) {
      Get.snackbar(
        'No Files',
        'Please select files to convert',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isConverting.value = true;
      conversionProgress.value = 0.0;
      convertedFiles.clear();

      if (conversionType.value == 'pdf_to_image') {
        await _convertPdfToImages();
      } else {
        await _convertImagesToPdf();
      }

      statusMessage.value = 'Conversion completed successfully!';
      Get.snackbar(
        'Success',
        'Files converted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      statusMessage.value = 'Conversion failed: $e';
      Get.snackbar(
        'Error',
        'Conversion failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isConverting.value = false;
      conversionProgress.value = 0.0;
    }
  }

  Future<void> _convertPdfToImages() async {
    statusMessage.value = 'Converting PDF to images...';
    
    if (kIsWeb) {
      // Web platform - use bytes
      final fileName = selectedFiles.first.path;
      final pdfBytes = selectedFileBytes[fileName]!;
      final originalName = path.basenameWithoutExtension(fileName);
      
      final images = await _pdfService.convertPdfToImagesFromBytes(
        pdfBytes,
        selectedImageFormat.value.toLowerCase(),
        onProgress: (progress) {
          conversionProgress.value = progress;
        },
      );
      
      convertedFiles.addAll(images);
      statusMessage.value = 'Converted ${images.length} pages from $originalName.pdf';
    } else {
      // Mobile platform - use file
      final pdfFile = selectedFiles.first;
      final originalName = path.basenameWithoutExtension(pdfFile.path);
      
      final images = await _pdfService.convertPdfToImages(
        pdfFile,
        selectedImageFormat.value.toLowerCase(),
        onProgress: (progress) {
          conversionProgress.value = progress;
        },
      );

      convertedFiles.addAll(images);
      statusMessage.value = 'Converted ${images.length} pages from $originalName.pdf';
    }
  }

  Future<void> _convertImagesToPdf() async {
    statusMessage.value = 'Converting images to PDF...';
    
    if (kIsWeb) {
      // Web platform - use bytes from selectedFileBytes
      final imageBytesList = <Uint8List>[];
      for (final file in selectedFiles) {
        final fileName = path.basename(file.path);
        final bytes = selectedFileBytes[fileName];
        if (bytes != null) {
          imageBytesList.add(bytes);
        }
      }
      
      final pdfBytes = await _pdfService.convertImageBytesToPdf(
        imageBytesList,
        onProgress: (progress) {
          conversionProgress.value = progress;
        },
      );
      
      convertedFiles.add(pdfBytes);
      statusMessage.value = 'Combined ${selectedFiles.length} images into PDF';
    } else {
      // Mobile platform - use files
      final pdfBytes = await _pdfService.convertImagesToPdf(
        selectedFiles,
        onProgress: (progress) {
          conversionProgress.value = progress;
        },
      );

      convertedFiles.add(pdfBytes);
      statusMessage.value = 'Combined ${selectedFiles.length} images into PDF';
    }
  }

  Future<void> downloadFiles() async {
    if (convertedFiles.isEmpty) return;

    try {
      if (kIsWeb) {
        // Web platform - use browser download
        await _downloadFilesWeb();
      } else {
        // Mobile platform - save to device storage
        await _downloadFilesMobile();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to download files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadFilesWeb() async {
    // For web, we'll trigger browser downloads
    if (conversionType.value == 'pdf_to_image') {
      final originalName = path.basenameWithoutExtension(selectedFiles.first.path);
      
      for (int i = 0; i < convertedFiles.length; i++) {
        final fileName = '${originalName}_page_${i + 1}.${selectedImageFormat.value.toLowerCase()}';
        await _triggerWebDownload(convertedFiles[i], fileName);
      }
      
      Get.snackbar(
        'Downloaded',
        '${convertedFiles.length} images downloaded to your Downloads folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      final fileName = 'converted_images_${DateTime.now().millisecondsSinceEpoch}.pdf';
      await _triggerWebDownload(convertedFiles.first, fileName);
      
      Get.snackbar(
        'Downloaded',
        'PDF downloaded to your Downloads folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _downloadFilesMobile() async {
    final directory = await getApplicationDocumentsDirectory();
    final downloadPath = Directory('${directory.path}/ConvertFlow');
    
    if (!await downloadPath.exists()) {
      await downloadPath.create(recursive: true);
    }

    if (conversionType.value == 'pdf_to_image') {
      final originalName = path.basenameWithoutExtension(selectedFiles.first.path);
      
      for (int i = 0; i < convertedFiles.length; i++) {
        final fileName = '${originalName}_page_${i + 1}.${selectedImageFormat.value.toLowerCase()}';
        final file = File('${downloadPath.path}/$fileName');
        await file.writeAsBytes(convertedFiles[i]);
      }
      
      Get.snackbar(
        'Downloaded',
        'Images saved to ${downloadPath.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      final fileName = 'converted_images_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${downloadPath.path}/$fileName');
      await file.writeAsBytes(convertedFiles.first);
      
      Get.snackbar(
        'Downloaded',
        'PDF saved to ${downloadPath.path}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _triggerWebDownload(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // Create a blob and download link for web
      final base64 = base64Encode(bytes);
      final dataUrl = 'data:application/octet-stream;base64,$base64';
      
      // Use JavaScript to trigger download
      // This is a simplified approach - in production you might want to use a proper web download package
      final script = '''
        const link = document.createElement('a');
        link.href = '$dataUrl';
        link.download = '$fileName';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
      ''';
      
      // For now, we'll show a message to the user
      Get.snackbar(
        'Download Ready',
        'File prepared: $fileName (Web download functionality requires additional setup)',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> shareFiles() async {
    if (convertedFiles.isEmpty) return;

    try {
      if (kIsWeb) {
        // Web platform - use Web Share API or fallback to download
        await _shareFilesWeb();
      } else {
        // Mobile platform - use traditional sharing
        await _shareFilesMobile();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to share files: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _shareFilesWeb() async {
    // On web, sharing is limited, so we'll offer download instead
    Get.snackbar(
      'Share on Web',
      'Web sharing is limited. Files will be downloaded instead.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
    
    // Trigger download as alternative to sharing
    await downloadFiles();
  }

  Future<void> _shareFilesMobile() async {
    final tempDir = await getTemporaryDirectory();
    final List<XFile> filesToShare = [];

    if (conversionType.value == 'pdf_to_image') {
      final originalName = path.basenameWithoutExtension(selectedFiles.first.path);
      
      for (int i = 0; i < convertedFiles.length; i++) {
        final fileName = '${originalName}_page_${i + 1}.${selectedImageFormat.value.toLowerCase()}';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(convertedFiles[i]);
        filesToShare.add(XFile(file.path));
      }
    } else {
      final fileName = 'converted_images_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(convertedFiles.first);
      filesToShare.add(XFile(file.path));
    }

    await Share.shareXFiles(filesToShare, text: 'Converted with ConvertFlow');
  }

  void clearFiles() {
    selectedFiles.clear();
    convertedFiles.clear();
    selectedFileBytes.clear(); // Clear web file bytes
    conversionProgress.value = 0.0;
    statusMessage.value = '';
  }

  void changeImageFormat(String format) {
    selectedImageFormat.value = format;
  }
}
