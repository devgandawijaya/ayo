import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();
  bool _isCheckIn = true; // true = Check In, false = Check Out
  bool _isSelfieCaptured = false;
  bool _isSubmitting = false;

  // Mock office coordinates & simulated distance
  final double _userDistanceMeters = 42.0;
  final String _officeAddress = 'Kantor Pusat PT. PKP, Menara Pradiptha Lt. 5';

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  void _captureSelfie() {
    setState(() {
      _isSelfieCaptured = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Foto selfie berhasil diambil (Terverifikasi)'),
        backgroundColor: AppTheme.successColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _submitAttendance() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    final config = user?.configuration;
    final isSelfieRequired = config?.selfie ?? true;

    if (isSelfieRequired && !_isSelfieCaptured) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verifikasi selfie wajib dilakukan sesuai kebijakan perusahaan!'),
          backgroundColor: AppTheme.dangerColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });

    final actionType = _isCheckIn ? 'Masuk' : 'Pulang';
    final timeStr = DateFormat('HH:mm:ss').format(DateTime.now());

    _showSuccessDialog(actionType, timeStr);
  }

  void _showSuccessDialog(String actionType, String timeStr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: AppTheme.successColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Presensi $actionType Berhasil!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tercatat pada $timeStr WIB',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _dialogRow('Lokasi', 'PT. PKP Office'),
                  _dialogRow('Jarak GPS', '$_userDistanceMeters m (Aman)'),
                  _dialogRow('Selfie', 'Terverifikasi'),
                  _dialogRow('Status', 'Tepat Waktu'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Selesai',
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _isSelfieCaptured = false;
                  _isCheckIn = !_isCheckIn;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final config = user?.configuration;
    final maxRadius = double.tryParse(config?.radius ?? '150') ?? 150.0;
    final isWithinRadius = _userDistanceMeters <= maxRadius;

    final dateFormatted = DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_currentTime);
    final timeFormatted = DateFormat('HH:mm:ss').format(_currentTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Karyawan'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Check-in / Check-out Mode Selector
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCheckIn = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _isCheckIn ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Absen Masuk',
                            style: TextStyle(
                              color: _isCheckIn ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isCheckIn = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: !_isCheckIn ? AppTheme.primaryColor : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Absen Pulang',
                            style: TextStyle(
                              color: !_isCheckIn ? Colors.white : AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Live Digital Clock Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    dateFormatted,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        timeFormatted,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'WIB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isCheckIn ? 'Jadwal Masuk: 08:00 - 09:00' : 'Jadwal Pulang: 17:00 - 18:00',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Geolocation Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isWithinRadius ? AppTheme.successColor.withOpacity(0.4) : AppTheme.dangerColor.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isWithinRadius
                          ? AppTheme.successColor.withOpacity(0.12)
                          : AppTheme.dangerColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: isWithinRadius ? AppTheme.successColor : AppTheme.dangerColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              isWithinRadius ? 'Dalam Radius Kantor' : 'Di Luar Radius Kantor',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isWithinRadius ? AppTheme.successColor : AppTheme.dangerColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_userDistanceMeters.toInt()}m / ${maxRadius.toInt()}m',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _officeAddress,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Selfie Verification Viewfinder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 18, color: AppTheme.primaryColor),
                          SizedBox(width: 8),
                          Text(
                            'Verifikasi Wajah (Selfie)',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _isSelfieCaptured
                              ? AppTheme.successColor.withOpacity(0.12)
                              : Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _isSelfieCaptured ? 'Terverifikasi' : 'Wajib Diambil',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _isSelfieCaptured ? AppTheme.successColor : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Viewfinder Frame
                  GestureDetector(
                    onTap: _captureSelfie,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _isSelfieCaptured ? AppTheme.successColor : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                      ),
                      child: _isSelfieCaptured
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.face_retouching_natural,
                                  size: 64,
                                  color: AppTheme.successColor,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Wajah Terdeteksi & Cocok',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.successColor,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ketuk untuk mengambil ulang foto',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 48,
                                  color: AppTheme.primaryLight.withOpacity(0.7),
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Ketuk di sini untuk Ambil Foto Selfie',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pastikan pencahayaan cukup dan wajah terlihat jelas',
                                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Attendance Button
            CustomButton(
              text: _isCheckIn ? 'Kirim Presensi Masuk' : 'Kirim Presensi Pulang',
              icon: Icons.fingerprint,
              isLoading: _isSubmitting,
              onPressed: isWithinRadius ? _submitAttendance : null,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
