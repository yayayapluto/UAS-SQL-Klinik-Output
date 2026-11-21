-- =====================================================================
-- 07_pengujian.sql — KUNCI JAWABAN
-- Pemilik : Rassya
-- Sepuluh skenario uji. Jalankan dengan mysql --force karena uji 1-6
-- dan 8-10 sengaja menghasilkan galat.
--   bash tools/reset-db.sh
--   mysql ... --force < sql/07_pengujian.sql
-- =====================================================================
USE klinik_pratama;

SELECT '=== UJI 1. Antrean ganda ditolak ===' AS uji;
INSERT INTO kunjungan (id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan)
VALUES (5, 2, '2026-08-06', 1, 'Menunggu');

SELECT '=== UJI 2. Pasien tidak terdaftar ditolak ===' AS uji;
INSERT INTO kunjungan (id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan)
VALUES (999, 1, '2026-08-05', 9, 'Menunggu');

SELECT '=== UJI 3. Suhu 50 derajat ditolak ===' AS uji;
UPDATE rekam_medis SET suhu = 50.0 WHERE id_rekam = 1;

SELECT '=== UJI 4. Kuota jadwal penuh ditolak ===' AS uji;
INSERT INTO kunjungan (id_pasien, id_jadwal, tanggal_kunjungan, no_antrean, status_kunjungan)
VALUES (5, 7, '2026-10-07', 5, 'Menunggu');

SELECT '=== UJI 5. Jadwal dokter bentrok ditolak ===' AS uji;
INSERT INTO jadwal_praktik (id_dokter, tanggal, jam_mulai, jam_selesai, ruangan, kuota)
VALUES (1, '2026-08-05', '10:00:00', '11:00:00', 'R-02', 5);

SELECT '=== UJI 6. Resep melebihi stok ditolak ===' AS uji;
INSERT INTO detail_resep (id_rekam, id_obat, jumlah, aturan_pakai)
VALUES (1, 8, 99, '3x1 sendok teh');

SELECT '=== UJI 7. Alur normal daftar, periksa, bayar ===' AS uji;
INSERT INTO jadwal_praktik (id_dokter, tanggal, jam_mulai, jam_selesai, ruangan, kuota)
VALUES (3, '2026-12-20', '09:00:00', '12:00:00', 'R-03', 5);
SET @jadwal_uji = LAST_INSERT_ID();

CALL sp_daftar_kunjungan(10, @jadwal_uji);
SET @kunjungan_uji = LAST_INSERT_ID();

INSERT INTO rekam_medis (id_kunjungan, keluhan, diagnosis, tekanan_darah, suhu,
                         berat_badan, tinggi_badan, tanggal_periksa)
VALUES (@kunjungan_uji, 'Gigi berlubang', 'Karies dentin', '120/80', 36.7, 62.0, 165.0, '2026-12-20');
SET @rekam_uji = LAST_INSERT_ID();

INSERT INTO detail_tindakan (id_kunjungan, id_tindakan, jumlah)
VALUES (@kunjungan_uji, 3, 1);
INSERT INTO detail_resep (id_rekam, id_obat, jumlah, aturan_pakai)
VALUES (@rekam_uji, 1, 10, '3x1 tablet');

CALL sp_bayar_kunjungan(@kunjungan_uji, 'Tunai');

SELECT '=== UJI 8. Pembayaran kedua ditolak ===' AS uji;
CALL sp_bayar_kunjungan(@kunjungan_uji, 'Tunai');

SELECT '=== UJI 9. View gabungan ===' AS uji;
SELECT COUNT(*) AS baris_view FROM v_kunjungan_lengkap;
SELECT id_kunjungan, nama_pasien, nama_dokter, nama_poli, status_bayar
FROM v_kunjungan_lengkap ORDER BY id_kunjungan;

SELECT '=== UJI 10. Hak akses petugas ===' AS uji;
SHOW GRANTS FOR 'petugas_klinik'@'%';

SELECT '=== PEMBERSIHAN ===' AS uji;
DELETE FROM pembayaran     WHERE id_kunjungan = @kunjungan_uji;
DELETE FROM detail_resep   WHERE id_rekam = @rekam_uji;
DELETE FROM detail_tindakan WHERE id_kunjungan = @kunjungan_uji;
DELETE FROM rekam_medis    WHERE id_rekam = @rekam_uji;
DELETE FROM kunjungan      WHERE id_kunjungan = @kunjungan_uji;
DELETE FROM jadwal_praktik WHERE id_jadwal = @jadwal_uji;
UPDATE obat SET stok = stok + 10 WHERE id_obat = 1;

SELECT 'kunjungan' AS tabel, COUNT(*) AS baris FROM kunjungan
UNION ALL SELECT 'pembayaran', COUNT(*) FROM pembayaran
UNION ALL SELECT 'jadwal_praktik', COUNT(*) FROM jadwal_praktik
UNION ALL SELECT 'rekam_medis', COUNT(*) FROM rekam_medis;
