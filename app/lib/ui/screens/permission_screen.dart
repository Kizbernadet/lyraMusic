import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/media_store.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/kit.dart';

/// Autorisation d'accès aux fichiers audio, selon la version d'Android.
Future<Permission> audioPermission() async =>
    await MediaStoreBridge.sdkInt() >= 33 ? Permission.audio : Permission.storage;

/// Autorisation (prototype 02) : explication, puis demande système (CA-01, CA-02).
class PermissionScreen extends StatefulWidget {
  final VoidCallback onGranted;
  final bool startDenied;
  const PermissionScreen({super.key, required this.onGranted, this.startDenied = false});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  late bool _denied = widget.startDenied;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Retour depuis les réglages du téléphone : on revérifie.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed && _denied) {
      if (await (await audioPermission()).isGranted) widget.onGranted();
    }
  }

  Future<void> _request() async {
    setState(() => _busy = true);
    final status = await (await audioPermission()).request();
    if (!mounted) return;
    if (status.isGranted || status.isLimited) {
      // Notification de lecture (Android 13+) : facultative.
      await Permission.notification.request();
      widget.onGranted();
    } else {
      setState(() {
        _denied = true;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.c;
    final points = [
      (Icons.music_note_rounded, l.permPoint1, l.permPoint1Sub),
      (Icons.wifi_off_rounded, l.permPoint2, l.permPoint2Sub),
      (Icons.shield_outlined, l.permPoint3, l.permPoint3Sub),
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(radiusM)),
                        child: Icon(Icons.folder_open_rounded, size: 26, color: c.primary),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(l.permTitle, style: context.t.h1),
                    const SizedBox(height: 8),
                    Text(l.permBody, style: context.t.body),
                    const SizedBox(height: 24),
                    for (final (icon, title, sub) in points)
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(radiusM)),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(icon, size: 18, color: c.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: context.t.title),
                                  Text(sub, style: context.t.meta),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_denied) ...[
                      const SizedBox(height: 6),
                      LyraBanner(
                        tone: Tone.err,
                        icon: Icons.error_outline_rounded,
                        title: l.permDeniedTitle,
                        text: l.permDeniedBody,
                        action: l.permOpenSettings,
                        onAction: openAppSettings,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              LyraButton(label: l.permAllow, full: true, onPressed: _busy ? null : _request),
              const SizedBox(height: 10),
              LyraButton(
                label: _denied ? l.permOpenSettings : l.permLater,
                variant: BtnVariant.secondary,
                small: true,
                full: true,
                onPressed: _denied ? openAppSettings : () => setState(() => _denied = true),
              ),
              const SizedBox(height: 10),
              Text(
                l.permFootnote,
                textAlign: TextAlign.center,
                style: context.t.meta.copyWith(color: c.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
