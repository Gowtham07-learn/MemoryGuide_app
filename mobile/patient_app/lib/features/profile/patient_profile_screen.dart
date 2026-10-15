import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/service_locator.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/liquid_glass.dart';
import '../authentication/login_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  bool _isLoading = false;

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to sign out of this device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PatientAppTheme.helpRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    await PatientAppServices.instance.authRepository.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PatientLoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = PatientAppServices.instance.authRepository.currentUser;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.3),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.75),
        elevation: 0,
        centerTitle: true,
      ),
      body: GlassAtmosphere(
        isDark: false,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(26.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: const Color(0xFFEFF6FF),
                            child: Text(
                              (user?.fullName.isNotEmpty == true
                                      ? user!.fullName[0]
                                      : 'P')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: PatientAppTheme.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user?.fullName ?? 'Patient',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: PatientAppTheme.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'patient@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: PatientAppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5EC),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Active Patient Account',
                              style: TextStyle(
                                color: Color(0xFF15803D),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                  // Link Code Card for Caregiver Connection
                  if (user?.linkCode != null)
                    GlassCard(
                      borderRadius: 24,
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.link_rounded,
                                  color: PatientAppTheme.primaryBlue),
                              SizedBox(width: 8),
                              Text(
                                'Caregiver Link Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: PatientAppTheme.deepNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Share this unique code with your caregiver so they can link to your app.',
                            style: TextStyle(
                              fontSize: 13,
                              color: PatientAppTheme.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white,
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user!.linkCode!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                    color: PatientAppTheme.deepNavy,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded,
                                      size: 20),
                                  tooltip: 'Copy link code',
                                  onPressed: () {
                                    Clipboard.setData(
                                        ClipboardData(text: user.linkCode!));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Link code copied to clipboard'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    height: 52,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: PatientAppTheme.helpRed,
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        side: const BorderSide(
                            color: Color(0xFFFECACA), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: PatientAppTheme.helpRed,
                              ),
                            )
                          : const Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      onPressed: _isLoading ? null : _logout,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
}
