import 'package:flutter/material.dart';

class CarrouselImages extends StatelessWidget {
  final List<String> images;

  const CarrouselImages({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PageView.builder(
        itemCount: images.length,
        itemBuilder: (_, index) => Image.asset(
          images[index],
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}