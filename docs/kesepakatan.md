# Kesepakatan F0: Sistem Informasi Klinik Pratama

Dokumen ini mencatat kesepakatan yang ditutup dengan tag `kesepakatan-v1`.
Pemiliknya Agit (Anggota 1). Isinya menjadi acuan sebelum `sql/01_struktur.sql`
dibekukan dan sebelum Dapa, Farras, Kenzie, Kafka, dan Rassya menulis berkas
masing-masing.

Sumber angka dan nama adalah `Panduan Projek/docs/PRD.md`. Kalau dokumen ini dan
PRD berbeda, PRD yang menang, dan dokumen ini yang diperbaiki.

## 1. Studi kasus

Klinik Pratama adalah klinik rawat jalan berskala kecil dengan lima poli: Poli
Umum, Poli Anak, Poli Gigi, Poli Penyakit Dalam, dan Poli Mata. Seorang dokter
bertugas di satu poli, sedangkan pasien boleh datang berulang kali ke poli mana
pun.

| Langkah | Pelaku | Data yang dihasilkan |
|---|---|---|
| 1. Pasien mendaftar di meja depan pada satu sesi jadwal | petugas klinik | baris `kunjungan` dengan `id_pasien`, `id_jadwal`, `tanggal_kunjungan` |
| 2. Petugas memberi nomor antrean | petugas klinik | `no_antrean` unik per jadwal, status awal `Menunggu` |
| 3. Dokter memeriksa pasien | dokter | baris `rekam_medis`: keluhan, diagnosis, tekanan darah, suhu, berat, tinggi, `imt` terhitung, tanggal periksa |
| 4. Dokter memberi tindakan dan menulis resep | dokter | baris `detail_tindakan` dan `detail_resep`; stok obat berkurang |
| 5. Petugas menghitung tagihan lalu mencatat pembayaran | petugas klinik | baris `pembayaran`: metode, `total_tagihan`, status bayar, tanggal bayar |

Dua hal yang tidak dicatat manual. Indeks massa tubuh dihitung database dari
berat dan tinggi, sedangkan nama hari diturunkan dari tanggal saat query. Kedua
angka itu tidak disimpan sebagai kolom biasa karena menyimpannya berarti
menyimpan nilai yang bisa bertentangan dengan sumbernya.

## 2. Ruang lingkup

Termasuk dalam cakupan: pendaftaran pasien, penjadwalan sesi praktik, kunjungan,
rekam medis, tindakan, resep dan stok obat, tagihan, pembayaran, pelaporan
kunjungan, hak akses, indeks, dan pengujian.

Empat hal di luar cakupan beserta alasannya:

| Di luar cakupan | Alasan |
|---|---|
| Riwayat cicilan pembayaran | Pembayaran dianggap lunas sekali bayar, jadi status dan tanggal sudah cukup |
| Pengadaan obat dari pemasok | Stok hanya berkurang lewat resep; penambahan dilakukan manual dengan SQL |
| Jadwal berulang mingguan | Setiap sesi dicatat satu baris pada tanggal tertentu, hari diturunkan dengan `DAYNAME()` |
| Autentikasi aplikasi | Hak akses diatur di tingkat database memakai `GRANT`, tanpa aplikasi |

PRD juga mencatat dua hal lain yang tidak diambil: jenis kelamin pasien, karena
tidak dipakai satu pun kebutuhan informasi, dan aplikasi antarmuka, karena
penilaian terfokus pada perancangan dan SQL.

## 3. Delapan aturan bisnis

Setiap aturan punya penjaga teknis sehingga bisa diperiksa mesin, dan setiap
aturan punya pengujian yang membuktikannya.

| No | Aturan | Penjaga | Bukti |
|---|---|---|---|
| 1 | Kuota jadwal tidak boleh terlampaui | trigger `trg_cek_kuota_jadwal` | Uji 4 |
| 2 | Satu dokter tidak boleh punya dua jadwal beririsan pada tanggal yang sama | trigger `trg_cek_bentrok_jadwal` | Uji 5 |
| 3 | Satu pasien hanya boleh terdaftar sekali pada satu sesi jadwal | `uq_kunjungan_pasien` | `verify.sh` bagian E |
| 4 | Resep hanya boleh dibuat setelah rekam medis ada | kunci tamu `fk_detail_resep_rekam` | skema |
| 5 | Satu kunjungan punya paling banyak satu baris pembayaran | `uq_pembayaran_kunjungan` | Uji 8 |
| 6 | Total tagihan adalah jumlah biaya tindakan ditambah harga obat | `sp_bayar_kunjungan` menghitung sendiri | Uji 7 |
| 7 | Stok obat berkurang otomatis saat resep disimpan | `trg_cek_stok_obat` dan `trg_kurangi_stok` | Uji 6 |
| 8 | Status kunjungan hanya salah satu dari empat nilai | `ENUM` pada `status_kunjungan` | skema |

Aturan 1 menjaga jumlah pasien per sesi, aturan 7 menjaga jumlah obat per resep.
Keduanya bekerja pada tabel berbeda, jadi jangan tertukar saat presentasi.

## 4. Kamus data

Kamus data adalah daftar resmi nama entitas dan atributnya. Semua berkas SQL
memakai nama di tabel ini, tanpa singkatan baru yang muncul di tengah
pengerjaan.

| Entitas | Atribut | Keterangan |
|---|---|---|
| poli | id_poli, nama_poli, lantai | Tempat layanan. Nama poli unik. |
| dokter | id_dokter, id_poli, nama_dokter, no_sip, email, no_telp, tipe_dokter | Tenaga medis. Nomor SIP dan email unik. |
| jadwal_praktik | id_jadwal, id_dokter, tanggal, jam_mulai, jam_selesai, ruangan, kuota | Satu baris untuk satu sesi pada satu tanggal. |
| pasien | id_pasien, nama_pasien, nik, email, no_telp, tanggal_lahir, alamat | NIK 16 digit dan unik. |
| kunjungan | id_kunjungan, id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan | Pendaftaran pasien pada satu sesi jadwal. |
| rekam_medis | id_rekam, id_kunjungan, keluhan, diagnosis, tekanan_darah, suhu, berat_badan, tinggi_badan, imt, tanggal_periksa | Hasil pemeriksaan. Satu kunjungan paling banyak satu rekam. |
| tindakan | id_tindakan, nama_tindakan, tarif | Master tindakan dan tarifnya. |
| detail_tindakan | id_detail_tindakan, id_kunjungan, id_tindakan, jumlah | Tindakan yang dikerjakan pada satu kunjungan. |
| obat | id_obat, nama_obat, satuan, harga, stok | Master obat dan sisa stok. |
| detail_resep | id_detail_resep, id_rekam, id_obat, jumlah, aturan_pakai | Obat yang diresepkan pada satu rekam medis. |
| pembayaran | id_pembayaran, id_kunjungan, tanggal_bayar, metode, total_tagihan, status_bayar | Tagihan satu kunjungan. Satu kunjungan paling banyak satu baris. |

Tipe data, `ENUM`, dan nama constraint tidak diulang di sini karena sumbernya
`sql/01_struktur.sql`. Perubahan tipe atau nama kolom hanya lewat Farras.

## 5. Delapan kebutuhan informasi

Kebutuhan ditulis sebagai pertanyaan supaya bisa langsung diuji dengan query.

| No | Pertanyaan | Query acuan | Hasil pada data contoh |
|---|---|---|---|
| 1 | Pasien mana yang lahir sebelum 2005, diurutkan dari yang paling tua? | Q1 | 10 baris, tertua Gilang Ramadhan 1980-02-18 |
| 2 | Dokter mana bertugas di poli apa, dan poli itu di lantai berapa? | Q2 | 6 dokter |
| 3 | Bagaimana riwayat kunjungan lengkap: pasien, dokter, poli, status? | Q3 | 14 baris |
| 4 | Berapa sisa kuota setiap jadwal praktik saat ini? | Q4 | jadwal 7 sisa 0 |
| 5 | Kunjungan mana yang tagihannya belum lunas? | Q5 | 3 baris |
| 6 | Pasien mana yang pernah dirujuk ke Poli Anak? | Q6 | 6 pasien |
| 7 | Poli mana yang pendapatannya di atas rata-rata? | Q7 | Poli Anak |
| 8 | Obat apa yang paling banyak keluar, dan dokter mana yang menangani kunjungan terbanyak? | Q8, Q10 | Amlodipine 5mg 60 tablet; dr. Andi Pratama peringkat 1 |

Q9 (kategori biaya kunjungan dengan `CASE`) tidak berasal langsung dari satu
pertanyaan kebutuhan, tetapi dipakai untuk membaca sebaran biaya. Hasilnya 5
kunjungan Ringan, 3 Sedang, 2 Berat.

## 6. Relasi dan kardinalitas

| Relasi | Kardinalitas | Bentuk tabel hasil |
|---|---|---|
| poli memiliki dokter | 1 : N | kunci tamu `id_poli` di `dokter` |
| dokter punya jadwal praktik | 1 : N | kunci tamu `id_dokter` di `jadwal_praktik` |
| pasien mendaftar kunjungan | 1 : N | kunci tamu `id_pasien` di `kunjungan` |
| jadwal diisi kunjungan | 1 : N | kunci tamu `id_jadwal` di `kunjungan` |
| kunjungan menghasilkan rekam medis | 1 : 0..1 | `id_kunjungan` unik di `rekam_medis` |
| kunjungan menerima tindakan | M : N | tabel penghubung `detail_tindakan` |
| kunjungan ditagih pembayaran | 1 : 0..1 | `id_kunjungan` unik di `pembayaran` |
| rekam medis diresepkan obat | M : N | tabel penghubung `detail_resep` |

Delapan relasi itu menjadi sepuluh kunci tamu di `sql/01_struktur.sql`, semuanya
memakai `ON DELETE RESTRICT ON UPDATE CASCADE`.

## 7. Catatan extended ER: spesialisasi dokter

Model ER dasar tidak bisa menyatakan bahwa sebagian dokter adalah spesialis dan
sebagian dokter umum. Pada model extended ER, hal ini digambar sebagai
spesialisasi dengan dokter sebagai entitas induk dan dua subentitas di bawahnya.

Implementasi yang dipilih memakai satu tabel dengan kolom pembeda
`tipe_dokter ENUM('Umum','Spesialis')`. Atribut yang berbeda antar subentitas
masih sedikit, sehingga memecah tabel menjadi tiga hanya menambah penggabungan
tanpa manfaat nyata. Jika nanti dokter spesialis memerlukan belasan atribut
sendiri, tabel terpisah baru masuk akal. Keputusan ini dicatat supaya tidak
dibaca sebagai kelalaian.

## 8. Pembagian berkas

Satu berkas satu pemilik. Berkas anggota lain dibaca, tidak disunting.

| Anggota | Berkas dan bagian milik |
|---|---|
| Agit (Anggota 1) | `docs/kesepakatan.md`, `sql/00-kesepakatan.sql`, `sql/04_prosedur.sql`, `panduan/gambar/erd.tex`, Bab I dan Bab III `laporan/template-laporan.tex`, subbab ERD pada Bab II |
| Dapa (Anggota 2) | `sql/02_data.sql`, dokumentasi normalisasi, tangkapan layar query dasar |
| Farras (Anggota 3) | `sql/01_struktur.sql`, tabel transformasi, skema relasional, aljabar relasional |
| Kenzie (Anggota 4) | `sql/03_view_trigger.sql`, `sql/06_indeks.sql` |
| Kafka (Anggota 5) | `sql/05_keamanan.sql`, `sql/08_kueri.sql` |
| Rassya (Anggota 6) | `sql/07_pengujian.sql`, `tools/`, `bukti/`, daftar periksa, build PDF |

## 9. Keputusan yang dicatat

Empat keputusan berikut berasal dari PRD dan diulang di sini supaya tidak
dipertanyakan lagi saat presentasi.

1. `imt` disimpan sebagai generated stored column. Nilainya selalu dihitung
   database, jadi kebenaran datanya tidak bergantung pada disiplin pengisi.
2. Spesialisasi dokter diwakili satu kolom `tipe_dokter`, lihat bagian 7.
3. Kolom `hari` tidak ada pada `jadwal_praktik`, karena hari bisa bertentangan
   dengan tanggal. Nilainya diambil dengan `DAYNAME(tanggal)`.
4. NoSQL hanya dibahas sebagai perbandingan pemetaan dokumen JSON, tanpa
   membangun server.

Dua keputusan teknis penulisan yang diambil di sesi ini:

5. Subbab perbandingan NoSQL ditempatkan pada Bab III laporan sebagai subbab
   III.4, bukan di Bab II, supaya tidak bertabrakan dengan penyuntingan Dapa dan
   Farras.
6. Nama dan NIM anggota pada sampul serta tabel peran dibiarkan bergaris kosong.
   Pengisiannya dilakukan setelah data kelompok final.

## 10. Checklist F0

- [x] Delapan aturan bisnis tertulis, masing-masing punya penjaga dan pengujian.
- [x] Kamus data memuat sebelas entitas dan seluruh atributnya.
- [x] Delapan kebutuhan informasi ditulis sebagai pertanyaan yang bisa diuji.
- [x] Ruang lingkup beserta empat hal di luar cakupan disepakati.
- [x] Kardinalitas 1:N, M:N, dan 1:0..1 tercatat lengkap.
- [x] Pembagian berkas tercatat.
- [ ] Tag `kesepakatan-v1` dipasang setelah dokumen ini disetujui keenam anggota.

## 11. Status verifikasi akhir

Pemeriksaan akhir Agit terhadap daftar periksa buatan Rassya belum bisa
dijalankan karena berkas daftar periksa itu belum ada di repositori. Butir
daftar periksa tersedia sebagai panduan di `panduan/bab/14-daftar-periksa.tex`,
tetapi hasilnya baru bisa diperiksa setelah Rassya menyerahkan daftar beserta
berkas buktinya.

Keluaran akhir proyek hanya tiga: laporan dalam bentuk PDF, berkas `bukti/`
berisi keluaran perintah, dan PDF panduan. Tidak ada bahan presentasi lain yang
perlu disiapkan, sehingga butir penilaian cukup diperiksa lewat ketiga berkas
itu.

Butir lain pada daftar Agit sudah terpenuhi dan buktinya tercatat: kamus data
cocok dengan `sql/01_struktur.sql` untuk sebelas tabel, tabel kardinalitas
memuat delapan relasi dengan tipe 1:N, M:N, dan 1:0..1, serta laporan terbangun
tanpa rujukan menggantung.
