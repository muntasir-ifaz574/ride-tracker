import '../../domain/entities/driver.dart';

class DriverModel extends Driver {
  const DriverModel({
    required super.name,
    required super.vehicle,
    required super.rating,
  });

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      name: json['name'] as String,
      vehicle: json['vehicle'] as String,
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'vehicle': vehicle,
      'rating': rating,
    };
  }
}
