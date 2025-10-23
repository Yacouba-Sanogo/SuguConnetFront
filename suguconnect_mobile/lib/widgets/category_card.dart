import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String iconPath;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.title,
    required this.iconPath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<bool>(
              future: _assetExists(iconPath),
              builder: (context, snapshot) {
                final exists = snapshot.data ?? false;
                if (iconPath.toLowerCase().endsWith('.svg') && exists) {
                  return SvgPicture.asset(
                    iconPath,
                    height: 40,
                    width: 40,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFFF6B35),
                      BlendMode.srcIn,
                    ),
                  );
                }
                // fallback to a raster asset with same base name, or a default icon
                try {
                  final pngPath = iconPath.replaceAll(RegExp(r'\.svg\$'), '.png');
                  return Image.asset(pngPath, height: 40, width: 40, fit: BoxFit.contain);
                } catch (_) {
                  return const Icon(Icons.image, size: 40, color: Color(0xFFFF6B35));
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }
}