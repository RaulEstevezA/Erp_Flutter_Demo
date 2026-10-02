import 'package:url_launcher/url_launcher.dart';

/// Abre unas coordenadas en Google Maps (app si está instalada, si no web).
Future<void> openInMaps(double latitude, double longitude) {
  return launchUrl(
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$latitude,$longitude',
    }),
    mode: LaunchMode.externalApplication,
  );
}
