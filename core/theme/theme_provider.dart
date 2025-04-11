import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ThemeMode Provider (Light / Dark)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
