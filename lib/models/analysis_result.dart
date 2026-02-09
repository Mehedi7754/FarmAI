class Disease {
  final String name;
  final double probability;
  final String reason;

  Disease({
    required this.name,
    required this.probability,
    required this.reason,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['রোগের_নাম'] ?? '',
      probability: (json['সম্ভাবনা_শতাংশ'] ?? 0).toDouble(),
      reason: json['কারণ'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'রোগের_নাম': name,
      'সম্ভাবনা_শতাংশ': probability,
      'কারণ': reason,
    };
  }
}

class AnalysisResult {
  final List<Disease> diseases;
  final List<String> primaryMedicines;
  final List<String> homeCare;
  final List<String> actions;

  AnalysisResult({
    required this.diseases,
    required this.primaryMedicines,
    required this.homeCare,
    required this.actions,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      diseases: (json['সম্ভাব্য_রোগসমূহ'] as List?)
              ?.map((d) => Disease.fromJson(d))
              .toList() ??
          [],
      primaryMedicines: List<String>.from(json['প্রাথমিক_ওষুধ'] ?? []),
      homeCare: List<String>.from(json['ঘরোয়া_চিকিৎসা'] ?? []),
      actions: List<String>.from(json['যে_ব্যবস্থা_নিতে_হবে'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'সম্ভাব্য_রোগসমূহ': diseases.map((d) => d.toJson()).toList(),
      'প্রাথমিক_ওষুধ': primaryMedicines,
      'ঘরোয়া_চিকিৎসা': homeCare,
      'যে_ব্যবস্থা_নিতে_হবে': actions,
    };
  }
}
