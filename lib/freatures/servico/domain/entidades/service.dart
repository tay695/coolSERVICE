class Service {
  final String id;
  final String name;
  final String description;
  final double basePrice;
  final bool isExternal;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.basePrice,
    this.isExternal = false,
  });
}
