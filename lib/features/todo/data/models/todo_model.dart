import 'dart:typed_data';
import 'dart:convert';

import 'package:crud_app/features/todo/domain/entities/todo.dart';

class TodoModel extends Todo {
  TodoModel({
    required super.id,
    required super.title,
    required super.createdAt,
    required super.signatureUrl,
    super.latitude,
    super.longitude,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    double? latitude;
    double? longitude;

    // Debug: lihat format asli yang dikembalikan Supabase
    print('=== RAW coordinates: ${json['coordinates']} (type: ${json['coordinates']?.runtimeType}) ===');

    if (json['coordinates'] != null) {
      final coords = json['coordinates'];

      // Format 1: WKB Hex String (PostGIS default EWKB for points)
      // e.g. "0101000020E61000007A7DF7D8A72F5A4030AAFBB616EC07C0"
      if (coords is String &&
          coords.length >= 42 &&
          RegExp(r'^[0-9a-fA-F]+$').hasMatch(coords)) {
        try {
          // Helper to decode hex to bytes
          final bytes = <int>[];
          for (int i = 0; i < coords.length; i += 2) {
            bytes.add(int.parse(coords.substring(i, i + 2), radix: 16));
          }

          final byteData = ByteData.view(Uint8List.fromList(bytes).buffer);

          // Byte 0: Endianness (1 = little endian)
          final endian = byteData.getUint8(0) == 1 ? Endian.little : Endian.big;

          // Byte 1-4: Geometry Type (1 = Point, 0x20000000 flag = has SRID)
          final type = byteData.getUint32(1, endian);

          int offset = 5;
          if ((type & 0x20000000) != 0) {
            offset += 4; // Skip SRID
          }

          // Read X (Longitude) and Y (Latitude)
          longitude = byteData.getFloat64(offset, endian);
          offset += 8;
          latitude = byteData.getFloat64(offset, endian);
        } catch (e) {
          print('=== ERROR PARSING WKB: $e ===');
        }
      }
      // Format 2: WKT string — "POINT(longitude latitude)"
      else if (coords is String && coords.startsWith('POINT')) {
        final raw =
            coords.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
        if (raw.length == 2) {
          longitude = double.tryParse(raw[0]);
          latitude = double.tryParse(raw[1]);
        }
      }
      // Format 3: GeoJSON Map
      else if (coords is Map && coords['type'] == 'Point') {
        final list = coords['coordinates'];
        if (list is List && list.length == 2) {
          longitude = (list[0] as num).toDouble();
          latitude = (list[1] as num).toDouble();
        }
      }
    }

    return TodoModel(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']).toLocal(),
      signatureUrl: json['signatures_url'],
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt.toIso8601String(),
      'signatures_url': signatureUrl,
      'coordinates': latitude != null && longitude != null
          ? 'POINT($longitude $latitude)'
          : null,
    };
  }
}
