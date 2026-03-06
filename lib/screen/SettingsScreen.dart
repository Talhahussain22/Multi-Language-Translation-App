import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchEmail(BuildContext context) async {
    const email = 'th47555@gmail.com';
    const subject = 'LangRush Support';
    const body = 'Hello, I need help with...';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await _showCopyFallback(context, email);
      }
    } catch (_) {
      await _showCopyFallback(context, email);
    }
  }

  Future<void> _showCopyFallback(BuildContext context, String email) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('No email app found', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 8),
              const Text('Copy the address and send us an email manually.'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: Text(email, style: const TextStyle(fontWeight: FontWeight.w600))),
                  TextButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: email));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Email copied to clipboard')),
                      );
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconBadge(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Section: Legal
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              'Legal',
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, letterSpacing: 0.2),
            ),
          ),
          Card(
            elevation: 1,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.black12, width: 0.8)),
            child: Column(
              children: [
                ListTile(
                  leading: _iconBadge(Icons.privacy_tip, primary),
                  title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WebViewPolicyScreen(
                        title: 'Privacy Policy',
                        url: 'https://talhahussain22.github.io/privacy_policy_langrush/',
                      ),
                    ),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: _iconBadge(Icons.description, primary),
                  title: const Text('Terms & Conditions', style: TextStyle(fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WebViewPolicyScreen(
                        title: 'Terms & Conditions',
                        url: 'https://talhahussain22.github.io/terms-and-conditions/',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section: Support
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6, top: 18),
            child: Text(
              'Support',
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700, letterSpacing: 0.2),
            ),
          ),
          Card(
            elevation: 1,
            shadowColor: Colors.black12,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.black12, width: 0.8)),
            child: Column(
              children: [
                ListTile(
                  leading: _iconBadge(Icons.email, primary),
                  title: const Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: const Text('th47555@gmail.com'),
                  trailing: const Icon(Icons.open_in_new),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  onTap: () => _launchEmail(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(height: 0),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'LangRush • Version 1.0.2',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class WebViewPolicyScreen extends StatefulWidget {
  final String title;
  final String url;
  const WebViewPolicyScreen({super.key, required this.title, required this.url});

  @override
  State<WebViewPolicyScreen> createState() => _WebViewPolicyScreenState();
}

class _WebViewPolicyScreenState extends State<WebViewPolicyScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (err) {
            setState(() {
              _isLoading = false;
              _error = err.description;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 2),
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.redAccent, size: 36),
                    const SizedBox(height: 8),
                    const Text('Failed to load page', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      onPressed: () {
                        setState(() {
                          _error = null;
                          _isLoading = true;
                        });
                        _controller.loadRequest(Uri.parse(widget.url));
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PolicyTextScreen extends StatelessWidget {
  final String title;
  const PolicyTextScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final text = title == 'Privacy Policy' ? _privacy : _terms; // fallback if misused
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(text, style: const TextStyle(height: 1.5, fontSize: 14)),
        ),
      ),
    );
  }
}

const _privacy = 'This is a placeholder privacy policy. Your privacy matters.'
    ' We do not collect personal data beyond app functionality.';
const _terms = 'These are placeholder terms and conditions.'
    ' Use the app responsibly and comply with local regulations.';
