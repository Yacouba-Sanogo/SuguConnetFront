import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavigationBarWidget extends StatelessWidget {
  final int? currentIndex;
  final Function(int)? onTap;

  const BottomNavigationBarWidget({
    super.key,
    this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 58,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Bouton Accueil
              _buildNavItem(
                icon: Icons.home_outlined,
                label: 'Accueil',
                index: 0,
                isSelected: currentIndex == 0,
                onTap: () => onTap?.call(0),
              ),
              // Bouton Favoris
              _buildNavItem(
                icon: Icons.favorite_border,
                label: 'Favoris',
                index: 1,
                isSelected: currentIndex == 1,
                onTap: () => onTap?.call(1),
              ),
              // Bouton Commandes
              _buildNavItem(
                icon: Icons.receipt_long_outlined,
                label: 'Commandes',
                index: 2,
                isSelected: currentIndex == 2,
                onTap: () => onTap?.call(2),
              ),
              // Bouton Profil
              _buildNavItem(
                icon: Icons.person_outline,
                label: 'Profil',
                index: 3,
                isSelected: currentIndex == 3,
                onTap: () => onTap?.call(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget pour créer un élément de navigation
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: const Color(0xFFFB662F).withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected ? const Color(0xFFFB662F) : Colors.black,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: GoogleFonts.itim(
                    fontSize: 11,
                    color: isSelected ? const Color(0xFFFB662F) : Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

