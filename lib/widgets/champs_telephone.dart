import 'package:flutter/material.dart';

class ChampTelephone extends StatelessWidget {
  const ChampTelephone({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 90,
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: "223",
              items: const [
                DropdownMenuItem(value: "223", child: Text("223")),
                DropdownMenuItem(value: "221", child: Text("221")),
                DropdownMenuItem(value: "225", child: Text("225")),
              ],
              onChanged: (val) {},
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Numéro de téléphone",
              labelStyle: const TextStyle(
                fontFamily: 'Itim',
                fontSize: 16,
                color: Colors.black54,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
