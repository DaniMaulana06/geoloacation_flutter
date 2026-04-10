import 'package:crud_app/features/todo/domain/entities/location_entity.dart';

class LocationModel extends LocationEntity {
  LocationModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    final coordString = json['coordinates'] as String?;
    final rawCorrds = coordString
        ?.replaceAll('POINT(', '')
        .replaceAll(')', '')
        .split(' ');

    return LocationModel(
      id: json['id'],
      name: json['name'],
      latitude: double.parse(rawCorrds![1]),
      longitude: double.parse(rawCorrds[0]),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'coordinates' : 'POINT($latitude $longitude)'
    };
  }
}
