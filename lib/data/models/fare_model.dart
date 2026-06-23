import '../../domain/entities/fare.dart';

class FareModel extends Fare {
  const FareModel({
    required super.estimated,
    required super.currency,
  });

  factory FareModel.fromJson(Map<String, dynamic> json) {
    return FareModel(
      estimated: (json['estimated'] as num).toDouble(),
      currency: json['currency'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimated': estimated,
      'currency': currency,
    };
  }
}
