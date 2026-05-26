enum TipoAtendimento {
  manutencao,
  instalacao,
  visitaTecnica,
}

class Service {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final TipoAtendimento tipoAtendimento;
  final bool isExternal;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.tipoAtendimento,
    required this.isExternal,
  });
}
