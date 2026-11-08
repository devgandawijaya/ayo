import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../providers/presence_provider.dart';
import '../widgets/info_card.dart';
import 'attendance_screen.dart';
import 'history_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresenceData();
    });
  }

  void _loadPresenceData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null && user.employee != null) {
      Provider.of<PresenceProvider>(context, listen: false).fetchPresences(
        employeeId: user.employee!.id,
        token: user.token,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.dangerColor),
            SizedBox(width: 8),
            Text('Konfirmasi Keluar'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerColor,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showTokenDetails(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Detail Sesi & JWT Token',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Token JWT (Bearer):',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                user.token,
                style: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (user.fcmToken != null) ...[
              const Text(
                'FCM Token:',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  user.fcmToken!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final presence = context.watch<PresenceProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final config = user.configuration;
    final emp = user.employee;
    final person = user.person;
    final company = user.company;
    final todayPres = presence.todayPresence;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company?.name ?? 'PT. PKP',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              company?.description ?? 'Employee Portal',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.security, size: 22),
            tooltip: 'Lihat Token JWT',
            onPressed: () => _showTokenDetails(context, user),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: 'Keluar',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await auth.checkAuthStatus();
          _loadPresenceData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Profile Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white,
                      child: Text(
                        user.name.isNotEmpty
                            ? user.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                            : 'U',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.roleName.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Presence Status Card (Fetched from /presences API)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.today, size: 18, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text(
                              'Presensi Terakhir / Hari Ini',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        if (todayPres != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: todayPres.isLate
                                  ? AppTheme.dangerColor.withOpacity(0.12)
                                  : AppTheme.successColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              todayPres.isLate
                                  ? 'Terlambat (${todayPres.lateMinutes} mnt)'
                                  : 'Tepat Waktu',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: todayPres.isLate
                                    ? AppTheme.dangerColor
                                    : AppTheme.successColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),

                    if (presence.isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ] else if (todayPres != null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Jam Masuk',
                                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.login, size: 16, color: AppTheme.successColor),
                                    const SizedBox(width: 6),
                                    Text(
                                      todayPres.timeIn ?? '-',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(height: 36, width: 1, color: const Color(0xFFE2E8F0)),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Jam Pulang',
                                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.logout, size: 16, color: Colors.orange),
                                      const SizedBox(width: 6),
                                      Text(
                                        todayPres.timeOut ?? '-',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lokasi: ${todayPres.locationName} (${todayPres.radius ?? "0"}m)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          Text(
                            'Tgl: ${todayPres.dateString}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 20, color: Colors.orange.shade700),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Belum ada presensi tercatat untuk hari ini.',
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                              );
                            },
                            child: const Text('Absen', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Actions Grid
              const Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildQuickAction(
                    icon: Icons.camera_alt_rounded,
                    label: 'Absensi',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AttendanceScreen()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.history_rounded,
                    label: 'Riwayat',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.event_note_rounded,
                    label: 'Cuti',
                    color: Colors.green,
                    onTap: () => _showActionNotice(context, 'Pengajuan Cuti'),
                  ),
                  _buildQuickAction(
                    icon: Icons.receipt_long_rounded,
                    label: 'Slip Gaji',
                    color: Colors.purple,
                    onTap: () => _showActionNotice(context, 'Slip Gaji'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Attendance & Device Policy Configuration Card
              SectionCard(
                title: 'Konfigurasi Presensi',
                icon: Icons.settings_suggest_rounded,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Verifikasi Selfie',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        StatusBadge(
                          text: (config?.selfie ?? false) ? 'Wajib' : 'Opsional',
                          isPositive: config?.selfie ?? false,
                          icon: (config?.selfie ?? false)
                              ? Icons.check_circle
                              : Icons.info_outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Geotagging (Lokasi)',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        StatusBadge(
                          text: (config?.geotagging ?? false)
                              ? 'Aktif (Radius ${config?.radius ?? 0}m)'
                              : 'Nonaktif',
                          isPositive: config?.geotagging ?? false,
                          icon: Icons.location_on,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Fingerprint / Biometrik',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        StatusBadge(
                          text: (config?.fingerprint ?? false) ? 'Aktif' : 'Nonaktif',
                          isPositive: config?.fingerprint ?? false,
                          icon: Icons.fingerprint,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Batas Sesi (Timeout)',
                          style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        Text(
                          '${config?.sessionTimeout ?? 0} detik',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Employment Details Card
              SectionCard(
                title: 'Informasi Kepegawaian',
                icon: Icons.badge_outlined,
                child: Column(
                  children: [
                    InfoRow(label: 'NPK Karyawan', value: emp?.npk ?? '-'),
                    InfoRow(label: 'Departemen ID', value: 'Dept #${emp?.departmentId ?? "-"}'),
                    InfoRow(label: 'Supervisor (SPV) ID', value: '#${emp?.spvId ?? "-"}'),
                    InfoRow(label: 'Tanggal Bergabung', value: emp?.joinDate ?? '-'),
                    InfoRow(label: 'App ID Karyawan', value: emp?.appId ?? '-'),
                  ],
                ),
              ),

              // Personal Data Card
              SectionCard(
                title: 'Data Pribadi',
                icon: Icons.person_outline,
                child: Column(
                  children: [
                    InfoRow(label: 'Nama Lengkap', value: person?.name ?? user.name),
                    InfoRow(label: 'Jenis Kelamin', value: person?.gender ?? '-'),
                    InfoRow(label: 'Agama', value: person?.religion ?? '-'),
                    InfoRow(label: 'Status Perkawinan', value: person?.maritalStatus ?? '-'),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showActionNotice(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur $title siap dihubungkan dengan modul terkait.'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
