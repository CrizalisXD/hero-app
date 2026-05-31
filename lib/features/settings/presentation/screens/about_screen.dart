import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/l10n/l10n.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '—';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((p) {
      if (mounted) {
        setState(() => _version = '${p.version}+${p.buildNumber}');
      }
    });
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsSectionAbout)),
      body: ListView(
        children: [
          ListTile(title: Text(l.aboutVersion(_version))),
          ListTile(
            title: Text(l.aboutPrivacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open('https://hero.app/privacy'),
          ),
          ListTile(
            title: Text(l.aboutTermsOfService),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => _open('https://hero.app/terms'),
          ),
          ListTile(
            title: Text(l.aboutOpenSourceLicenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Hero',
            ),
          ),
        ],
      ),
    );
  }
}
