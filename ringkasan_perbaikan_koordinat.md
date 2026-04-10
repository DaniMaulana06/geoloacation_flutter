# Ringkasan Perbaikan Fitur Koordinat & Google Maps

Berikut adalah penjelasan teknis untuk materi presentasi mengenai perbaikan bug koordinat yang sebelumnya tidak muncul, dan bagaimana integrasinya dengan Google Maps.

---

## 1. Memperbarui Layer Entitas (Menjaga Prinsip Clean Architecture)
**Lokasi File yang Diubah:** `lib/features/todo/domain/entities/todo.dart`

**Latar Belakang & Perbaikan:**
*   **Masalah Awal:** Di dalam *Entity* terdapat fungsi untuk mengubah bentuk koordinat (`_parseLatitude`/`_parseLongitude`) yang memanggil variabel ilegal secara asal (`map['coordinates']`). Selain itu, *Entity* pada konsep *Clean Architecture* bertugas hanya sebagai cetakan/kerangka data murni (objek data kosong), bukannya menjalankan *logic database*.
*   **Tindakan:** Menghapus komponen *parsing database* dari *Entity*. Konversi/manipulasi data dari Supabase mutlak saya percayakan dan pindahkan ke `todo_model.dart` yang memang bertugas untuk memproses JSON eksternal tersebut menjadi Objek Dart.

---

## 2. Decode Data Mentah PostGIS menjadi Angka Asli (EWKB)
**Lokasi File yang Diubah:** `lib/features/todo/data/models/todo_model.dart`

**Latar Belakang & Perbaikan:**
*   **Masalah Awal:** Tipe data kolom lokasi di Supabase *PostGIS* secara default akan dikirim berbentuk Sandi Heksadesimal yaitu **WKB Hex String (Well-Known Binary)** (contoh responsenya: `0101000020E61000007...`). Dulu kode Anda hanya berusaha membaca teks kalimat seperti `"POINT(latitude longitude)"`. Hal ini menyebabkan Flutter menolak sandi Hex-nya dan menyamaratakannya menjadi `null`.
*   **Tindakan:** 
    *   Saya menaruh fungsi pustaka `dart:typed_data`.
    *   Saya merancang secara **Native Blok Decoder Hex-WKB**. Kode canggih ini memecah karakter *hexa* yang berjumlah 50 digit, yang langsung masuk untuk "merampas" byte tersembunyi `Float64` untuk sumbu X (*Longitude*) dan sumbu Y (*Latitude*).
    *   Dengan parser manual ini, setiap titik heksadesimal berhasil diekstrak dan didapatkan kembali angkanya untuk dimunculkan pada layer aplikasi.

---

## 3. Menampilkan Data Relevan di Database (Optimasi UX)
**Lokasi File yang Diubah:** `lib/features/todo/data/datasource/todo_remote_datasource.dart`

**Latar Belakang & Perbaikan:**
*   **Masalah Awal:** Seluruh *list/daftar* Tugas Todo disortot atau diatur berdasarkan `Select().order('id')`. Cara ini membuat aplikasi menampilkan daftar **lama** di atas (Ascending). Akibatnya, kita sering menekan data pertama (yang rupanya data *jadul* tanpa kordinat), sehingga pesannya "Tdak ada data koordinat" terus menerus. 
*   **Tindakan:** Mengubah parameternya dengan menambahkan sintaks pembalik: `.order('id', ascending: false)`. Kini, aplikasi memaksa data Tugas terbaru (yang koordinatnya paling *fresh*) ke barisan nomor 1. Hal ini mencegah kita dari mengecek *history* jelek yang *null*.

---

## 4. UI Rendering dan URL Scheme Google Maps Native
**Lokasi File yang Diubah:** `lib/features/todo/presentation/pages/detail_page.dart` & `pubspec.yaml`

**Latar Belakang & Perbaikan:**
*   **Masalah Awal:** Tampilan pada UI dulu hanya berbentuk _Text Component_ sangat sederhana membiarkan tulisan *"null"*, dan tentunya tidak responsif interaktif.
*   **Tindakan:**
    1.  **Proteksi Null Check (*Fallback*)**: Menambahkan struktur kontrol `if (latitude != null)` di UI. Jika titik tak ditemukan (pada data jadul), ia memunculkan *"Tidak ada data koordinat"* dengan rapi, tidak ada error layar merah.
    2.  **Integrasi External Plugin**: Mengunggah pustaka dari *pub.dev* bernama **`url_launcher`** di file `pubspec.yaml`. Ini adalah akses Flutter langsung OS bawaan yang canggih.
    3.  **Skema API Google Maps URL**: Menganimasikan Tombol *ElevatedButton* yang jika ditekan akan merakit link rute Universal dari struktur Location, yaitu:\
        `https://www.google.com/maps/search/?api=1&query=$latitude,$longitude`
    4.  **Bawaan Framework _Intent_ Native**: `url_launcher` melempar URL (*URI*) Google ini langsung ke OS (misalnya *Android Manifest Action View*). Efeknya adalah *Aplikasi langsung di-minimize sementara, OS mengambil paksa arah kordinat itu, dan membuka secara resmi Aplikasi Google Maps dengan pin lokasi Real Type akurasi tinggi!*
