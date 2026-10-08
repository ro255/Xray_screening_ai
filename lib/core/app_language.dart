import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage { english, swahili }

class AppLanguageController extends ValueNotifier<AppLanguage> {
  AppLanguageController({SharedPreferences? preferences})
    : _preferences = preferences,
      super(
        preferences?.getString(_preferenceKey) == 'swahili'
            ? AppLanguage.swahili
            : AppLanguage.english,
      );

  static const _preferenceKey = 'appLanguage';
  final SharedPreferences? _preferences;

  Future<void> setLanguage(AppLanguage language) async {
    await _preferences?.setString(_preferenceKey, language.name);
    value = language;
  }
}

class AppStrings extends InheritedWidget {
  const AppStrings({required this.language, required super.child, super.key});

  final AppLanguage language;

  bool get _english => language == AppLanguage.english;

  static AppStrings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppStrings>()!;

  String get home => _english ? 'Home' : 'Nyumbani';
  String get screening => _english ? 'Screening' : 'Uchunguzi';
  String get settings => _english ? 'Settings' : 'Mipangilio';
  String get welcome => _english ? 'Welcome 👋' : 'Karibu 👋';
  String get healthMatters =>
      _english ? 'Your health matters.' : 'Afya yako ni muhimu.';
  String get screeningServices =>
      _english ? 'Screening services' : 'Huduma za uchunguzi';
  String get services => _english ? 'services' : 'huduma';
  String get available => _english ? 'AVAILABLE NOW' : 'HUDUMA INAPATIKANA';
  String get xrayScreening =>
      _english ? 'X-Ray screening' : 'Uchunguzi wa X-Ray';
  String get xrayDescription => _english
      ? 'Upload a chest X-ray image for analysis.'
      : 'Pakia picha ya kifua na uipeleke kwa uchambuzi.';
  String get xrayTip => _english
      ? 'Tip: use a clear, well-lit chest X-ray for the most accurate analysis.'
      : 'Kidokezo: tumia picha ya kifua safi na yenye mwanga kwa uchambuzi sahihi.';
  String get startScreening => _english ? 'Start screening' : 'Anza uchunguzi';
  String get screeningDisclaimer => _english
      ? 'Screening results are for support only and do not replace medical advice.'
      : 'Matokeo ya uchunguzi ni msaada tu na hayachukui nafasi ya ushauri wa daktari.';
  String get comingSoon => _english ? 'Coming soon' : 'Inakuja hivi karibuni';
  String get languageLabel => _english ? 'Language' : 'Lugha';
  String get chooseLanguage => _english
      ? 'Choose your preferred language'
      : 'Chagua lugha unayopendelea';
  String get chest => _english ? 'Chest' : 'Kifua';
  String get bones => _english ? 'Bones' : 'Mifupa';
  String get patientReference =>
      _english ? 'Patient reference number' : 'Namba ya mgonjwa';
  String get patientRefHint => _english
      ? 'e.g. P-001'
      : 'mfano P-001';
  String get noImage => _english ? 'No image selected' : 'Hakuna picha';
  String get tapToUpload => _english
      ? 'Tap to upload an X-ray image'
      : 'Gusa pakia picha ya X-Ray';
  String get takePhoto => _english ? 'Take photo' : 'Piga picha';
  String get choosePhoto => _english ? 'Choose photo' : 'Chagua picha';
  String get submitForAnalysis =>
      _english ? 'Submit for analysis' : 'Tuma kuchambuliwa';
  String get results => _english ? 'Results' : 'Matokeo';
  String get analyzing => _english ? 'Analyzing...' : 'Inachambua...';
  String get analyzingImage =>
      _english ? 'Analyzing image...' : 'Inachambua picha...';
  String get waitingInQueue =>
      _english ? 'Waiting in queue...' : 'Inasubiri foleni...';
  String get mayTakeMinutes => _english
      ? 'This may take a few minutes'
      : 'Inaweza kuchukua dakika chache';
  String get doctorReview =>
      _english ? 'Doctor review recommended' : 'Inahitaji mapitio ya daktari';
  String get noFindings =>
      _english ? 'No findings detected' : 'Hakuna dalili zilizoonekana';
  String confidence(String? value) =>
      _english ? 'Confidence: ${value ?? '-'}' : 'Uhakika: ${value ?? '-'}';
  String get flaggedRegions =>
      _english ? 'Flagged regions' : 'Maeneo yaliyoonyeshwa';
  String get medicalDisclaimer => _english
      ? 'This is not a diagnosis. These results are for screening support only and must be confirmed by a doctor.'
      : 'Hii si utambuzi. Matokeo haya ni msaada wa uchunguzi tu; daktari lazima athibitishe.';
  String get unavailable => _english
      ? 'This service is coming soon'
      : 'Huduma hii inakuja hivi karibuni';
  String get notSynced => _english
      ? 'Results not yet synced to DHIS2'
      : 'Matokeo bado hayajawasiliana kwa DHIS2';
  String get synced => _english
      ? 'Synced to DHIS2'
      : 'Imewasilishwa kwa DHIS2';
  String get serviceReady => _english
      ? 'AI service ready'
      : 'Huduma ya AI inapatikana';
  String get serviceDegraded => _english
      ? 'AI service degraded'
      : 'Huduma ya AI imepungua';
  String get appTagline => _english
      ? 'AI-powered screening'
      : 'Uchunguzi wa AI';
  String healthWarning(String model) => _english
      ? 'Analysis service is degraded (model: ${model.isEmpty ? '-' : model}). Results may be delayed.'
      : 'Huduma ya uchambuzi imepungua (modeli: ${model.isEmpty ? '-' : model}). Matokeo yanaweza kukikwa.';
  String scanError(String? code) => _english
      ? switch (code) {
          'invalid_model_output' =>
            'The analysis produced an unreadable result. Please try again.',
          _ => code ?? 'An error occurred. Please try again.',
        }
      : switch (code) {
          'invalid_model_output' =>
            'Uchambuzi ulitoka na matokeo yasiyoweza kusomwa. Jaribu tena.',
          _ => code ?? 'Hitilafu imetokea. Jaribu tena.',
        };

  String moduleTitle(String id, String fallback) {
    if (_english) return fallback;
    return switch (id) {
      'xray' => 'X-Ray',
      'hiv' => 'VVU',
      'hpv' => 'HPV',
      'preg' => 'Ujauzito',
      'sti' => 'Magonjwa ya Zinaa',
      'uti' => 'UTI',
      _ => fallback,
    };
  }

  String moduleSubtitle(String id, String fallback) {
    if (_english) return fallback;
    return switch (id) {
      'xray' => 'Kifua na mifupa',
      'hiv' => 'Kipimo cha VVU',
      'hpv' => 'Saratani ya shingo ya kizazi',
      'preg' => 'Kipimo cha ujauzito',
      'sti' => 'Uchunguzi wa magonjwa ya zinaa',
      'uti' => 'Maambukizi ya njia ya mkojo',
      _ => fallback,
    };
  }

  @override
  bool updateShouldNotify(AppStrings oldWidget) =>
      language != oldWidget.language;
}
