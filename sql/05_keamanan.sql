-- =====================================================================
-- 05_keamanan.sql — KUNCI JAWABAN
-- Pemilik : Kafka
-- Tiga pengguna dan hak aksesnya sesuai PRD bagian 8.4.
-- =====================================================================
USE klinik_pratama;

DROP USER IF EXISTS 'petugas_klinik'@'%';
DROP USER IF EXISTS 'petugas_klinik'@'localhost';
DROP USER IF EXISTS 'dokter_klinik'@'%';
DROP USER IF EXISTS 'dokter_klinik'@'localhost';
DROP USER IF EXISTS 'admin_klinik'@'%';
DROP USER IF EXISTS 'admin_klinik'@'localhost';

CREATE USER 'petugas_klinik'@'%' IDENTIFIED BY 'Klinik#2026';
CREATE USER 'petugas_klinik'@'localhost' IDENTIFIED BY 'Klinik#2026';
CREATE USER 'dokter_klinik'@'%' IDENTIFIED BY 'Klinik#2026';
CREATE USER 'dokter_klinik'@'localhost' IDENTIFIED BY 'Klinik#2026';
CREATE USER 'admin_klinik'@'%' IDENTIFIED BY 'Klinik#2026';
CREATE USER 'admin_klinik'@'localhost' IDENTIFIED BY 'Klinik#2026';

-- Petugas meja depan: baca jadwal, daftarkan pasien. Tidak boleh menulis
-- rekam medis, obat, atau pembayaran.
GRANT SELECT ON `klinik_pratama`.`poli` TO 'petugas_klinik'@'%';
GRANT SELECT ON `klinik_pratama`.`dokter` TO 'petugas_klinik'@'%';
GRANT SELECT ON `klinik_pratama`.`jadwal_praktik` TO 'petugas_klinik'@'%';
GRANT SELECT, INSERT ON `klinik_pratama`.`pasien` TO 'petugas_klinik'@'%';
GRANT SELECT, INSERT ON `klinik_pratama`.`kunjungan` TO 'petugas_klinik'@'%';

GRANT SELECT ON `klinik_pratama`.`poli` TO 'petugas_klinik'@'localhost';
GRANT SELECT ON `klinik_pratama`.`dokter` TO 'petugas_klinik'@'localhost';
GRANT SELECT ON `klinik_pratama`.`jadwal_praktik` TO 'petugas_klinik'@'localhost';
GRANT SELECT, INSERT ON `klinik_pratama`.`pasien` TO 'petugas_klinik'@'localhost';
GRANT SELECT, INSERT ON `klinik_pratama`.`kunjungan` TO 'petugas_klinik'@'localhost';

-- Dokter: baca semua, tulis rekam medis dan resep.
GRANT SELECT ON `klinik_pratama`.* TO 'dokter_klinik'@'%';
GRANT INSERT, UPDATE ON `klinik_pratama`.`rekam_medis` TO 'dokter_klinik'@'%';
GRANT INSERT, UPDATE ON `klinik_pratama`.`detail_resep` TO 'dokter_klinik'@'%';

GRANT SELECT ON `klinik_pratama`.* TO 'dokter_klinik'@'localhost';
GRANT INSERT, UPDATE ON `klinik_pratama`.`rekam_medis` TO 'dokter_klinik'@'localhost';
GRANT INSERT, UPDATE ON `klinik_pratama`.`detail_resep` TO 'dokter_klinik'@'localhost';

-- Admin: hak penuh untuk pemeliharaan.
GRANT ALL PRIVILEGES ON `klinik_pratama`.* TO 'admin_klinik'@'%' WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON `klinik_pratama`.* TO 'admin_klinik'@'localhost' WITH GRANT OPTION;

SHOW GRANTS FOR 'petugas_klinik'@'%';
SHOW GRANTS FOR 'dokter_klinik'@'%';
SHOW GRANTS FOR 'admin_klinik'@'%';
