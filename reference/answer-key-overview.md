# 2-Expected-Result-KlinikPratama

Acuan penilaian. Isi folder ini bukan pekerjaan siapa pun, melainkan keadaan
yang harus dicapai bila tugas dikerjakan benar. Dipakai untuk membandingkan
hasil kerja tim di `3-Repo-Terkirim-KlinikPratama`.

## Keadaan yang diharapkan

| Sasaran | Ukuran lulusan |
|---|---|
| Skema | 11 tabel dasar, 2 view, 4 trigger, 2 prosedur, 3 pengguna |
| Data contoh | setiap tabel minimal 5 baris, angka khusus sesuai Bab 4 PRD |
| Constraint | 10 foreign key, semuanya `ON DELETE RESTRICT` |
| Pemeriksaan | `tools/verify.sh` berakhir `Lulus: 34   Gagal: 0` |
| Transaksi | `tools/demo-isolasi.sh` membuktikan READ COMMITTED, REPEATABLE READ, dan galat 1213 |
| Indeks | `EXPLAIN` memakai `idx_pasien_nama` dan `idx_kunjungan_tanggal` |

## Kriteria penerimaan menurut PRD

Sumber resmi ada di panduan, tidak disalin ke sini supaya tidak ada dua versi:

- `1-Panduan-KlinikPratama/docs/PRD.md` — kebutuhan produk dan kriteria penerimaan.
- `1-Panduan-KlinikPratama/docs/PEMBAGIAN-TUGAS.md` — pemilik berkas dan urutan fase.
- `1-Panduan-KlinikPratama/docs/panduan-studi-kasus-erd.md` — Definition of Done Anggota 1 (Agit).
- `1-Panduan-KlinikPratama/sql/` — scaffold resmi sebelum diisi.

## `reference/verify-expected.txt`

Keluaran `verify.sh` yang dianggap benar. Bandingkan dengan hasil sendiri:

```bash
cd 3-Repo-Terkirim-KlinikPratama
"C:/Program Files/Git/bin/bash.exe" tools/reset-db.sh
"C:/Program Files/Git/bin/bash.exe" tools/verify.sh
```

Setelah database terisi Dapa sampai Rassya, baris terakhir harus sama:

```text
Lulus: 34   Gagal: 0
SEMUA PEMERIKSAAN LULUS
```

## Pemeriksaan Anggota 1

Butir yang dinilai untuk peran Anggota 1 (Agit), seluruhnya harus punya bukti
berkas: kesepakatan F0 (studi kasus, ruang lingkup, delapan aturan bisnis, kamus
data, delapan kebutuhan informasi, kardinalitas), ERD, Bab I, Bab III, subbab
NoSQL, serta laporan PDF yang sudah terbangun. Rincian per butir ada di
`1-Panduan-KlinikPratama/docs/panduan-studi-kasus-erd.md`.

Enam anggota tim pegang berkas SQL masing-masing: 1 Agit, 2 Dapa, 3 Farras,
4 Kenzie, 5 Kafka, 6 Rassya.
