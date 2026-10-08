import 'dart:convert';
import 'dart:io';
import 'package:diesease_ai_app/core/setting.dart';
import 'package:diesease_ai_app/feature/xray/xray_model.dart';
import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class XrayRepository {
  final Dio _dio;
  final Settings _settings;
  XrayRepository(this._dio, this._settings);

  Future<String> submit(File image, String patientRef) async {
    try {
      final bytes = await image.readAsBytes();
      var b64 = base64Encode(bytes);
      final idx = b64.indexOf(',');
      if (idx != -1) b64 = b64.substring(idx + 1);
      final res = await _dio.post('/api/xray/analyze', data: {
        'image': b64,
        'facility_id': _settings.facilityId,
        'patient_ref': patientRef,
      });
      return res.data['scan_id'] as String;
    } catch (e) {
      throw mapError(e);
    }
  }

  Stream<XrayResult> watch(String scanId) async* {
    var delay = const Duration(seconds: 2);
    var waited = Duration.zero;
    const cap = Duration(minutes: 5);
    while (true) {
      try {
        final res = await _dio.get('/api/xray/results/$scanId');
        final r = XrayResult.fromJson(res.data);
        yield r;
        if (r.isDone) return;
      } catch (e) {
        throw mapError(e);
      }
      if (waited >= cap) {
        throw ApiException('Analysis timed out. Please try again.');
      }
      await Future.delayed(delay);
      waited += delay;
      delay = delay * 2;
      if (delay > const Duration(seconds: 10)) {
        delay = const Duration(seconds: 10);
      }
    }
  }

  Future<HealthStatus> healthCheck() async {
    try {
      final res = await _dio.get('/api/health');
      return HealthStatus.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      return HealthStatus(
        status: 'degraded',
        ollamaReachable: false,
        modelAvailable: false,
        model: '',
      );
    }
  }
}
