import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/presence_model.dart';
import '../providers/auth_provider.dart';
import '../providers/presence_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresences();
    });
  }

  void _loadPresences() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null && user.employee != null) {
      Provider.of<PresenceProvider>(context, listen: false).fetchPresences(
        employeeId: user.employee!.id,
        token: user.token,
      );
    }
  }

  Future<void> _pickDateRange() async {
    final presence = Provider.of<PresenceProvider>(context, listen: false);
    final initialFrom = DateTime.tryParse(presence.fromDate) ?? DateTime.now();
    final initialTo = DateTime.tryParse(presence.toDate) ?? DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      initialDateRange: DateTimeRange(start: initialFrom, end: initialTo),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
      if (user != null && user.employee != null) {
        final fromStr = DateFormat('yyyy-MM-dd').format(picked.start);
        final toStr = DateFormat('yyyy-MM-dd').format(picked.end);

        await presence.fetchPresences(
          employeeId: user.employee!.id,
          token: user.token,
          from: fromStr,
          to: toStr,
        );
      }
    }
  }

  void _showDetailModal(PresenceModel item) {
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
                Text(
                  'Detail Presensi: ${item.dateString}',
                  style: const TextStyle(
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
            _detailRow('Status Kehadiran', item.isLate ? 'Terlambat (${item.lateMinutes} menit)' : 'Tepat Waktu',
                color: item.isLate ? AppTheme.dangerColor : AppTheme.successColor),
            if (item.reason != null && item.reason!.isNotEmpty)
              _detailRow('Alasan', item.reason!, color: Colors.orange.shade800),
            _detailRow('Jam Masuk', item.timeIn ?? '-'),
            _detailRow('Jam Pulang', item.timeOut ?? '-'),
            _detailRow('Jadwal Standar', '${item.setupTimeIn ?? "-"} (Maks: ${item.setupTimeInDeadline ?? "-"})'),
            _detailRow('Jam Istirahat', '${item.startBreak ?? "-"} s/d ${item.endBreak ?? "-"}'),
            _detailRow('Lokasi Kantor Masuk', item.timeInLocation?.name ?? 'PKP HO'),
            _detailRow('Koordinat GPS Masuk', '${item.latitude ?? "-"}, ${item.longitude ?? "-"}'),
            _detailRow('Radius Presensi', '${item.radius ?? "-"} meter'),
            _detailRow('ID Perangkat (Mobile ID)', item.mobileId ?? '-', isMonospace: true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? color, bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? AppTheme.textPrimary,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final presence = context.watch<PresenceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded),
            tooltip: 'Filter Tanggal',
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang',
            onPressed: _loadPresences,
          ),
        ],
      ),
      body: presence.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadPresences(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Filter Info Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.primaryLight),
                              const SizedBox(width: 8),
                              Text(
                                '${presence.fromDate}  s/d  ${presence.toDate}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: _pickDateRange,
                            child: const Text(
                              'Ubah',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stats Overview Cards
                    Row(
                      children: [
                        _buildStatBox(
                          'Total Hadir',
                          '${presence.totalPresent}',
                          Icons.how_to_reg,
                          AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          'Tepat Waktu',
                          '${presence.totalOnTime}',
                          Icons.check_circle_outline,
                          AppTheme.successColor,
                        ),
                        const SizedBox(width: 10),
                        _buildStatBox(
                          'Terlambat',
                          '${presence.totalLate}',
                          Icons.warning_amber_rounded,
                          AppTheme.dangerColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Presence List Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daftar Kehadiran (${presence.presences.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (presence.errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          presence.errorMessage!,
                          style: const TextStyle(color: AppTheme.dangerColor),
                        ),
                      ),
                    ] else if (presence.presences.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text(
                              'Tidak ada data presensi pada rentang tanggal ini.',
                              style: TextStyle(color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.builder(
                        itemCount: presence.presences.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final item = presence.presences[index];
                          return _buildPresenceCard(item);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatBox(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresenceCard(PresenceModel item) {
    final isLate = item.isLate;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showDetailModal(item),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Date & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.event, size: 16, color: AppTheme.primaryColor),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.dateString,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLate
                          ? AppTheme.dangerColor.withOpacity(0.12)
                          : AppTheme.successColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isLate
                          ? 'Terlambat (${item.lateMinutes} mnt)'
                          : 'Tepat Waktu',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isLate ? AppTheme.dangerColor : AppTheme.successColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Divider(height: 20, color: Color(0xFFF1F5F9)),

              // In & Out times
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.login_rounded, size: 18, color: AppTheme.successColor),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Masuk', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text(
                              item.timeIn ?? '-',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, size: 18, color: Colors.orange),
                        const SizedBox(width: 6),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pulang', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            Text(
                              item.timeOut ?? '-',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Location and Reason row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        item.locationName,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                  if (item.reason != null && item.reason!.isNotEmpty)
                    Text(
                      'Ket: ${item.reason}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: AppTheme.dangerColor,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
