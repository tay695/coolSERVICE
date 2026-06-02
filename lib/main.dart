import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:coolservice/firebase_options.dart';

import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/core/app_config/presentation/viewmodels/app_config_view_model.dart';
import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/clientes/data/repositories/sqlite_client_repository.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:coolservice/freatures/funcionarios/data/repositories/sqlite_funcionario_repository.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view/login_page.dart';
import 'package:coolservice/freatures/servico/data/repositories/shared_preferences_service_repository.dart';
import 'package:coolservice/freatures/servico/data/repositories/sqlite_service_repository.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';

import 'package:coolservice/freatures/ordem_servico/data/repositories/sqlite_ordem_servico_repository.dart';
import 'package:coolservice/freatures/ordem_servico/presentation/view_model/ordem_servico_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefService = PreferencesService();
  await prefService.disableFirstTime();

  // Criação da senha Hash para o Usuário Admin Padrão
  final bytes = utf8.encode('000000');
  final hash = sha256.convert(bytes).toString();

  final repo = SQLiteFuncionarioRepository();
  await repo.save(
    Funcionario(
      id: '1',
      name: 'Admin',
      cpf: '00000000000',
      especialty: 'Gestão',
      phone: '00000000000',
      role: UserRole.admin,
      isActive: true,
      username: 'admin',
      passwordHash: hash,
    ),
  );

  // Instanciação dos Repositórios
  final funcionarioRepository = SQLiteFuncionarioRepository();
  final clienteRepository = SQLiteClientRepository();
  
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppConfigViewModel(prefService)),
        ChangeNotifierProvider(
          create: (_) => FuncionarioViewModel(funcionarioRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => ClientViewModel(clienteRepository),
        ),

        ChangeNotifierProvider(
          create: (_) => ServiceViewModel(
            kIsWeb
                ? SharedPreferencesServiceRepository()
                : SQLiteServiceRepository(),
          ),
        ),

        ChangeNotifierProvider(
          create: (_) => OrdemServicoViewModel(
            repository: SQLiteOrdemServicoRepository(),
            preferencesService: prefService,
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
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: configViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const LoginPage(),
    );
  }
}
