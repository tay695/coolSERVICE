
import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';
import 'package:coolservice/freatures/clientes/presentation/view_model/client_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ClientFormPage extends StatefulWidget {
  final Client? client;
  const ClientFormPage({super.key, this.client});

  @override
  State<ClientFormPage> createState() => _ClientFormPageState();
}

class _ClientFormPageState extends State<ClientFormPage> {
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

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<ClientViewModel>();
    final isEditing = widget.client != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Cliente' : 'Novo Cliente'),
      ),
    
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: 'Nome completo'),
            ),
            TextField(
              controller: _cpfCnpjController,
              decoration: const InputDecoration(labelText: 'CPF/CNPJ'),
            ),
            TextField(
              controller: _enderecoController,
              decoration: const InputDecoration(labelText: 'Endereço'),
            ),
            TextField(
              controller: _telefoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mail'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
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
              },
              child: Text(isEditing ? 'Salvar' : 'Cadastrar'),
            ),
          ],
        ),
      ),
    );
  }
}
