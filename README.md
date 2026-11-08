# Ayo - Flutter Employee Portal & Presensi (PT. PKP)

Aplikasi Flutter untuk Employee Portal & HRIS PT Prawathiya Karsa Pradiptha (PT. PKP), mencakup:
1. **Otentikasi**: Login API dengan JWT Bearer Token & penyimpanan sesi lokal.
2. **Dashboard**: Ringkasan profil karyawan, status kebijakan presensi (Selfie, Radius 150m), serta widget presensi hari ini.
3. **Presensi & Riwayat Kehadiran**: Integrasi penuh endpoint `/presences` dengan filter tanggal, deteksi keterlambatan, lokasi kantor, jam kerja, dan rincian GPS.

---

## 1. Analisis Integrasi API

### A. Endpoint Login
- **URL**: `http://149.129.246.92:83/auth/login`
- **Method**: `POST`
- **Headers**: `Content-Type: application/json`
- **Body**:
  ```json
  {
    "email": "tatang@pkp.co.id",
    "password": "pkp12345678",
    "appId": "3507398578724"
  }
  ```
- **Hasil**: Menghasilkan `data.token` (JWT) dan objek `data.employee.id` (misal: `470`).

### B. Endpoint Riwayat Presensi
- **URL**: `http://149.129.246.92:83/presences`
- **Method**: `GET`
- **Headers**:
  - `Authorization: Bearer <TOKEN_JWT>`
  - `Accept: application/json`
- **Query Parameters**:
  - `master_employee_id`: Diambil otomatis dari user yang sedang login (`user.employee.id`).
  - `pageSize`: `1000`.
  - `from`: Tanggal awal (`YYYY-MM-DD`).
  - `to`: Tanggal akhir (`YYYY-MM-DD`).

#### Rincian Data Presensi yang Ditampilkan:
* `time_in`: Jam Masuk (cth: `08:57:00`).
* `time_out`: Jam Pulang (cth: `23:39:00`).
* `late`: Keterlambatan dalam menit (cth: `-26` $\rightarrow$ Terlambat 26 menit).
* `reason`: Alasan keterlambatan (cth: `"telat"`, `"hp mati"`).
* `time_in_location`: Nama lokasi kantor (cth: `"PKP HO"` atau `"Rumah Bintang"`).
* `latitude`, `longitude`, & `radius`: Koordinat GPS dan jarak saat melakukan presensi.
* `start_break` & `end_break`: Jadwal istirahat (`12:00:00 - 13:00:00`).

---

## 2. Struktur Proyek

```
ayo/
├── lib/
│   ├── config/
│   │   ├── api_constants.dart          # Endpoint login & presences
│   │   └── app_theme.dart              # Desain UI tema korporat
│   ├── models/
│   │   ├── login_request.dart
│   │   ├── login_response.dart
│   │   ├── user_model.dart
│   │   ├── employee_model.dart
│   │   ├── company_model.dart
│   │   ├── person_model.dart
│   │   ├── configuration_model.dart
│   │   ├── location_model.dart         # Model lokasi kantor & jam kerja
│   │   ├── presence_model.dart         # Model entri presensi
│   │   └── presence_response.dart      # Model payload respons presences
│   ├── services/
│   │   ├── auth_service.dart           # HTTP Client login
│   │   ├── presence_service.dart       # HTTP Client presences
│   │   └── session_manager.dart        # SharedPreferences persistence
│   ├── providers/
│   │   ├── auth_provider.dart          # State login & session
│   │   └── presence_provider.dart      # State presensi & filter tanggal
│   ├── screens/
│   │   ├── splash_screen.dart          # Auto-login check
│   │   ├── login_screen.dart           # Form login + demo autofill
│   │   ├── dashboard_screen.dart       # Dashboard utama & widget presensi
│   │   ├── attendance_screen.dart      # Presensi selfie & verifikasi jarak
│   │   └── history_screen.dart         # Riwayat lengkap & modal detail
│   └── main.dart                       # MultiProvider & MaterialApp
```

---

## 3. Fitur Utama

1. **Dashboard Cerdas**:
   - Menampilkan kartu **"Presensi Terakhir / Hari Ini"** yang langsung memuat data dari `/presences` begitu user masuk ke Dashboard.
   - Deteksi otomatis status kehadiran: **Tepat Waktu** (Hijau) atau **Terlambat** (Merah) lengkap dengan durasi menit dan nama kantor (`PKP HO`).
   - Tombol cepat untuk langsung presensi jika belum absen.

2. **Halaman Riwayat Presensi (`HistoryScreen`)**:
   - Filter rentang tanggal menggunakan Date Range Picker.
   - Ringkasan statistik kehadiran: **Total Hadir**, **Tepat Waktu**, dan **Terlambat**.
   - Kartu riwayat per hari dengan jam masuk, jam pulang, lokasi, serta catatan alasan.
   - Modal bottom sheet detail presensi lengkap dengan koordinat GPS, radius meter, dan ID perangkat.

3. **Halaman Presensi Interaktif (`AttendanceScreen`)**:
   - Jam digital realtime dengan deteksi zona waktu WIB.
   - Validasi Geofencing lokasi kantor berdasarkan parameter `configuration.radius` (150m).
   - Viewfinder verifikasi wajah (swafoto/selfie) sesuai kebijakan `configuration.selfie = true`.
   - Tombol pengiriman presensi Masuk & Pulang.

---

## 4. Cara Menjalankan

```bash
cd /Users/legacygandawijaya/Documents/ayo
flutter pub get
flutter run
```
