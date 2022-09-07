class Measurements {
  Measurements({
    this.upperBound,
    this.lowerBound,
    this.pulseRate,
    this.sugarLavel,
    this.weight,
  });

  String? upperBound;
  String? lowerBound;
  String? pulseRate;
  String? sugarLavel;
  String? weight;

  factory Measurements.fromJson(Map<String, dynamic> json) => Measurements(
        upperBound: json["upper_bound"],
        lowerBound: json["lower_bound"],
        pulseRate: json["pulse_rate"],
        sugarLavel: json["sugar_lavel"],
        weight: json["weight"],
      );

  Map<String, dynamic> toJson() => {
        "upper_bound": upperBound,
        "lower_bound": lowerBound,
        "pulse_rate": pulseRate,
        "sugar_lavel": sugarLavel,
        "weight": weight,
      };
}
