import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/data/repositories/sqlite_funcionario_repository.dart';
import 'package:flutter/material.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = SQLiteFuncionarioRepository();
    final todos = await repo.listAll();

    final funcionario = todos.cast<Funcionario?>().firstWhere(
      (f) =>
          f!.username == _usernameController.text.trim() &&
          f.passwordHash == _passwordController.text.trim(),
      orElse: () => null,
    );

    setState(() => _isLoading = false);

    if (funcionario == null) {
      setState(() => _error = 'Usuário ou senha incorretos.');
      return;
    }

    Navigator.pushReplacement(context,
    MaterialPageRoute(builder: (_) => DashboardPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noiteArtica,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // logo / ícone
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.azulProfundo,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cianoFrio.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.build_circle_outlined,
                  size: 64,
                  color: AppColors.cianoFrio,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'CollSERVICE',
                style: TextStyle(
                  color: AppColors.brancoPuro,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Faça login para continuar',
                style: TextStyle(
                  color: AppColors.cinzaNeve,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 40),

              // campo usuário
              TextField(
                controller: _usernameController,
                style: const TextStyle(color: AppColors.brancoPuro),
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: const TextStyle(color: AppColors.azulGelo),
                  prefixIcon: const Icon(Icons.person_outline, color: AppColors.azulGelo),
                  filled: true,
                  fillColor: AppColors.azulProfundo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cianoFrio, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // campo senha
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.brancoPuro),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(color: AppColors.azulGelo),
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.azulGelo),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.cinzaNeve,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppColors.azulProfundo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.cianoFrio, width: 1.5),
                  ),
                ),
              ),

              // erro
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(color: AppColors.inactive, fontSize: 13),
                ),
              ],

              const SizedBox(height: 32),

              // botão
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cianoFrio,
                    foregroundColor: AppColors.noiteArtica,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.noiteArtica,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}