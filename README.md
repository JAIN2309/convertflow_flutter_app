# ConvertFlow - PDF & Image Converter


**ConvertFlow** is a modern, cross-platform mobile application built with Flutter that provides seamless conversion between PDF files and various image formats. Transform your documents effortlessly while preserving original file names.

## ✨ Features

### 🔄 **Dual Conversion Modes**
- **PDF to Images**: Convert PDF pages to JPG, PNG, WEBP, BMP formats
- **Images to PDF**: Combine multiple images into a single PDF document

### 🎨 **Modern UI/UX**
- Beautiful Material 3 design with light/dark theme support
- Intuitive splash screen with smooth animations
- Progress indicators for conversion tracking
- Real-time file preview and status updates

### 📱 **Cross-Platform Support**
- **Android**: Native mobile experience
- **iOS**: Optimized for iPhone and iPad
- **Web**: Browser-based access with full functionality

### 🔧 **Advanced Features**
- **File Name Preservation**: Maintains original file names during conversion
- **Multiple Format Support**: JPG, PNG, WEBP, BMP image formats
- **Batch Processing**: Convert multiple files simultaneously
- **High Quality Output**: Maintains image quality during conversion
- **Share & Download**: Easy file sharing and local storage options

## 🏗️ Architecture

ConvertFlow follows **Clean Architecture** principles with **GetX** state management:

```
lib/
├── app/
│   ├── core/
│   │   └── theme/           # App theming and styling
│   ├── data/
│   │   └── services/        # Business logic services
│   ├── modules/
│   │   ├── splash/          # Splash screen module
│   │   ├── home/            # Home screen module
│   │   └── converter/       # Conversion functionality
│   └── routes/              # Navigation and routing
└── main.dart                # App entry point
```

### 🔧 **Tech Stack**
- **Framework**: Flutter 3.6+
- **State Management**: GetX
- **PDF Processing**: Syncfusion Flutter PDF, PDF package
- **Image Processing**: Image package
- **File Operations**: File Picker, Path Provider
- **UI Components**: Material 3, Google Fonts
- **Sharing**: Share Plus

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.6.1 or higher
- Dart SDK 3.0+
- Android Studio / VS Code
- Chrome (for web development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/convertflow.git
   cd convertflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   
   **For Android:**
   ```bash
   flutter run
   ```
   
   **For Web:**
   ```bash
   flutter run -d chrome
   ```
   
   **For iOS:**
   ```bash
   flutter run -d ios
   ```

## 📱 Usage Guide

### Converting PDF to Images

1. **Launch ConvertFlow** and tap "PDF to Images"
2. **Select PDF file** using the file picker
3. **Choose output format** (PNG, JPG, WEBP, BMP)
4. **Tap Convert** to start the conversion process
5. **Download or Share** the generated images

### Converting Images to PDF

1. **Select "Images to PDF"** from the home screen
2. **Pick multiple images** from your device
3. **Tap Convert** to combine images into PDF
4. **Save or Share** the generated PDF file

## 🔧 Configuration

### Android Permissions
Add these permissions to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS Permissions
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to select images for conversion.</string>
<key>NSDocumentsFolderUsageDescription</key>
<string>This app needs access to documents to save converted files.</string>
```

## 🧪 Testing

Run tests with:
```bash
flutter test
```

For integration tests:
```bash
flutter drive --target=test_driver/app.dart
```

## 📦 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for state management solutions
- Syncfusion for PDF processing capabilities
- Material Design team for UI/UX guidelines

## 📈 Roadmap

- [ ] **Cloud Storage Integration** (Google Drive, Dropbox)
- [ ] **OCR Text Recognition** from PDFs and images
- [ ] **Batch Conversion Queue** for large file processing
- [ ] **Custom Watermarking** for converted files
- [ ] **Advanced Image Editing** tools
- [ ] **Desktop Support** (Windows, macOS, Linux)

---

**ConvertFlow** - Transform your files with ease! 🚀
