import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suguconnect_mobile/home_page.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()), 
      ],
      child: MaterialApp(
        title: 'SuguConnect', 
        theme: AppTheme.lightTheme, 
        debugShowCheckedModeBanner: false, 
        home: const HomePage()
      ),
    );
  }
}
