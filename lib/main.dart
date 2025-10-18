import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/home_screen.dart';
import 'providers/pdf_provider.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
