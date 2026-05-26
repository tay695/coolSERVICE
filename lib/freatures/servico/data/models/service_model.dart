import 'package:coolservice/freatures/servico/domain/entidades/service.dart';

class ServiceModel extends Service {
  ServiceModel({
    required super.id,
    required super.name,
    required super.description,
    required super.basePrice,
    required super.tipoAtendimento,
    required super.isExternal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'basePrice': basePrice,
      'tipoAtendimento': tipoAtendimento.name,
      'isExternal': isExternal ? 1 : 0,
    };
  }

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    String tipoBanco = map['tipoAtendimento'] ?? 'manutencao';
    if (tipoBanco == 'visita_tecnica' || tipoBanco == 'visitatecnica') {
      tipoBanco = 'visitaTecnica';
    }

    return ServiceModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      basePrice: (map['basePrice'] as num?)?.toDouble() ?? 0.0,
      tipoAtendimento: TipoAtendimento.values.byName(tipoBanco),
      isExternal: map['isExternal'] == 1,
    );
  }
}
