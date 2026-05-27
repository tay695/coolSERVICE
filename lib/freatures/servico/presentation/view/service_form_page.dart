import 'package:coolservice/core/widgets/menu_lateral.dart';
import 'package:coolservice/freatures/servico/domain/entidades/service.dart';
import 'package:coolservice/freatures/servico/presentation/view_model/Service_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ServiceFormPage extends StatefulWidget {
  final Service? service;
  const ServiceFormPage({super.key, this.service});

  @override
  State<ServiceFormPage> createState() => _ServiceFormPageState();
}

class _ServiceFormPageState extends State<ServiceFormPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  TipoAtendimento _selectedTipo = TipoAtendimento.manutencao;
  bool _isExternal = false;

  @override
  void initState() {
    super.initState();
    if (widget.service != null) {
      _nameController.text = widget.service!.name;
      _descriptionController.text = widget.service!.description;
      _basePriceController.text = widget.service!.basePrice.toString();
      _selectedTipo = widget.service!.tipoAtendimento;
      _isExternal = widget.service!.isExternal;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.service != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Serviço' : 'Novo Serviço'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Serviço',
                hintText: 'Ex: Manutenção Preventiva',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descrição',
                hintText: 'Descreva detalhadamente o serviço',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _basePriceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Preço Base (R\$)',
                hintText: '0.00',
                prefixText: 'R\$ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TipoAtendimento>(
              initialValue: _selectedTipo,
              decoration: const InputDecoration(
                labelText: 'Tipo de Atendimento',
                border: OutlineInputBorder(),
              ),
              items: TipoAtendimento.values
                  .map(
                    (tipo) => DropdownMenuItem(
                      value: tipo,
                      child: Text(_getTipoLabel(tipo)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedTipo = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Serviço Externo'),
              subtitle: const Text('Este serviço é realizado por terceiros?'),
              value: _isExternal,
              onChanged: (value) => setState(() => _isExternal = value),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveService,
                    child: Text(isEditing ? 'Salvar' : 'Cadastrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveService() async {
    // Validações
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome do serviço é obrigatório')),
      );
      return;
    }

    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Descrição é obrigatória')));
      return;
    }

    if (_basePriceController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preço base é obrigatório')));
      return;
    }

    final basePrice = double.tryParse(
      _basePriceController.text.replaceAll(',', '.'),
    );

    if (basePrice == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preço inválido')));
      return;
    }

    try {
      final viewModel = context.read<ServiceViewModel>();
      final isEditing = widget.service != null;
      final service = Service(
        id: widget.service?.id ?? DateTime.now().toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        basePrice: basePrice,
        tipoAtendimento: _selectedTipo,
        isExternal: _isExternal,
      );

      if (isEditing) {
        await viewModel.updateService(service);
      } else {
        await viewModel.createService(service);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Serviço atualizado com sucesso'
                : 'Serviço cadastrado com sucesso',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar serviço: $e')));
    }
  }

  String _getTipoLabel(TipoAtendimento tipo) {
    switch (tipo) {
      case TipoAtendimento.manutencao:
        return 'Manutenção';
      case TipoAtendimento.instalacao:
        return 'Instalação';
      case TipoAtendimento.visitaTecnica:
        return 'Visita Técnica';
    }
  }
}
