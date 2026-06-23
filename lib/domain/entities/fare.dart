class Fare {
  final double estimated;
  final String currency;

  const Fare({
    required this.estimated,
    required this.currency,
  });

  String get formattedFare => '${estimated.toStringAsFixed(0)} $currency';
}
