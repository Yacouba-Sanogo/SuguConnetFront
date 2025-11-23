import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Widget réutilisable pour afficher des images réseau avec fallback
class NetworkImageWithFallback extends StatelessWidget {
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final String? placeholder;

  const NetworkImageWithFallback({
    super.key,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    
    Widget imageWidget = FutureBuilder<String?>(
      future: imagePath != null ? apiService.buildImageUrl(imagePath!) : Future.value(null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.image,
              size: (width != null && height != null) 
                  ? (width! < height! ? width! * 0.5 : height! * 0.5)
                  : 24,
              color: Colors.grey,
            ),
          );
        }

        final url = snapshot.data!;
        Widget image = Image.network(
          url,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: borderRadius,
            ),
            child: Icon(
              Icons.image,
              size: (width != null && height != null) 
                  ? (width! < height! ? width! * 0.5 : height! * 0.5)
                  : 24,
              color: Colors.grey,
            ),
          ),
        );

        if (borderRadius != null) {
          return ClipRRect(
            borderRadius: borderRadius!,
            child: image,
          );
        }

        return image;
      },
    );

    return imageWidget;
  }
}


