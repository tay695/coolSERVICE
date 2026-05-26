import 'package:coolservice/freatures/clientes/data/repositories/sqlite_client_repository.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:coolservice/freatures/funcionarios/data/repositories/sqlite_funcionario_repository.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/funcionario_list_page.dart';
import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:coolservice/freatures/servico/data/repositories/shared_preferences_service_repository.dart';
import 'package:coolservice/freatures/servico/data/repositories/sqlite_service_repository.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = PreferencesService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigViewModel(prefService)),
        ChangeNotifierProvider(
          create: (_) => FuncionarioViewModel(SQLiteFuncionarioRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ClientViewModel(SQLiteClientRepository()),
        ),
        ChangeNotifierProvider(
          create: (_) => ServiceViewModel(
            kIsWeb
                ? SharedPreferencesServiceRepository()
                : SQLiteServiceRepository(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final configViewModel = context.watch<AppConfigViewModel>();

    return MaterialApp(
      title: 'CoolService',
      debugShowCheckedModeBanner: false,
      themeMode: configViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      // Lógica de roteamento inicial pelo SharedPreferences
      home: configViewModel.isFirstTime
          ? Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AppConfigViewModel>().completeOnboarding();
                  },
                  child: const Text('Sair do Tutorial e Ir para o App'),
                ),
              ),
            )
          : const FuncionarioListPage(),
    );
  }
}
