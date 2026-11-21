-- =====================================================================
-- 06_indeks.sql — KUNCI JAWABAN
-- Pemilik : Kenzie
-- Dua indeks sesuai PRD bagian 8.5, dapat dijalankan berulang.
-- =====================================================================
USE klinik_pratama;

-- idx_pasien_nama
SET @sql = (
  SELECT IF(COUNT(*) > 0, 'DROP INDEX idx_pasien_nama ON pasien', 'DO 0')
  FROM information_schema.statistics
  WHERE table_schema = 'klinik_pratama' AND index_name = 'idx_pasien_nama'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE INDEX idx_pasien_nama ON pasien (nama_pasien);

-- idx_kunjungan_tanggal
SET @sql = (
  SELECT IF(COUNT(*) > 0, 'DROP INDEX idx_kunjungan_tanggal ON kunjungan', 'DO 0')
  FROM information_schema.statistics
  WHERE table_schema = 'klinik_pratama' AND index_name = 'idx_kunjungan_tanggal'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE INDEX idx_kunjungan_tanggal ON kunjungan (tanggal_kunjungan, id_jadwal);

SELECT index_name, table_name, seq_in_index, column_name
FROM information_schema.statistics
WHERE table_schema = 'klinik_pratama'
  AND index_name IN ('idx_pasien_nama', 'idx_kunjungan_tanggal')
ORDER BY index_name, seq_in_index;

EXPLAIN SELECT * FROM pasien WHERE nama_pasien LIKE 'A%';
EXPLAIN SELECT * FROM kunjungan WHERE tanggal_kunjungan = '2026-09-10';
