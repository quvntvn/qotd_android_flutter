import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Weather {
  final String city;
  final double temp;
  Weather(this.city, this.temp);
}

class WeatherService {
  static Future<Weather> current() async {
    /// permission runtime
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return Weather('Localisation désactivée', 0);
    }

    try {
      final pos = await Geolocator.getCurrentPosition();

      // Open‑Meteo (pas de clé) + reverse‑geocoding Nominatim simplifié
      final meteoUrl =
          'https://api.open-meteo.com/v1/forecast?latitude=${pos.latitude}&longitude=${pos.longitude}&current_weather=true&timezone=auto';
      final meteoRes = await http.get(Uri.parse(meteoUrl));
      if (meteoRes.statusCode != 200) throw Exception('weather fetch');
      final meteo = jsonDecode(meteoRes.body);
      final temp = meteo['current_weather']['temperature']?.toDouble() ?? 0.0;

      final geoUrl =
          'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${pos.latitude}&lon=${pos.longitude}&accept-language=fr';
      final geoRes = await http.get(Uri.parse(geoUrl));
      if (geoRes.statusCode != 200) throw Exception('geo fetch');
      final place = jsonDecode(geoRes.body);
      final city =
          place['address']['city'] ?? place['address']['village'] ?? '—';

      return Weather(city, temp);
    } catch (_) {
      return Weather('—', 0);
    }
  }
}
