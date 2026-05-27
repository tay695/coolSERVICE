import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:coolservice/core/theme/app_theme.dart';

class ClientFormPage extends StatefulWidget {
  final Client? client;
  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfCnpjController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.client != null) {
      _nomeController.text = widget.client!.name;
      _cpfCnpjController.text = widget.client!.cpfCnpj;
      _enderecoController.text = widget.client!.address;
      _telefoneController.text = widget.client!.phone;
      _emailController.text = widget.client!.email;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfCnpjController.dispose();
    _enderecoController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: AppColors.azulGelo, size: 20) : null,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.noiteArtica
          : AppColors.brancoPuro,
      labelStyle: const TextStyle(color: AppColors.azulProfundo, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulGelo, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulGelo, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inactive, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.inactive, width: 2),
      ),
    );
  }

  Widget _buildSectionCard({required String label, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.azulProfundo.withOpacity(0.4)
            : AppColors.brancoPuro,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.azulGelo.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.azulCeu,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ClientViewModel>();
    final isEditing = widget.client != null;

    return Scaffold(
            appBar: AppBar(title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.azulProfundo, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.azulCeu.withOpacity(0.18),
                      border: Border.all(color: AppColors.azulGelo.withOpacity(0.4), width: 1.5),
                    ),
                    child: const Icon(Icons.person_outline, color: AppColors.brancoPuro, size: 28),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isEditing ? 'Editar cliente' : 'Novo cliente',
                    style: const TextStyle(color: AppColors.brancoPuro, fontSize: 17, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Preencha os dados do cliente',
                    style: TextStyle(color: AppColors.azulGelo, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSectionCard(
              label: 'Dados pessoais',
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: _fieldDecoration('Nome completo', icon: Icons.person_outline),
                  validator: (v) => v!.isEmpty ? 'Informe o nome' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cpfCnpjController,
                  decoration: _fieldDecoration('CPF / CNPJ', icon: Icons.badge_outlined),
                  validator: (v) => v!.isEmpty ? 'Informe o CPF/CNPJ' : null,
                ),
              ],
            ),

            const SizedBox(height: 12),

            _buildSectionCard(
              label: 'Contato',
              children: [
                TextFormField(
                  controller: _telefoneController,
                  decoration: _fieldDecoration('Telefone', icon: Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Informe o telefone' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: _fieldDecoration('E-mail', icon: Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _enderecoController,
                  decoration: _fieldDecoration('Endereço', icon: Icons.location_on_outlined),
                ),
              ],
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: AppColors.azulCeu, fontSize: 14)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.brancoPuro,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brancoPuro.withOpacity(0.18),
                  ),
                  child: const Icon(Icons.check_rounded, size: 16),
                ),
                label: Text(
                  isEditing ? 'Salvar cliente' : 'Cadastrar cliente',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final client = Client(
                      id: widget.client?.id ?? DateTime.now().toString(),
                      name: _nomeController.text,
                      cpfCnpj: _cpfCnpjController.text,
                      address: _enderecoController.text,
                      phone: _telefoneController.text,
                      email: _emailController.text,
                    );
                    if (isEditing) {
                      await viewModel.updateClient(client);
                    } else {
                      await viewModel.createClient(client);
                    }
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}