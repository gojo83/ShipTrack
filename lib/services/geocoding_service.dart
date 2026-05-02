import 'package:latlong2/latlong.dart';
import 'dart:math';

class GeocodingService {
  // Fake coordinates around Bangladesh for demo
  static const List<LatLng> _points = [
    LatLng(23.8103, 90.4125), // Dhaka
    LatLng(22.3569, 91.7832), // Chittagong
    LatLng(24.8949, 91.8687), // Sylhet
    LatLng(22.8456, 89.5403), // Khulna
    LatLng(24.3745, 88.6042), // Rajshahi
    LatLng(25.7439, 89.2752), // Rangpur
    LatLng(24.0049, 90.4074), // Narayanganj
    LatLng(23.4607, 90.7754), // Comilla
  ];

  Future<LatLng?> getCoordinates(String address) async {
    // Return a random Bangladesh coordinate — no API call
    final rand = Random(address.hashCode);
    return _points[rand.nextInt(_points.length)];
  }

  double calculateDistanceKm(LatLng from, LatLng to) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, from, to);
  }

  String estimateDeliveryTime(double distanceKm, String deliveryType) {
    if (deliveryType == 'Express') {
      if (distanceKm < 20) return 'within 3 hours';
      if (distanceKm < 50) return 'within 6 hours';
      if (distanceKm < 200) return 'within 12 hours';
      return 'within 1 day';
    } else {
      if (distanceKm < 20) return 'within 1 day';
      if (distanceKm < 100) return '1–2 days';
      if (distanceKm < 300) return '2–3 days';
      return '3–5 days';
    }
  }
}