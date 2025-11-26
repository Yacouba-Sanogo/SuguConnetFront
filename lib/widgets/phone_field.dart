import 'package:flutter/material.dart';

/// Widget réutilisable pour le champ téléphone avec indicatif pays
class PhoneField extends StatelessWidget {
  final String label;
  final TextEditingController phoneController;
  final String selectedCountryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final List<String> countryCodes;

  const PhoneField({
    super.key,
    required this.label,
    required this.phoneController,
    required this.selectedCountryCode,
    required this.onCountryCodeChanged,
    this.countryCodes = const ['223', '226', '225'],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Indicatif pays
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCountryCode,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: countryCodes.map((code) {
                    return DropdownMenuItem(
                      value: code,
                      child: Text(code),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onCountryCodeChanged(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Numéro de téléphone
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


