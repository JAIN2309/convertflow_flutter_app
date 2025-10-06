import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class ImageService {
  Future<Uint8List> resizeImage(
    File imageFile,
    int width,
    int height, {
    bool maintainAspectRatio = true,
  }) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      img.Image resizedImage;
      
      if (maintainAspectRatio) {
        resizedImage = img.copyResize(
          image,
          width: width,
          height: height,
          interpolation: img.Interpolation.linear,
        );
      } else {
        resizedImage = img.copyResize(
          image,
          width: width,
          height: height,
        );
      }
      
      return Uint8List.fromList(img.encodePng(resizedImage));
    } catch (e) {
      throw Exception('Failed to resize image: $e');
    }
  }

  Future<Uint8List> convertImageFormat(
    File imageFile,
    String targetFormat,
  ) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      switch (targetFormat.toLowerCase()) {
        case 'png':
          return Uint8List.fromList(img.encodePng(image));
        case 'jpg':
        case 'jpeg':
          return Uint8List.fromList(img.encodeJpg(image, quality: 95));
        case 'webp':
          // WebP encoding might not be available on all platforms
          return Uint8List.fromList(img.encodePng(image)); // Fallback to PNG
        case 'bmp':
          return Uint8List.fromList(img.encodeBmp(image));
        default:
          throw Exception('Unsupported format: $targetFormat');
      }
    } catch (e) {
      throw Exception('Failed to convert image format: $e');
    }
  }

  Future<Map<String, dynamic>> getImageInfo(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      return {
        'width': image.width,
        'height': image.height,
        'format': _getImageFormat(imageFile.path),
        'size': imageBytes.length,
      };
    } catch (e) {
      throw Exception('Failed to get image info: $e');
    }
  }

  String _getImageFormat(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'JPEG';
      case 'png':
        return 'PNG';
      case 'webp':
        return 'WEBP';
      case 'bmp':
        return 'BMP';
      case 'gif':
        return 'GIF';
      default:
        return 'Unknown';
    }
  }

  Future<bool> isValidImageFile(File file) async {
    try {
      final imageBytes = await file.readAsBytes();
      final image = img.decodeImage(imageBytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
}
