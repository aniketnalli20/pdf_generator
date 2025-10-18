import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/home_screen.dart';
import 'providers/pdf_provider.dart';
import 'splash_screen.dart';

void main() {
  runApp(const PdfApp());
}

class PdfApp extends StatelessWidget {
  const PdfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PdfProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PDF Assistant',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF001F3F), // Navy blue
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF001F3F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF001F3F),
              foregroundColor: Colors.white,
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF001F3F),
              side: const BorderSide(color: Color(0xFF001F3F)),
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF001F3F)),
        ),
        home: SplashScreen(nextScreen: const HomeScreen()),
      ),
    );
  }
}
