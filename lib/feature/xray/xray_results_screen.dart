import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_theme.dart';
import 'package:diesease_ai_app/feature/xray/xray_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'xray_repository.dart';

const _kPrimary = AppColors.primary;
const _kInk = AppColors.ink;
const _kMuted = AppColors.muted;
const _kGreen = AppColors.success;
const _kOrange = AppColors.warning;
const _kBlue = AppColors.info;

class XrayResultScreen extends StatefulWidget {
  final String scanId;
  const XrayResultScreen(this.scanId, {super.key});

  @override
  State<XrayResultScreen> createState() => _XrayResultScreenState();
}

class _XrayResultScreenState extends State<XrayResultScreen> {
  late Stream<XrayResult> _resultStream;

  @override
  void initState() {
    super.initState();
    _resultStream = context.read<XrayRepository>().watch(widget.scanId);
  }

  @override
  void didUpdateWidget(covariant XrayResultScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scanId != widget.scanId) {
      _resultStream = context.read<XrayRepository>().watch(widget.scanId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(strings.results), centerTitle: true),
      body: StreamBuilder<XrayResult>(
        stream: _resultStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _ErrorState(message: snapshot.error.toString());
          }
          final result = snapshot.data;
          if (result == null) return _Waiting(text: strings.analyzing);
          if (!result.isDone) {
            return _Waiting(
              text: result.status == 'processing'
                  ? strings.analyzingImage
                  : strings.waitingInQueue,
            );
          }
          if (result.error != null) {
            return _ErrorState(message: strings.scanError(result.error));
          }
          return _Done(result);
        },
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  final String text;
  const _Waiting({required this.text});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 96,
                  width: 96,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation(
                      _kPrimary.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 60,
                  child: CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation(_kPrimary),
                  ),
                ),
                const Icon(
                  Icons.medical_information_rounded,
                  color: _kPrimary,
                  size: 26,
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kInk,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              strings.mayTakeMinutes,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMuted, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.errorSoft,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kInk,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  final XrayResult r;
  const _Done(this.r);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final review = r.requiresReview;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            _StatusBanner(review: review, confidence: r.confidence),
            const SizedBox(height: 14),
            _SyncBadge(synced: r.syncedToDhis2),
            if (r.findings.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                strings.results,
                style: const TextStyle(
                  color: _kInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              ...r.findings.map((f) => _FindingTile(finding: f)),
            ],
            if (r.flaggedRegions.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                strings.flaggedRegions,
                style: const TextStyle(
                  color: _kInk,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: r.flaggedRegions
                    .map((e) => _RegionChip(label: e))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),
            _DisclaimerCard(strings: strings),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool review;
  final String? confidence;
  const _StatusBanner({required this.review, required this.confidence});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final accent = review ? _kOrange : _kGreen;
    final light = review ? AppColors.warningSoft : AppColors.successSoft;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  review ? Icons.flag_rounded : Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review ? strings.doctorReview : strings.noFindings,
                      style: const TextStyle(
                        color: _kInk,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strings.confidence(confidence),
                      style: const TextStyle(
                        color: _kMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ConfidenceMeter(value: confidence),
        ],
      ),
    );
  }
}

class _ConfidenceMeter extends StatelessWidget {
  final String? value;
  const _ConfidenceMeter({required this.value});

  double _fraction() => switch ((value ?? 'low').toLowerCase()) {
    'high' => 1.0,
    'medium' => 0.6,
    'low' => 0.3,
    _ => 0.3,
  };

  Color _color() => switch ((value ?? 'low').toLowerCase()) {
    'high' => _kGreen,
    'medium' => const Color(0xFFD8A13A),
    'low' => _kOrange,
    _ => _kOrange,
  };

  @override
  Widget build(BuildContext context) {
    final f = _fraction();
    final c = _color();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: f,
            minHeight: 8,
            backgroundColor: c.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(c),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              (value ?? '-').toUpperCase(),
              style: TextStyle(
                color: c,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
            Text(
              '${(f * 100).round()}%',
              style: TextStyle(
                color: c,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SyncBadge extends StatelessWidget {
  final bool synced;
  const _SyncBadge({required this.synced});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final color = synced ? _kGreen : _kBlue;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(
                synced ? Icons.cloud_done_rounded : Icons.cloud_upload_outlined,
                size: 15,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                synced ? strings.synced : strings.notSynced,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FindingTile extends StatelessWidget {
  final String finding;
  const _FindingTile({required this.finding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 3),
              height: 8,
              width: 8,
              decoration: const BoxDecoration(
                color: _kPrimary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                finding,
                style: const TextStyle(
                  color: _kInk,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  const _RegionChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kOrange.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.rectangle_outlined, size: 14, color: _kOrange),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _kOrange,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  final AppStrings strings;
  const _DisclaimerCard({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.soft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: _kPrimary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.medicalDisclaimer,
              style: const TextStyle(
                color: Color(0xFF4D625B),
                height: 1.5,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
