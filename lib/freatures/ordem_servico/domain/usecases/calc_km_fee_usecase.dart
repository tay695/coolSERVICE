import 'dart:convert';
import 'package:http/http.dart' as http;

class CalcKmFeeUseCase {
  final double taxaPorKm;


  static const double _latEmpresa = -14.30144;
  static const double _lonEmpresa = -42.69371;


  CalcKmFeeUseCase({required this.taxaPorKm});

  // Nominatim: converte endereço do cliente em lat/lon
  Future<Map<String, double>> geocodificarEndereco(String address) async {
    print('Nominatim recebeu: $address');
    final query = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'CoolServiceApp/1.0'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar Nominatim.');
    }

    final List data = jsonDecode(response.body);
    if (data.isEmpty) {
      throw Exception(
        'Endereço não encontrado: "$address".\n'
        'Verifique o endereço cadastrado do cliente.',
      );
    }

    print('Nominatim retornou: lat=${data[0]['lat']} lon=${data[0]['lon']}');
    
    return {
      'lat': double.parse(data[0]['lat']),
      'lon': double.parse(data[0]['lon']),
    };
  }

  // OSRM: calcula distância real pela rota (só ida)
  Future<double> calcularDistanciaRota({
    required double latOrigem,
    required double lonOrigem,
    required double latDestino,
    required double lonDestino,
  }) async {
    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '$lonOrigem,$latOrigem;$lonDestino,$latDestino'
      '?overview=false',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao consultar OSRM.');
    }

    final data = jsonDecode(response.body);
    if (data['code'] != 'Ok') {
      throw Exception('OSRM não encontrou rota para este endereço.');
    }

    // OSRM retorna distância em metros
    final distanciaMetros = data['routes'][0]['legs'][0]['distance'] as num;
    return distanciaMetros / 1000;
  }

  // Calcula a taxa final
  double calcularTaxa(double distanciaKm) => distanciaKm * taxaPorKm;

  // Fluxo completo: Nominatim → OSRM → taxa 
  Future<({double distanciaKm, double taxa})> executar(
    String enderecoCliente,
    String city,
    String state,
  ) async {
    final enderecoCompleto = '${enderecoCliente.trim()}, ${city.trim()}, ${state.trim()}, Brasil';
    final destino = await geocodificarEndereco(enderecoCompleto);

    final distanciaKm = await calcularDistanciaRota(
      latOrigem: _latEmpresa,
      lonOrigem: _lonEmpresa,
      latDestino: destino['lat']!,
      lonDestino: destino['lon']!,
    );

    final taxa = calcularTaxa(distanciaKm);
    return (distanciaKm: distanciaKm, taxa: taxa);
  }
}