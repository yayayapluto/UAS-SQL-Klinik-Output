-- =====================================================================
-- 08_kueri.sql — KUNCI JAWABAN
-- Pemilik : Kafka
-- Sepuluh query bukti (Q1-Q10) sesuai PRD bagian 7.
-- =====================================================================
USE klinik_pratama;

SELECT '=== Q1. Pasien lahir sebelum 2005, tertua dulu ===' AS q;
SELECT id_pasien, nama_pasien, tanggal_lahir
FROM pasien
WHERE tanggal_lahir < '2005-01-01'
ORDER BY tanggal_lahir;

SELECT '=== Q2. Dokter, poli, lantai ===' AS q;
SELECT d.nama_dokter, p.nama_poli, p.lantai
FROM dokter d
JOIN poli p ON p.id_poli = d.id_poli
ORDER BY d.nama_dokter;

SELECT '=== Q3. Riwayat kunjungan lengkap ===' AS q;
SELECT k.id_kunjungan, pa.nama_pasien, d.nama_dokter, p.nama_poli,
       k.tanggal_kunjungan, k.status_kunjungan
FROM kunjungan k
JOIN pasien pa       ON pa.id_pasien = k.id_pasien
JOIN jadwal_praktik j ON j.id_jadwal = k.id_jadwal
JOIN dokter d        ON d.id_dokter = j.id_dokter
JOIN poli p          ON p.id_poli = d.id_poli
ORDER BY k.id_kunjungan;

SELECT '=== Q4. Sisa kuota tiap jadwal ===' AS q;
SELECT j.id_jadwal, d.nama_dokter, j.tanggal, j.kuota,
       COUNT(k.id_kunjungan) AS terpakai,
       j.kuota - COUNT(k.id_kunjungan) AS sisa_kuota
FROM jadwal_praktik j
JOIN dokter d ON d.id_dokter = j.id_dokter
LEFT JOIN kunjungan k
       ON k.id_jadwal = j.id_jadwal AND k.status_kunjungan <> 'Batal'
GROUP BY j.id_jadwal, d.nama_dokter, j.tanggal, j.kuota
ORDER BY j.id_jadwal;

SELECT '=== Q5. Tagihan belum lunas ===' AS q;
SELECT b.id_pembayaran, pa.nama_pasien, b.total_tagihan, b.status_bayar
FROM pembayaran b
JOIN kunjungan k ON k.id_kunjungan = b.id_kunjungan
JOIN pasien pa   ON pa.id_pasien = k.id_pasien
WHERE b.status_bayar = 'Belum Lunas'
ORDER BY b.total_tagihan DESC;

SELECT '=== Q6. Pasien Poli Anak dan pasien tertua ===' AS q;
SELECT id_pasien, nama_pasien, tanggal_lahir
FROM pasien
WHERE id_pasien IN (
  SELECT k.id_pasien
  FROM kunjungan k
  JOIN jadwal_praktik j ON j.id_jadwal = k.id_jadwal
  JOIN dokter d         ON d.id_dokter = j.id_dokter
  JOIN poli p           ON p.id_poli = d.id_poli
  WHERE p.nama_poli = 'Poli Anak'
)
ORDER BY tanggal_lahir;

SELECT nama_pasien AS pasien_tertua, tanggal_lahir
FROM pasien
WHERE tanggal_lahir = (SELECT MIN(tanggal_lahir) FROM pasien);

SELECT '=== Q7. Poli di atas rata-rata pendapatan ===' AS q;
SELECT p.nama_poli, SUM(b.total_tagihan) AS total_pendapatan
FROM pembayaran b
JOIN kunjungan k      ON k.id_kunjungan = b.id_kunjungan
JOIN jadwal_praktik j ON j.id_jadwal = k.id_jadwal
JOIN dokter d         ON d.id_dokter = j.id_dokter
JOIN poli p           ON p.id_poli = d.id_poli
WHERE b.status_bayar = 'Lunas'
GROUP BY p.nama_poli
HAVING SUM(b.total_tagihan) > (
  SELECT AVG(t.total) FROM (
    SELECT SUM(b2.total_tagihan) AS total
    FROM pembayaran b2
    JOIN kunjungan k2      ON k2.id_kunjungan = b2.id_kunjungan
    JOIN jadwal_praktik j2 ON j2.id_jadwal = k2.id_jadwal
    JOIN dokter d2         ON d2.id_dokter = j2.id_dokter
    JOIN poli p2           ON p2.id_poli = d2.id_poli
    WHERE b2.status_bayar = 'Lunas'
    GROUP BY p2.nama_poli
  ) t
)
ORDER BY total_pendapatan DESC;

SELECT '=== Q8. Obat paling banyak keluar ===' AS q;
SELECT o.nama_obat, SUM(dr.jumlah) AS total_keluar, COUNT(*) AS jumlah_resep
FROM detail_resep dr
JOIN obat o ON o.id_obat = dr.id_obat
GROUP BY o.id_obat, o.nama_obat
ORDER BY total_keluar DESC
LIMIT 1;

SELECT '=== Q9. Kategori biaya kunjungan ===' AS q;
SELECT CASE
         WHEN b.total_tagihan < 50000  THEN 'Ringan'
         WHEN b.total_tagihan <= 150000 THEN 'Sedang'
         ELSE 'Berat'
       END AS kategori,
       COUNT(*) AS jumlah
FROM pembayaran b
GROUP BY kategori
ORDER BY jumlah DESC;

SELECT '=== Q10. Peringkat dokter ===' AS q;
SELECT d.nama_dokter, COUNT(k.id_kunjungan) AS jumlah_kunjungan,
       RANK() OVER (ORDER BY COUNT(k.id_kunjungan) DESC) AS peringkat
FROM dokter d
LEFT JOIN jadwal_praktik j ON j.id_dokter = d.id_dokter
LEFT JOIN kunjungan k      ON k.id_jadwal = j.id_jadwal
GROUP BY d.id_dokter, d.nama_dokter
ORDER BY peringkat, d.nama_dokter;
