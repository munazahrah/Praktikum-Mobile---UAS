# Praktikum-Mobile---UAS

📈 S-PARK: Stock Prediction Analysis & Research Kit

🌟 Tentang Aplikasi

S-PARK adalah aplikasi mobile berbasis Flutter yang dirancang untuk memberikan pengguna alat bantu analisis dan prediksi harga saham utama. Aplikasi ini memanfaatkan model deep learning (GRU - Gated Recurrent Unit) untuk menyajikan proyeksi harga di masa depan, dikombinasikan dengan data historis dan fundamental perusahaan.

Aplikasi ini bertujuan untuk:
- Menyediakan pemantauan harga saham utama secara cepat dan efisien.
- Menampilkan data historis yang lengkap (Open, High, Low, Close, Volume).
- Menyajikan hasil prediksi harga yang mudah diakses di tab terpisah.

Fitur Utama:
- Home: Ringkasan status koneksi, status model prediksi, dan data harga penutupan terbaru.
- Daftar Saham: Menampilkan daftar semua saham yang tersedia beserta ringkasan singkat.
- Prediksi: Menampilkan grafik harga historis dan grafik prediksi harga untuk beberapa hari ke depan.

🔗 Endpoint API yang Digunakan

Aplikasi S-PARK menggunakan data statis yang di-host di npoint.io sebagai sumber data tunggal untuk semua informasi saham (historis, ringkasan, dan prediksi).

URL Utama (Base URL)

Semua data diambil dari satu endpoint utama:

[https://api.npoint.io/676f598b7ee38b8bc276](https://api.npoint.io/676f598b7ee38b8bc276)


Struktur Data API

API mengembalikan objek utama dalam format List yang membungkus satu Map ([ { ... } ]). Class ApiService menangani parsing struktur ini.

|Bagian Data| Keterangan | Penggunaan dalam Aplikasi |
|data |Berisi semua detail saham (company_name, description, market_cap, historical, prediction_data), diindeks oleh simbol (e.g., AAPL, MSFT). | Digunakan untuk Ringkasan, Grafik Historis, dan Prediksi. |
| search_results | Daftar simbol dan nama perusahaan yang tersedia. | Digunakan untuk fitur Pencarian dan Daftar Saham. |

⚙️ Panduan Instalasi dan Menjalankan Aplikasi

Ikuti langkah-langkah ini untuk menjalankan aplikasi S-PARK di perangkat atau emulator Anda.

Persyaratan Sistem
- Flutter SDK (Versi 3.x ke atas)
- Dart SDK
- IDE (VS Code atau Android Studio)
- Perangkat: Emulator Android atau Perangkat Fisik (Disarankan Perangkat Fisik untuk menghindari masalah jaringan).

Langkah 1: Konfigurasi Android (Jika Menggunakan HTTP)
- Jika Anda sebelumnya mengalami masalah koneksi dan harus menggunakan koneksi non-aman (http://):
- Buka file android/app/src/main/AndroidManifest.xml.
- Tambahkan atribut android:usesCleartextTraffic="true" ke dalam tag <application>.

<application
    ...
    android:usesCleartextTraffic="true"
    android:icon="@mipmap/ic_launcher">
    <!-- ... -->
</application>


Langkah 2: Hubungkan Perangkat
Pastikan perangkat target Anda terhubung dan terdeteksi:

1. Untuk Perangkat Fisik:
- Aktifkan Opsi Pengembang dan Debugging USB di ponsel Anda.
- Pastikan mode koneksi USB disetel ke File Transfer / MTP.

2. Verifikasi deteksi perangkat di terminal:
- flutter devices
- Jalankan Aplikasi, Setelah perangkat terdeteksi : flutter run
