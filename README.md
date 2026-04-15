# 📰 NewsApp — Flutter

Aplikasi Flutter yang menampilkan berita terkini dari [NewsAPI](https://newsapi.org), dibangun dengan fokus pada arsitektur kode yang bersih, kemampuan offline, dan konsistensi struktur kode.

---

## ✨ Fitur

- Menampilkan berita terkini dari NewsAPI
- Pencarian artikel berdasarkan kata kunci
- Filter berita berdasarkan kategori (Teknologi, Olahraga, Bisnis, Kesehatan, Hiburan)
- Shimmer loading effect untuk pengalaman pengguna yang lebih halus
- Mode offline — otomatis menampilkan data cache saat tidak ada koneksi internet
- Tampilan error yang ramah pengguna dengan tombol retry

---

## 📁 Struktur Folder

```
lib/
├── models/         # Data model (Article)
├── services/       # Logika API call & caching
├── providers/      # State management (Provider)
├── views/          # Screens (Home, Search, Detail)
├── widgets/        # Reusable UI components
└── main.dart
```

### Penjelasan Struktur

| Folder | Tujuan |
|---|---|
| `models/` | Mendefinisikan bentuk data. `Article.fromJson()` menangani parsing JSON sehingga bagian lain aplikasi tidak perlu peduli dengan format respons API. |
| `services/` | Semua request ke API dan logika baca/tulis cache berada di sini. File UI tidak pernah memanggil API secara langsung. |
| `providers/` | Mengelola state aplikasi (loading, data, error). Berperan sebagai jembatan antara `services/` dan `views/`. |
| `views/` | Murni UI. Screen hanya membaca data dari provider dan menampilkannya — tidak ada logika bisnis di sini. |
| `widgets/` | Komponen UI yang dapat digunakan ulang (`ArticleCard`, `LoadingShimmer`) dan dipakai secara konsisten di semua screen. |

Pemisahan ini memastikan perubahan di satu layer (misalnya mengganti API) tidak merusak layer lainnya.

---

## 🔧 State Management — Kenapa Provider?

Proyek ini menggunakan **Provider** sebagai solusi state management. Berikut alasannya:

- **Sederhana dan mudah dibaca** — Provider mengikuti pola yang mudah dilacak dan di-debug. Alur data bersifat eksplisit: `Service → Provider → View`.
- **Direkomendasikan oleh tim Flutter** — Provider adalah solusi yang direkomendasikan secara resmi untuk skala proyek seperti ini.
- **Tepat ukuran** — Solusi seperti BLoC atau Riverpod menambahkan boilerplate yang tidak diperlukan untuk aplikasi dengan fitur tunggal seperti ini. GetX, meskipun praktis, terlalu banyak menyembunyikan proses internal sehingga arsitektur menjadi lebih sulit dijelaskan dan dirawat.
- **Mudah diuji** — Karena logika bisnis terisolasi di layer Provider, setiap bagian dapat diuji secara independen.

---

## 📦 Dependencies

```yaml
dependencies:
  http: ^1.4.0              # API call ke NewsAPI
  provider: ^6.1.5          # State management
  shared_preferences: ^2.5.3 # Caching offline
  shimmer: ^3.0.0            # Loading state UI
  url_launcher: ^6.3.1      # Buka artikel di browser
  flutter_dotenv: ^5.2.1     # Load API key dari file .env
  cached_network_image: ^3.4.1 # Image caching & placeholder
  intl: ^0.20.2              # Date formatting
```

---

## 🚀 Cara Menjalankan

### Cara Cepat (Tanpa Setup)

File APK sudah tersedia di folder `apk/`. Transfer `apk/news_app.apk` ke perangkat Android dan install langsung.

### Build Dari Source Code

**Prasyarat:** Flutter SDK ≥ 3.7.0, Android SDK, JDK 17

1. Clone repositori ini
   ```bash
   git clone <repository-url>
   cd news_app
   ```

2. Install dependencies
   ```bash
   flutter pub get
   ```

3. Tambahkan API key NewsAPI

   Salin `.env.example` menjadi `.env` dan isi API key kamu:
   ```bash
   cp .env.example .env
   ```
   ```
   NEWS_API_KEY=isi_api_key_kamu_di_sini
   ```
   API key gratis bisa didapatkan di [newsapi.org/register](https://newsapi.org/register)

4. Jalankan di perangkat fisik atau emulator
   ```bash
   flutter run
   ```

> **Catatan:** NewsAPI versi gratis tidak mendukung request dari browser (CORS). Jalankan di perangkat Android/iOS atau emulator untuk hasil terbaik.

---

## 📱 Daftar Screen

| Screen | Deskripsi |
|---|---|
| Home | Daftar artikel dengan shimmer loading, filter kategori, banner offline, dan tampilan error |
| Search | Pencarian kata kunci menggunakan `async/await` + `FutureBuilder` |
| Detail | Tampilan lengkap artikel beserta informasi sumber dan tombol buka di browser |

---

## 🗂️ Mode Offline

Saat tidak ada koneksi internet, aplikasi secara otomatis memuat data terakhir yang berhasil diambil dari cache lokal (`shared_preferences`) dan menampilkan banner **"Mode Offline"** untuk memberitahu pengguna.

---

*Dibuat untuk UTS — Lab Pengembangan Aplikasi Mobile, Sistem Informasi 2025/2026*
