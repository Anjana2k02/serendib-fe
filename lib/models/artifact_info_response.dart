class ArtifactDetails {
  final String artifactName;
  final String category;
  final String era;
  final String material;
  final String artifactDetails;

  ArtifactDetails({
    required this.artifactName,
    required this.category,
    required this.era,
    required this.material,
    required this.artifactDetails,
  });

  factory ArtifactDetails.fromJson(Map<String, dynamic> json) {
    return ArtifactDetails(
      artifactName: json['artifact_name'] ?? '',
      category: json['category'] ?? '',
      era: json['era'] ?? '',
      material: json['material'] ?? '',
      artifactDetails: json['artifact_details'] ?? '',
    );
  }
}

class PredictionResponse {
  final String predLabel;
  final ArtifactDetails? artifact;

  PredictionResponse({
    required this.predLabel,
    this.artifact,
  });

  factory PredictionResponse.fromJson(Map<String, dynamic> json) {
    return PredictionResponse(
      predLabel: json['pred_label'] ?? '',
      artifact: json['artifact'] != null
          ? ArtifactDetails.fromJson(json['artifact'])
          : null,
    );
  }
}

class PredictionItem {
  final String label;
  final double confidence;

  PredictionItem({
    required this.label,
    required this.confidence,
  });

  factory PredictionItem.fromJson(List<dynamic> json) {
    try {
      print('Parsing PredictionItem from: $json');
      return PredictionItem(
        label: json[0] as String,
        confidence: (json[1] as num).toDouble(),
      );
    } catch (e) {
      print('Error parsing PredictionItem: $e');
      rethrow;
    }
  }

  List<dynamic> toJson() {
    return [label, confidence];
  }

  String get confidencePercentage =>
      '${(confidence * 100).toStringAsFixed(2)}%';
}
