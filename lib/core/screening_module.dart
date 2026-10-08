import 'package:flutter/material.dart';

class ScreeningModule {
  final String id, title, subtitle, route;
  final IconData icon;
  final bool enabled;
  const ScreeningModule(this.id, this.title, this.subtitle, this.icon,
      this.route, {this.enabled = false});
}

const modules = [
  ScreeningModule('xray', 'X-Ray', 'Chest and bones',
      Icons.medical_information, '/xray', enabled: true),
  ScreeningModule('hiv', 'HIV', 'HIV test', Icons.bloodtype, '/hiv'),
  ScreeningModule('hpv', 'HPV', 'Cervical cancer screening',
      Icons.female, '/hpv'),
  ScreeningModule('preg', 'Pregnancy', 'Pregnancy test',
      Icons.pregnant_woman, '/preg'),
  ScreeningModule('sti', 'STI screening', 'Sexually transmitted infections',
      Icons.health_and_safety, '/sti'),
  ScreeningModule('uti', 'UTI', 'Urinary tract infection',
      Icons.water_drop, '/uti'),
];