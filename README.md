# IGOTO Mobile - Investasi Gotong Royong

Aplikasi mobile berbasis Android untuk pengelolaan dan simulasi program pendanaan bersama pengadaan furniture CV. Karya Amanah Sejati.

Dikembangkan untuk memenuhi Tugas Akhir Pemrograman Perangkat Bergerak (Tubes Mobpro), Program Studi S1 Rekayasa Perangkat Lunak, Telkom University.

---

## Anggota Pengembang

- **Nama:** Mikdam Huda Nurhayat
- **NIM:** 1302223034
- **Kelas:** SE-48-03

---

## Deskripsi Project

IGOTO Mobile memfasilitasi calon investor untuk melakukan simulasi kalkulasi keuntungan secara transparan, melihat titik lokasi fisik workshop mebel melalui peta interaktif Google Maps, memotret fisik struk bukti transfer menggunakan kamera handphone, dan menerima notifikasi lokal di ponsel ketika pengajuan diverifikasi.

Di sisi pengelola, aplikasi menyediakan panel admin untuk memverifikasi bukti bayar investor, memperbarui progres pendanaan secara otomatis, dan mengekspor rekapitulasi data ke dalam format file PDF di penyimpanan lokal perangkat.

---

## Daftar Fitur Aplikasi (Pemenuhan 9 Fitur Wajib)

1. **Navigation dan Routing:** Multi-page application dengan routing rute publik (Splash, Login, Register) dan rute terproteksi (Dashboard Investor & Dashboard Admin).
2. **Server-based Database:** Database relasional MySQL (Non-BaaS) dengan koneksi pool pada backend REST API Express.js.
3. **API Integration:** Komunikasi data HTTP JSON lengkap (GET, POST, PUT, Multipart Upload) dengan otentikasi JWT Bearer Token.
4. **File Storage Management:** Penyimpanan file gambar sementara di cache lokal serta fungsi generate dan cetak laporan rekapitulasi PDF menggunakan package `pdf` dan `printing`.
5. **Camera Input:** Input langsung pengambilan foto bukti pembayaran struk/transfer perbankan menggunakan kamera ponsel (`camera` / `image_picker`).
6. **State Management:** Menerapkan `provider` (`ChangeNotifierProvider`, `Consumer`) untuk memisahkan UI, logika bisnis, dan data layer.
7. **Error Handling:** Validasi form input, penanganan kegagalan koneksi jaringan/server, dialog informasi error yang ramah pengguna.
8. **Google Maps Integration:** Peta interaktif Google Maps menampilkan marker lokasi workshop CV. Karya Amanah Sejati lengkap dengan info window alamat dan koordinat fisik.
9. **Notification System:** Pengiriman notifikasi lokal ke status bar ponsel pengguna (`flutter_local_notifications`) saat pengajuan investasi berhasil dikirim dan saat status diverifikasi.

---

## Akun Demo Pengujian

Aplikasi dilengkapi tombol cepat (*quick chip*) di halaman login untuk mempermudah demonstrasi:

| Peran | Email | Kata Sandi |
|---|---|---|
| **Investor** | `mikdam.test@gmail.com` | `password123` |
| **Admin** | `admin@igoto.com` | `password123` |

---

## Petunjuk Menjalankan Project

### 1. Menjalankan Backend & Database
1. Pastikan service MySQL aktif pada port 3306 (misalnya via XAMPP).
2. Import skema dan data awal jika belum:
   ```bash
   mysql -u root < backend/database/schema.sql
   mysql -u root < backend/database/seed.sql
   ```
3. Masuk ke folder backend dan jalankan server:
   ```bash
   cd backend
   npm install
   node server.js
   ```
   Server REST API akan berjalan di `http://0.0.0.0:5000`.

### 2. Menjalankan Aplikasi Mobile Flutter
1. Masuk ke folder mobile:
   ```bash
   cd mobile
   flutter pub get
   ```
2. Jalankan aplikasi di emulator Android yang aktif:
   ```bash
   flutter run -d emulator-5554
   ```
   *Catatan: Pada emulator Android, aplikasi otomatis terhubung ke backend server melalui alamat `10.0.2.2:5000`. Jika menggunakan perangkat fisik Android melalui Wi-Fi, host API dapat diganti melalui tombol pengaturan (ikon gear) di pojok kanan atas halaman login.*
