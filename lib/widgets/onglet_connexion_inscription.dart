import 'package:flutter/material.dart';

class OngletConnexionInscription extends StatelessWidget {
  const OngletConnexionInscription({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0x4DD9D9D9), 
        borderRadius: BorderRadius.circular(6),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 3,
            top: 6,
            bottom: 6,
            child: Container(
              width: 186,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Row(
            children: const [
              Expanded(
                child: Center(
                  child: Text(
                    'Connexion',
                    style: TextStyle(fontSize: 22, fontFamily: 'Itim'),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Inscription',
                    style: TextStyle(fontSize: 22, fontFamily: 'Itim'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
