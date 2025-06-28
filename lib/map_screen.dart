import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _origin;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  List<String> _instructions = [];
  List<Marker> _driverMarkers = [];

  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _setCurrentLocationAsOrigin();
  }

  Future<void> _setCurrentLocationAsOrigin() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialog('Por favor, habilite o serviço de localização no dispositivo.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showDialog('Permissão para localização negada.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showDialog('Permissão para localização negada permanentemente.');
      return;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final coords = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _origin = coords;
      _originController.text = 'Minha localização atual';
      _mapController.move(_origin!, 13);
      _generateFakeDrivers();
    });
  }

  Future<void> _searchCoordinates(String query, bool isOrigin) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );

    final response = await http.get(url, headers: {
      'User-Agent': 'FlutterAppProjetoDetran/1.0'
    });

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final coords = LatLng(lat, lon);

        setState(() {
          if (isOrigin) {
            _origin = coords;
            _originController.text = query;
          } else {
            _destination = coords;
            _destinationController.text = query;
          }
          _mapController.move(coords, 13);
          _routePoints.clear();
          _instructions.clear();
          _driverMarkers.clear();
          if (_origin != null) _generateFakeDrivers();
        });
      } else {
        _showDialog('Endereço não encontrado.');
      }
    } else {
      _showDialog('Erro ao buscar endereço.');
    }
  }

  Future<void> _fetchRoute() async {
    if (_origin == null || _destination == null) {
      _showDialog('Por favor, defina origem e destino.');
      return;
    }

    final apiKey = 'SUA_API_KEY_OPENROUTESERVICE'; // <<< Substitua pela sua chave
    final url = Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=$apiKey&start=${_origin!.longitude},${_origin!.latitude}&end=${_destination!.longitude},${_destination!.latitude}');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['features'][0]['geometry']['coordinates'] as List<dynamic>;
      final segments = data['features'][0]['properties']['segments'][0];
      final steps = segments['steps'] as List<dynamic>;

      List<LatLng> points = coords.map((c) {
        return LatLng(c[1], c[0]);
      }).toList();

      List<String> instructions = steps.map((step) {
        return step['instruction'] as String;
      }).toList();

      setState(() {
        _routePoints = points;
        _instructions = instructions;
      });

      _mapController.fitBounds(
        LatLngBounds.fromPoints(_routePoints),
        options: const FitBoundsOptions(padding: EdgeInsets.all(20)),
      );
    } else {
      _showDialog('Erro ao obter rota: ${response.statusCode}');
    }
  }

  void _generateFakeDrivers() {
    if (_origin == null) return;
    final random = Random();
    List<Marker> drivers = [];

    for (int i = 0; i < 5; i++) {
      final dx = (random.nextDouble() - 0.5) / 100;
      final dy = (random.nextDouble() - 0.5) / 100;
      final driverPos = LatLng(_origin!.latitude + dx, _origin!.longitude + dy);

      drivers.add(Marker(
        point: driverPos,
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showDriverOptions(driverPos),
          child: const Icon(Icons.local_taxi, color: Colors.green, size: 36),
        ),
      ));
    }

    setState(() {
      _driverMarkers = drivers;
    });
  }

  void _showDriverOptions(LatLng driverPos) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Motorista próximo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text('Localização: ${driverPos.latitude.toStringAsFixed(5)}, ${driverPos.longitude.toStringAsFixed(5)}'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Chamar Motorista'),
              onPressed: () {
                Navigator.pop(context);
                _showDialog('Motorista a caminho!');
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text('Compartilhar Perfil'),
              onPressed: () {
                Navigator.pop(context);
                _showDialog('Link de perfil compartilhado!');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRouteDetails() {
    if (_instructions.isEmpty) {
      _showDialog('Nenhuma rota calculada.');
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: _instructions.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(_instructions[index]),
          ),
        ),
      ),
    );
  }

  void _showDialog(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aviso'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rota e Destino'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _originController,
                          decoration: InputDecoration(
                            hintText: 'Origem',
                            prefixIcon: const Icon(Icons.my_location),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        tooltip: 'Usar localização atual',
                        onPressed: _setCurrentLocationAsOrigin,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _destinationController,
                          decoration: InputDecoration(
                            hintText: 'Destino (ex: Av. Paulista)',
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onSubmitted: (_) async {
                            await _searchCoordinates(_destinationController.text, false);
                            await _fetchRoute();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          await _searchCoordinates(_destinationController.text, false);
                          await _fetchRoute();
                        },
                        child: const Icon(Icons.directions),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  center: _origin ?? LatLng(-20.3155, -40.3128),
                  zoom: 13,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.example.projeto_detran',
                  ),
                  if (_origin != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _origin!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (_destination != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _destination!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  if (_routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 5,
                          color: Colors.blue,
                        )
                      ],
                    ),
                  if (_driverMarkers.isNotEmpty)
                    MarkerLayer(
                      markers: _driverMarkers,
                    ),
                ],
              ),
            ),
            if (_instructions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.list),
                  label: const Text('Ver detalhes da rota'),
                  onPressed: _showRouteDetails,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
