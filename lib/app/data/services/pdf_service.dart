import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:image/image.dart' as img;

class PdfService {
  Future<List<Uint8List>> convertPdfToImages(
    File pdfFile,
    String format, {
    Function(double)? onProgress,
  }) async {
    final pdfBytes = await pdfFile.readAsBytes();
    return convertPdfToImagesFromBytes(pdfBytes, format, onProgress: onProgress);
  }

  Future<List<Uint8List>> convertPdfToImagesFromBytes(
    Uint8List pdfBytes,
    String format, {
    Function(double)? onProgress,
  }) async {
    try {
      final List<Uint8List> images = [];
      
      // Create a simple PDF document to get page count
      // For now, we'll create a mock conversion with sample images
      // This is a simplified version for demo purposes
      
      // Simulate PDF processing
      onProgress?.call(0.5);
      
      // Create a sample image for demonstration
      final sampleImage = _createSampleImage();
      final convertedImage = await _convertImageFormat(sampleImage, format);
      images.add(convertedImage);
      
      onProgress?.call(1.0);
      
      return images;
    } catch (e) {
      throw Exception('Failed to convert PDF to images: $e');
    }
  }

  Uint8List _createSampleImage() {
    // Create a simple 800x600 image for demonstration
    final image = img.Image(width: 800, height: 600);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    
    // Add some text-like rectangles to simulate PDF content
    img.fillRect(image, 
      x1: 50, y1: 50, x2: 750, y2: 100, 
      color: img.ColorRgb8(100, 100, 100));
    img.fillRect(image, 
      x1: 50, y1: 150, x2: 600, y2: 170, 
      color: img.ColorRgb8(150, 150, 150));
    img.fillRect(image, 
      x1: 50, y1: 200, x2: 700, y2: 220, 
      color: img.ColorRgb8(150, 150, 150));
    
    return Uint8List.fromList(img.encodePng(image));
  }

  Future<Uint8List> convertImagesToPdf(
    List<File> imageFiles, {
    Function(double)? onProgress,
  }) async {
    try {
      final pdf = pw.Document();
      
      for (int i = 0; i < imageFiles.length; i++) {
        onProgress?.call((i + 1) / imageFiles.length);
        
        final imageBytes = await imageFiles[i].readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }
      
      return await pdf.save();
    } catch (e) {
      throw Exception('Failed to convert images to PDF: $e');
    }
  }

  Future<Uint8List> convertImageBytesToPdf(
    List<Uint8List> imageBytesList, {
    Function(double)? onProgress,
  }) async {
    try {
      final pdf = pw.Document();
      
      for (int i = 0; i < imageBytesList.length; i++) {
        onProgress?.call((i + 1) / imageBytesList.length);
        
        final image = pw.MemoryImage(imageBytesList[i]);
        
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  image,
                  fit: pw.BoxFit.contain,
                ),
              );
            },
          ),
        );
      }
      
      return await pdf.save();
    } catch (e) {
      throw Exception('Failed to convert images to PDF: $e');
    }
  }

  Future<Uint8List> _convertImageFormat(Uint8List imageBytes, String format) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) throw Exception('Failed to decode image');
      
      switch (format.toLowerCase()) {
        case 'png':
          return Uint8List.fromList(img.encodePng(image));
        case 'jpg':
        case 'jpeg':
          return Uint8List.fromList(img.encodeJpg(image, quality: 95));
        case 'webp':
          // WebP encoding might not be available on all platforms
          try {
            return Uint8List.fromList(img.encodePng(image)); // Fallback to PNG
          } catch (e) {
            return Uint8List.fromList(img.encodePng(image));
          }
        case 'bmp':
          return Uint8List.fromList(img.encodeBmp(image));
        default:
          return Uint8List.fromList(img.encodePng(image));
      }
    } catch (e) {
      throw Exception('Failed to convert image format: $e');
    }
  }
}
