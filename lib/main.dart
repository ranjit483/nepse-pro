import 'package:flutter/material.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';

// IMPORTANT: Replace these with your actual Supabase URL and Anon Key
const supabaseUrl = 'https://tcejglrvmvvnevajbivw.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlla2Nvanpva2ZvY3Njd2txcGRpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk2Mzc0MTQsImV4cCI6MjA5NTIxMzQxNH0.cE842G6sLE2XxRuwPvSu30FS-O2z0ED3a9KjQkLAhF0';

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
  late StreamSubscription<AuthState> _authStateSubscription;

  @override
  void initState() {
    super.initState();
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
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
