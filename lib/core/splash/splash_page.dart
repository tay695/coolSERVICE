import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navegaProximaTela();
  }

  void _navegaProximaTela() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    final configViewModel = context.read<AppConfigViewModel>();
    if (configViewModel.isFirstTime) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Onboarding'))),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.noiteArtica : AppColors.brancoGelo,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 180,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.home_repair_service,
                  size: 100,
                  color: Color.fromARGB(129, 0, 21, 45),
                );
              },
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cianoFrio),
            ),
          ],
        ),
      ),
    );
  }
}