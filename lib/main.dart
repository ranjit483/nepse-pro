import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

// IMPORTANT: Replace these with your actual Supabase URL and Anon Key
const supabaseUrl = 'https://tcejglrvmvvnevajbivw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjZWpnbHJ2bXZ2bmV2YWpiaXZ3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3MTY1NzYsImV4cCI6MjA5NTI5MjU3Nn0.HD5dKArcDBcAoet0Sy-M_IMg-AobYjeIaYsRX5CHveA';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const NepseApp());
}

final supabase = Supabase.instance.client;

class NepseApp extends StatelessWidget {
  const NepseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEPSE Pro',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else if (event == AuthChangeEvent.signedOut) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show dashboard if user is already logged in, otherwise show onboarding
    if (supabase.auth.currentUser != null) {
      return const DashboardScreen();
    }
    return const OnboardingScreen();
  }
}
