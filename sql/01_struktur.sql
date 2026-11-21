-- =====================================================================
-- 01_struktur.sql — KUNCI JAWABAN
-- Pemilik : Farras
-- Membuat database klinik_pratama dan sebelas tabel beserta kunci,
-- kunci tamu, dan constraint sesuai PRD bagian 5.
-- =====================================================================

CREATE DATABASE IF NOT EXISTS klinik_pratama
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE klinik_pratama;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS pembayaran;
DROP TABLE IF EXISTS detail_resep;
DROP TABLE IF EXISTS detail_tindakan;
DROP TABLE IF EXISTS rekam_medis;
DROP TABLE IF EXISTS kunjungan;
DROP TABLE IF EXISTS jadwal_praktik;
DROP TABLE IF EXISTS dokter;
DROP TABLE IF EXISTS pasien;
DROP TABLE IF EXISTS obat;
DROP TABLE IF EXISTS tindakan;
DROP TABLE IF EXISTS poli;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. poli -------------------------------------------------------------
CREATE TABLE poli (
  id_poli   INT AUTO_INCREMENT PRIMARY KEY,
  nama_poli VARCHAR(50) NOT NULL,
  lantai    VARCHAR(10) NOT NULL,
  CONSTRAINT uq_poli_nama UNIQUE (nama_poli)
) ENGINE=InnoDB;

-- 2. dokter -----------------------------------------------------------
CREATE TABLE dokter (
  id_dokter   INT AUTO_INCREMENT PRIMARY KEY,
  id_poli     INT NOT NULL,
  nama_dokter VARCHAR(100) NOT NULL,
  no_sip      VARCHAR(30) NOT NULL,
  email       VARCHAR(100) NOT NULL,
  no_telp     VARCHAR(20) NULL,
  tipe_dokter ENUM('Umum','Spesialis') NOT NULL DEFAULT 'Umum',
  CONSTRAINT uq_dokter_sip UNIQUE (no_sip),
  CONSTRAINT uq_dokter_email UNIQUE (email),
  CONSTRAINT fk_dokter_poli FOREIGN KEY (id_poli) REFERENCES poli (id_poli)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 3. jadwal_praktik ---------------------------------------------------
CREATE TABLE jadwal_praktik (
  id_jadwal   INT AUTO_INCREMENT PRIMARY KEY,
  id_dokter   INT NOT NULL,
  tanggal     DATE NOT NULL,
  jam_mulai   TIME NOT NULL,
  jam_selesai TIME NOT NULL,
  ruangan     VARCHAR(30) NOT NULL,
  kuota       INT NOT NULL,
  CONSTRAINT uq_jadwal_sesi UNIQUE (id_dokter, tanggal, jam_mulai),
  CONSTRAINT ck_jadwal_jam CHECK (jam_selesai > jam_mulai),
  CONSTRAINT ck_jadwal_kuota CHECK (kuota > 0),
  CONSTRAINT fk_jadwal_dokter FOREIGN KEY (id_dokter) REFERENCES dokter (id_dokter)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 4. pasien -----------------------------------------------------------
CREATE TABLE pasien (
  id_pasien     INT AUTO_INCREMENT PRIMARY KEY,
  nama_pasien   VARCHAR(100) NOT NULL,
  nik           CHAR(16) NOT NULL,
  email         VARCHAR(100) NULL,
  no_telp       VARCHAR(20) NULL,
  tanggal_lahir DATE NOT NULL,
  alamat        VARCHAR(200) NULL,
  CONSTRAINT uq_pasien_nik UNIQUE (nik),
  CONSTRAINT uq_pasien_email UNIQUE (email)
) ENGINE=InnoDB;

-- 5. kunjungan --------------------------------------------------------
CREATE TABLE kunjungan (
  id_kunjungan      INT AUTO_INCREMENT PRIMARY KEY,
  id_pasien         INT NOT NULL,
  id_jadwal         INT NOT NULL,
  tanggal_kunjungan DATE NOT NULL,
  no_antrean        INT NOT NULL,
  status_kunjungan  ENUM('Menunggu','Diperiksa','Selesai','Batal') NOT NULL DEFAULT 'Menunggu',
  CONSTRAINT uq_kunjungan_antrean UNIQUE (id_jadwal, no_antrean),
  CONSTRAINT uq_kunjungan_pasien  UNIQUE (id_pasien, id_jadwal),
  CONSTRAINT fk_kunjungan_pasien FOREIGN KEY (id_pasien) REFERENCES pasien (id_pasien)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kunjungan_jadwal FOREIGN KEY (id_jadwal) REFERENCES jadwal_praktik (id_jadwal)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 6. rekam_medis ------------------------------------------------------
CREATE TABLE rekam_medis (
  id_rekam      INT AUTO_INCREMENT PRIMARY KEY,
  id_kunjungan  INT NOT NULL,
  keluhan       VARCHAR(200) NOT NULL,
  diagnosis     VARCHAR(200) NOT NULL,
  tekanan_darah VARCHAR(15) NULL,
  suhu          DECIMAL(4,1) NULL,
  berat_badan   DECIMAL(5,1) NULL,
  tinggi_badan  DECIMAL(4,1) NULL,
  imt           DECIMAL(4,1) AS (ROUND(berat_badan / ((tinggi_badan/100) * (tinggi_badan/100)), 1)) STORED,
  tanggal_periksa DATE NOT NULL,
  CONSTRAINT uq_rekam_kunjungan UNIQUE (id_kunjungan),
  CONSTRAINT ck_rekam_suhu CHECK (suhu BETWEEN 30.0 AND 45.0),
  CONSTRAINT ck_rekam_berat CHECK (berat_badan BETWEEN 1.0 AND 300.0),
  CONSTRAINT ck_rekam_tinggi CHECK (tinggi_badan BETWEEN 30.0 AND 250.0),
  CONSTRAINT fk_rekam_kunjungan FOREIGN KEY (id_kunjungan) REFERENCES kunjungan (id_kunjungan)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. tindakan ---------------------------------------------------------
CREATE TABLE tindakan (
  id_tindakan   INT AUTO_INCREMENT PRIMARY KEY,
  nama_tindakan VARCHAR(80) NOT NULL,
  tarif         DECIMAL(10,2) NOT NULL,
  CONSTRAINT uq_tindakan_nama UNIQUE (nama_tindakan),
  CONSTRAINT ck_tindakan_tarif CHECK (tarif >= 0)
) ENGINE=InnoDB;

-- 8. detail_tindakan --------------------------------------------------
CREATE TABLE detail_tindakan (
  id_detail_tindakan INT AUTO_INCREMENT PRIMARY KEY,
  id_kunjungan       INT NOT NULL,
  id_tindakan        INT NOT NULL,
  jumlah             INT NOT NULL DEFAULT 1,
  CONSTRAINT uq_detail_tindakan UNIQUE (id_kunjungan, id_tindakan),
  CONSTRAINT ck_detail_tindakan_jumlah CHECK (jumlah > 0),
  CONSTRAINT fk_detail_tindakan_kunjungan FOREIGN KEY (id_kunjungan)
    REFERENCES kunjungan (id_kunjungan) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_detail_tindakan_tindakan FOREIGN KEY (id_tindakan)
    REFERENCES tindakan (id_tindakan) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 9. obat -------------------------------------------------------------
CREATE TABLE obat (
  id_obat   INT AUTO_INCREMENT PRIMARY KEY,
  nama_obat VARCHAR(80) NOT NULL,
  satuan    VARCHAR(20) NOT NULL,
  harga     DECIMAL(10,2) NOT NULL,
  stok      INT NOT NULL DEFAULT 0,
  CONSTRAINT uq_obat_nama UNIQUE (nama_obat),
  CONSTRAINT ck_obat_harga CHECK (harga >= 0),
  CONSTRAINT ck_obat_stok CHECK (stok >= 0)
) ENGINE=InnoDB;

-- 10. detail_resep ----------------------------------------------------
CREATE TABLE detail_resep (
  id_detail_resep INT AUTO_INCREMENT PRIMARY KEY,
  id_rekam        INT NOT NULL,
  id_obat         INT NOT NULL,
  jumlah          INT NOT NULL,
  aturan_pakai    VARCHAR(100) NULL,
  CONSTRAINT uq_detail_resep UNIQUE (id_rekam, id_obat),
  CONSTRAINT ck_detail_resep_jumlah CHECK (jumlah > 0),
  CONSTRAINT fk_detail_resep_rekam FOREIGN KEY (id_rekam) REFERENCES rekam_medis (id_rekam)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_detail_resep_obat FOREIGN KEY (id_obat) REFERENCES obat (id_obat)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 11. pembayaran ------------------------------------------------------
CREATE TABLE pembayaran (
  id_pembayaran  INT AUTO_INCREMENT PRIMARY KEY,
  id_kunjungan   INT NOT NULL,
  tanggal_bayar  DATE NULL,
  metode         ENUM('Tunai','Transfer','BPJS') NOT NULL,
  total_tagihan  DECIMAL(12,2) NOT NULL,
  status_bayar   ENUM('Lunas','Belum Lunas') NOT NULL DEFAULT 'Belum Lunas',
  CONSTRAINT uq_pembayaran_kunjungan UNIQUE (id_kunjungan),
  CONSTRAINT ck_pembayaran_total CHECK (total_tagihan >= 0),
  CONSTRAINT fk_pembayaran_kunjungan FOREIGN KEY (id_kunjungan)
    REFERENCES kunjungan (id_kunjungan) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

SELECT COUNT(*) AS tabel_terdaftar
FROM information_schema.tables
WHERE table_schema = 'klinik_pratama' AND table_type = 'BASE TABLE';
