class HealthStatus {
  final String status;
  final bool ollamaReachable;
  final bool modelAvailable;
  final String model;
  HealthStatus({
    required this.status,
    required this.ollamaReachable,
    required this.modelAvailable,
    required this.model,
  });
  factory HealthStatus.fromJson(Map<String, dynamic> j) => HealthStatus(
        status: j['status'] as String,
        ollamaReachable: j['ollama_reachable'] as bool? ?? false,
        modelAvailable: j['model_available'] as bool? ?? false,
        model: j['model'] as String? ?? '',
      );
  bool get isOk => status == 'ok' && ollamaReachable && modelAvailable;
  bool get isDegraded => status == 'degraded' || !ollamaReachable || !modelAvailable;
}

class XrayResult {
  final String scanId;
  final String status;
  final List<String> findings;
  final List<String> flaggedRegions;
  final String? confidence;
  final bool requiresReview;
  final bool syncedToDhis2;
  final String? error;

  XrayResult.fromJson(Map<String, dynamic> j)
      : scanId = j['scan_id'] as String,
        status = j['status'] as String,
        findings = (j['findings'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        flaggedRegions = (j['flagged_regions'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        confidence = j['confidence'] as String?,
        requiresReview = j['requires_review'] as bool? ?? true,
        syncedToDhis2 = j['synced_to_dhis2'] as bool? ?? false,
        error = j['error'] as String?;

  bool get isDone => status == 'complete' || status == 'failed';
}
