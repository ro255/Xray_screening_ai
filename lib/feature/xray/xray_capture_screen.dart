import 'dart:io';
import 'dart:math' as math;
import 'package:diesease_ai_app/core/app_language.dart';
import 'package:diesease_ai_app/core/app_theme.dart';
import 'package:diesease_ai_app/core/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'xray_repository.dart';

class XrayCaptureScreen extends StatefulWidget {
  const XrayCaptureScreen({super.key});

  @override
  State<XrayCaptureScreen> createState() => _XrayCaptureScreenState();
}

class _XrayCaptureScreenState extends State<XrayCaptureScreen> {
  final _patientRef = TextEditingController();
  File? _image;
  String _type = 'chest';
  bool _busy = false;

  bool get _canSubmit =>
      _image != null && _patientRef.text.trim().isNotEmpty && !_busy;

  @override
  void dispose() {
    _patientRef.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
    );
    if (picked != null && mounted) setState(() => _image = File(picked.path));
  }

  Future<void> _submit() async {
    final image = _image;
    final reference = _patientRef.text.trim();
    if (image == null || reference.isEmpty || _busy) return;

    setState(() => _busy = true);
    try {
      final id = await context.read<XrayRepository>().submit(image, reference);
      if (mounted) context.go('/xray/result/$id');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.xrayScreening)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              _ScanTypeSelector(
                selected: _type,
                onChanged: (value) => setState(() => _type = value),
              ),
              const SizedBox(height: 20),
              _PatientReferenceField(controller: _patientRef),
              const SizedBox(height: 20),
              _ImageDropZone(
                image: _image,
                onTap: () => _pick(ImageSource.gallery),
                onRemove: () => setState(() => _image = null),
              ),
              const SizedBox(height: 12),
              _PickerButtons(
                onCamera: () => _pick(ImageSource.camera),
                onGallery: () => _pick(ImageSource.gallery),
              ),
              const SizedBox(height: 28),
              ListenableBuilder(
                listenable: _patientRef,
                builder: (context, _) => _SubmitButton(
                  enabled: _canSubmit,
                  busy: _busy,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 20),
              InfoNote(
                text: strings.xrayTip,
                icon: Icons.lightbulb_outline_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScanTypeSelector extends StatelessWidget {
  const _ScanTypeSelector({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        showSelectedIcon: false,
        segments: [
          ButtonSegment<String>(
            value: 'chest',
            icon: const Icon(Icons.air_rounded),
            label: Text(strings.chest),
          ),
          ButtonSegment<String>(
            value: 'bones',
            icon: const Icon(Icons.accessibility_new_rounded),
            label: Text(strings.bones),
            tooltip: strings.comingSoon,
            enabled: false,
          ),
        ],
        selected: {selected},
        onSelectionChanged: (values) => onChanged(values.first),
      ),
    );
  }
}

class _PatientReferenceField extends StatelessWidget {
  const _PatientReferenceField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: strings.patientReference,
        hintText: strings.patientRefHint,
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
    );
  }
}

class _ImageDropZone extends StatelessWidget {
  const _ImageDropZone({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final File? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final file = image;

    return SizedBox(
      height: 260,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        child: file == null
            ? _EmptyDropZone(key: const ValueKey('empty'), onTap: onTap)
            : _ImagePreview(
                key: ValueKey(file.path),
                file: file,
                onTap: onTap,
                onRemove: onRemove,
              ),
      ),
    );
  }
}

class _EmptyDropZone extends StatelessWidget {
  const _EmptyDropZone({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: scheme.primary.withValues(alpha: 0.45),
        radius: AppRadius.lg,
      ),
      child: Material(
        color: scheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconBadge(
                  icon: Icons.add_photo_alternate_rounded,
                  size: 64,
                  iconSize: 30,
                  radius: 20,
                  background: scheme.primary,
                  foreground: scheme.onPrimary,
                ),
                const SizedBox(height: 16),
                Text(strings.noImage, style: textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(strings.tapToUpload, style: textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    super.key,
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  final File file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.onSurface,
        borderRadius: borderRadius,
        boxShadow: AppShadows.soft(scheme),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: onTap,
              child: Image.file(file, fit: BoxFit.contain),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton.filledTonal(
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.radius,
    this.strokeWidth = 1.5,
    this.dash = 7,
    this.gap = 5,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    ).deflate(strokeWidth / 2);
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.strokeWidth != strokeWidth ||
      old.dash != dash ||
      old.gap != gap;
}

class _PickerButtons extends StatelessWidget {
  const _PickerButtons({required this.onCamera, required this.onGallery});

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onCamera,
            icon: const Icon(Icons.camera_alt_rounded, size: 20),
            label: Text(
              strings.takePhoto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: onGallery,
            icon: const Icon(Icons.photo_library_rounded, size: 20),
            label: Text(
              strings.choosePhoto,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.enabled,
    required this.busy,
    required this.onPressed,
  });

  final bool enabled;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: busy
            ? SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: scheme.onSurface.withValues(alpha: 0.38),
                ),
              )
            : const Icon(Icons.auto_awesome_rounded, size: 20),
        label: Text(strings.submitForAnalysis),
      ),
    );
  }
}