import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../data/system_bridge.dart';
import '../../state/library.dart';
import '../../state/settings.dart';
import '../brand/logo.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';
import '../widgets/playback_sheets.dart';
import 'equalizer_screen.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'incomplete_screen.dart';
import 'player_layout_screen.dart';
import 'themes_screen.dart';
import 'workshop_screen.dart';

/// Réglages.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  static const appVersion = '0.3.0';
  static const languages = {'fr': 'Français', 'en': 'English', 'es': 'Español'};

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool? _lockAllowed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Retour des réglages du téléphone : on revérifie l'autorisation.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkLock();
  }

  Future<void> _checkLock() async {
    try {
      final allowed = await SystemBridge.lockScreenAllowed();
      if (mounted) setState(() => _lockAllowed = allowed);
    } catch (_) {}
  }

  Future<void> _setLockScreen(SettingsController s, bool value) async {
    final l = context.l;
    if (value && _lockAllowed != true) {
      final go = await showDialog<bool>(
        context: context,
        useRootNavigator: true,
        builder: (d) => AlertDialog(
          icon: const Icon(Icons.lock_outline_rounded),
          title: Text(l.lockScreen),
          content: Text(l.lockPermissionBody),
          actions: [
            LyraButton(
              label: l.cancel,
              small: true,
              variant: BtnVariant.ghost,
              onPressed: () => Navigator.of(d).pop(false),
            ),
            LyraButton(label: l.allow, small: true, onPressed: () => Navigator.of(d).pop(true)),
          ],
        ),
      );
      if (go != true) return;
      await Permission.notification.request();
      await SystemBridge.requestLockScreenPermission();
    }
    await s.set(Toggle.lockScreen, value);
    await SystemBridge.setLockScreenEnabled(value);
  }

  Future<void> _pinWidget(String kind) async {
    final ok = await SystemBridge.pinWidget(kind);
    if (!ok && mounted) context.toast(context.l.widgetManual, icon: Icons.widgets_outlined);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final s = context.watch<SettingsController>();
    final lib = context.watch<LibraryController>();
    final audio = context.audio;
    final languageName = s.locale == null ? l.languageSystem : SettingsScreen.languages[s.locale!.languageCode]!;
    final incomplete = lib.incomplete.length;

    return Scaffold(
      appBar: LyraAppBar(title: l.settings, large: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
        children: [
          LyraGroup(
            title: l.groupAppearance,
            children: [
              SettingRow(
                icon: Icons.palette_outlined,
                title: l.appearance,
                value: themeChoiceLabel(context, s),
                onTap: () => context.push(const ThemesScreen()),
              ),
              SettingRow(
                icon: Icons.tune_rounded,
                title: l.playerLayout,
                value: l.playerLayoutSub,
                onTap: () => context.push(const PlayerLayoutScreen()),
              ),
              SettingRow(
                icon: Icons.translate_rounded,
                title: l.language,
                value: languageName,
                onTap: () => _pickLanguage(context, s),
              ),
              SwitchRow(
                icon: Icons.vibration_rounded,
                title: l.hapticsLabel,
                value: l.hapticsSub,
                on: s.on(Toggle.haptics),
                onChanged: (v) => s.set(Toggle.haptics, v),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.workshop,
            children: [
              SettingRow(
                icon: Icons.auto_fix_high_rounded,
                title: l.workshop,
                value: l.workshopSub,
                onTap: () => context.push(const WorkshopScreen()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupPlayback,
            children: [
              SettingRow(
                icon: Icons.equalizer_rounded,
                title: l.equalizer,
                value: audio.equalizerOn ? l.on : l.off,
                onTap: () => context.push(const EqualizerScreen()),
              ),
              ListenableBuilder(
                listenable: Listenable.merge([audio.sleepAt, audio.sleepAfterTrack]),
                builder: (_, _) => SettingRow(
                  icon: Icons.bedtime_outlined,
                  title: l.sleepTimer,
                  value: audio.sleepAfterTrack.value
                      ? l.sleepEndOfTrack
                      : audio.sleepAt.value == null
                      ? l.off
                      : l.sleepIn(audio.sleepAt.value!.difference(DateTime.now()).inMinutes + 1),
                  onTap: () => showSleepTimerSheet(context),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: audio.speed,
                builder: (_, v, _) => SettingRow(
                  icon: Icons.speed_rounded,
                  title: l.playbackSpeed,
                  value: '${v.toStringAsFixed(2)}×',
                  onTap: () => showSpeedSheet(context),
                ),
              ),
              SwitchRow(
                icon: Icons.fast_forward_outlined,
                title: l.skipSilence,
                value: l.skipSilenceSub,
                on: s.on(Toggle.skipSilence),
                onChanged: (v) {
                  s.set(Toggle.skipSilence, v);
                  audio.setSkipSilence(v);
                },
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.lockScreen,
            children: [
              SwitchRow(
                icon: Icons.lock_outline_rounded,
                title: l.lockScreenOption,
                value: l.lockScreenSub,
                on: s.on(Toggle.lockScreen),
                onChanged: (v) => _setLockScreen(s, v),
              ),
              if (s.on(Toggle.lockScreen) && _lockAllowed == false)
                SettingRow(
                  icon: Icons.warning_amber_rounded,
                  tone: c.warning,
                  title: l.lockPermissionMissing,
                  value: l.lockPermissionMissingSub,
                  onTap: SystemBridge.requestLockScreenPermission,
                ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.widgets,
            children: [
              SettingRow(
                icon: Icons.view_agenda_outlined,
                title: l.widgetSmall,
                value: l.widgetSmallSub,
                onTap: () => _pinWidget('small'),
              ),
              SettingRow(
                icon: Icons.dashboard_outlined,
                title: l.widgetLarge,
                value: l.widgetLargeSub,
                onTap: () => _pinWidget('large'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupLibrary,
            children: [
              SettingRow(
                icon: Icons.radar_rounded,
                title: l.scanMusic,
                value: l.songsCount(lib.tracks.length),
                trailing: lib.scanning
                    ? SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary))
                    : null,
                onTap: lib.scanning ? null : () => rescanLibrary(context),
              ),
              SettingRow(
                icon: Icons.folder_outlined,
                title: l.tabFolders,
                value: '${lib.folders.length}',
                onTap: () => context.shell.goTab(ShellNav.home, homeTab: 4),
              ),
              SettingRow(
                icon: Icons.warning_amber_rounded,
                tone: incomplete > 0 ? c.warning : null,
                title: l.incompleteTitle,
                value: l.songsCount(incomplete),
                onTap: () => context.push(const IncompleteScreen()),
              ),
              SettingRow(
                icon: Icons.history_rounded,
                title: l.history,
                value: l.recentlyPlayed,
                onTap: () => context.push(const HistoryScreen()),
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupSystem,
            children: [
              SettingRow(
                icon: Icons.shield_outlined,
                title: l.permissions,
                value: l.permissionGranted,
                onTap: openAppSettings,
              ),
            ],
          ),
          const SizedBox(height: 18),
          LyraGroup(
            title: l.groupAbout,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: Center(child: LyraLogo(width: 170, spin: audio.playing.value)),
              ),
              SettingRow(
                icon: Icons.info_outline_rounded,
                title: l.version,
                value: '${SettingsScreen.appVersion} · ${l.splashTagline}',
              ),
              SettingRow(icon: Icons.lock_outline_rounded, title: l.privacy, value: l.privacyValue),
              SettingRow(
                icon: Icons.auto_awesome_outlined,
                title: l.licences,
                onTap: () => showLicensePage(
                  context: context,
                  useRootNavigator: true,
                  applicationName: 'LyraMusic',
                  applicationVersion: SettingsScreen.appVersion,
                  applicationIcon: const Padding(padding: EdgeInsets.all(12), child: LyraAppIcon(size: 56)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l.settingsFooter,
            textAlign: TextAlign.center,
            style: context.t.meta.copyWith(color: c.text3),
          ),
        ],
      ),
    );
  }

  void _pickLanguage(BuildContext context, SettingsController settings) {
    final l = context.l;
    final current = settings.locale?.languageCode;
    showLyraSheet(
      context,
      title: l.language,
      builder: (sheet) {
        final c = sheet.c;
        Widget option(String? code, String label) => SheetAction(
          icon: code == current ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
          color: code == current ? c.primary : null,
          label: label,
          onTap: () {
            Navigator.of(sheet).pop();
            settings.setLocale(code == null ? null : Locale(code));
          },
        );
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            option(null, l.languageSystem),
            for (final e in SettingsScreen.languages.entries) option(e.key, e.value),
          ],
        );
      },
    );
  }
}
