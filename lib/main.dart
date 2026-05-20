import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/data/repositories/sqlite_client_repository.dart';
import 'package:coolservice/data/repositories/sqlite_funcionario_repository.dart';
import 'package:coolservice/presentation/funcionarios/view/funcionario_list_page.dart';
import 'package:coolservice/presentation/funcionarios/view_model/funcionario_viewModel.dart'
    show FuncionarioViewModel;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = PreferencesService();

  // Instancie o seu repositório de funcionários aqui
  final funcionarioRepository = SQLiteFuncionarioRepository();
  final clienteRepository = SQLiteClientRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigViewModel(prefService)),

        ChangeNotifierProvider(
          create: (_) => FuncionarioViewModel(SQLiteFuncionarioRepository()),
          create: (_) => ClienteViewModel(SQLiteClientRepository()),
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
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),

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
