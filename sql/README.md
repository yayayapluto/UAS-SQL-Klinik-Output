# Scaffold SQL Klinik Pratama

Paket ini adalah kerangka kerja SQL untuk tim baru yang mengerjakan proyek Klinik Pratama. Semua berkas di dalamnya hanya berisi komentar, penanda TODO, dan kontrak nama objek. Tidak ada satu pun pernyataan SQL yang aktif, jadi paket ini belum menjadi solusi dan tidak dapat dijalankan apa adanya.

## Isi Paket

| Berkas | Pemilik | Isi |
| --- | --- | --- |
| `sql/00-kesepakatan.sql` | Agit | Kesepakatan nama objek, aturan bisnis, kardinalitas, dan kebutuhan informasi. |
| `sql/01_struktur.sql` | Farras | Sebelas tabel dasar beserta kunci primer, kunci asing, dan constraint. |
| `sql/02_data.sql` | Dapa | Jumlah baris, urutan pengisian, dan keadaan khusus data contoh untuk sebelas tabel. |
| `sql/03_view_trigger.sql` | Kenzie | Dua view dan empat trigger kuota, bentrok jadwal, serta stok obat. |
| `sql/04_prosedur.sql` | Agit | Dua prosedur pendaftaran kunjungan dan pembayaran. |
| `sql/05_keamanan.sql` | Kafka | Tiga user klinik beserta hak aksesnya. |
| `sql/06_indeks.sql` | Kenzie | Dua indeks untuk pencarian pasien dan rentang tanggal kunjungan. |
| `sql/07_pengujian.sql` | Rassya | Sepuluh uji perilaku untuk constraint, trigger, prosedur, view, dan hak akses. |
| `sql/08_kueri.sql` | Kafka | Sepuluh query bukti Q1 sampai Q10 sesuai PRD bagian 7. |

## Cara Pakai

Folder `sql/` ini sudah berada di repo kerja. Isi satu per satu sesuai urutan kerja.

Jangan menyalin paket ini ke repo yang sudah berisi solusi. Berkas dengan nama sama akan menimpa pekerjaan yang sudah ada dan menghapus hasil yang benar.

## Urutan Kerja

1. `01_struktur.sql`
2. `02_data.sql`
3. `03_view_trigger.sql`
4. `04_prosedur.sql`
5. `05_keamanan.sql`
6. `06_indeks.sql`
7. `07_pengujian.sql`, dikerjakan terpisah setelah enam berkas sebelumnya selesai.

Berkas 03 sampai 06 bergantung pada 01 dan 02. View dan trigger membaca tabel dari 01, prosedur memakai data dari 02, dan pengujian di 07 memeriksa seluruh objek yang dibuat sebelumnya. Kerjakan 01 dan 02 lebih dulu sampai bersih.

## Aturan Pengisian

1. Kerjakan daftar TODO di kepala berkas milikmu: tulis pernyataan SQL pada blok objek terkait, lalu ganti `[ ]` menjadi `[x]`.
2. Biarkan daftar TODO sampai fase ditutup. Tanda `[x]` menjadi bukti kemajuan.
3. Jangan mengubah nama tabel, kolom, constraint, view, trigger, prosedur, atau user yang sudah ditetapkan.
4. Jangan menyentuh berkas anggota lain. Setiap berkas punya pemilik tunggal.

Tipe data dan detail tipe tidak disalin di scaffold. Rujuk PRD di ZIP panduan, bagian 5, untuk kontrak lengkap.

## Menjalankan Satu Berkas SQL

Runner `tools/run-sql.sh` menjalankan satu berkas tanpa reset.

```bash
bash tools/run-sql.sh 02
```

Di CMD atau PowerShell:

```text
tools\run-sql.cmd 02
```

Runner mencari container `kbd-mysql`, lalu container `mysql`, lalu MySQL host
seperti Laragon atau XAMPP. Opsi: `--name <container>` dan `--host`. Kata sandi
container default `kbd`, host default kosong; set `KBD_PW` bila berbeda. Berkas
`07` otomatis memakai `--force`.

## Tool Pendukung

`tools/run-sql.sh` dan `tools/run-sql.cmd` sudah tersedia. Tool
`tools/reset-db.sh`, `tools/verify.sh`, dan `tools/demo-isolasi.sh` ditulis Rassya
pada Fase F3 mengikuti panduan Rassya di ZIP panduan.

Tim terdiri atas enam anggota: 1 Agit, 2 Dapa, 3 Farras, 4 Kenzie, 5 Kafka, dan
6 Rassya. Setiap berkas SQL dipegang satu orang sesuai tabel di atas.

## Kriteria Selesai

Pekerjaan dinyatakan selesai jika seluruh kondisi berikut terpenuhi.

1. `tabel terdaftar: 11`
2. `Lulus: 34   Gagal: 0`
3. Sepuluh uji di `07_pengujian.sql` memberi hasil sesuai kontrak.
4. Berkas bukti diperbarui dari keluaran terakhir, bukan hasil percobaan sebelumnya.

## Rujukan

- PRD, Pembagian Tugas, dan panduan Rassya ada di ZIP panduan.
