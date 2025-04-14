-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Apr 14, 2025 at 12:07 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `community_aspirations`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_complaint` (IN `p_citizen_id` INT, IN `p_agency_id` INT, IN `p_category_id` INT, IN `p_judul` VARCHAR(255), IN `p_deskripsi` TEXT)   BEGIN
    INSERT INTO complaint (
        citizen_id,
        agency_id,
        category_id,
        judul,
        deskripsi,
        status,
        created_at,
        updated_at,
        deleted_at,
        is_deleted
    ) VALUES (
        p_citizen_id,
        p_agency_id,
        p_category_id,
        p_judul,
        p_deskripsi,
        'diajukan',
        NOW(),
        NOW(),
        NULL,
        FALSE
    );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `respond_to_complaint` (IN `p_complaint_id` INT, IN `p_officer_id` INT, IN `p_deskripsi` TEXT)   BEGIN
    DECLARE complaint_status ENUM('diajukan', 'diproses', 'selesai') DEFAULT NULL;


    SELECT status INTO complaint_status
    FROM complaint
    WHERE complaint_id = p_complaint_id AND is_deleted = FALSE;

    IF complaint_status IS NOT NULL AND complaint_status != 'selesai' THEN

        -- Tambahkan respon
        INSERT INTO response (
            complaint_id,
            officer_id,
            deskripsi,
            created_at,
            updated_at,
            deleted_at,
            is_deleted
        ) VALUES (
            p_complaint_id,
            p_officer_id,
            p_deskripsi,
            NOW(),
            NOW(),
            NULL,
            FALSE
        );

        IF complaint_status = 'diajukan' THEN
            UPDATE complaint
            SET status = 'diproses',
                updated_at = NOW()
            WHERE complaint_id = p_complaint_id;
        END IF;

    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `soft_delete_complaint` (IN `p_complaint_id` INT)   BEGIN
    DECLARE v_exists INT;
    DECLARE v_is_deleted BOOLEAN;

    -- Cek apakah data ada
    SELECT COUNT(*) INTO v_exists
    FROM complaint
    WHERE complaint_id = p_complaint_id;

    IF v_exists > 0 THEN
        -- Cek apakah data sudah dihapus
        SELECT is_deleted INTO v_is_deleted
        FROM complaint
        WHERE complaint_id = p_complaint_id;

        IF NOT v_is_deleted THEN
            -- Eksekusi soft delete
            UPDATE complaint
            SET is_deleted = TRUE,
                deleted_at = NOW(),
                updated_at = NOW()
            WHERE complaint_id = p_complaint_id;
        END IF;
    END IF;
END$$

--
-- Functions
--
CREATE DEFINER=`root`@`localhost` FUNCTION `count_unread_notifications_by_citizen` (`citizenId` INT) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE unread_count INT;
    SELECT COUNT(*) INTO unread_count
    FROM notification
    WHERE citizen_id = citizenId
      AND status_dibaca = FALSE
      AND is_deleted = FALSE;
    RETURN unread_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `count_unread_notifications_by_officer` (`officerId` INT) RETURNS INT(11) DETERMINISTIC READS SQL DATA BEGIN
    DECLARE unread_count INT;
    SELECT COUNT(*) INTO unread_count
    FROM notification
    WHERE officer_id = officerId
      AND status_dibaca = FALSE
      AND is_deleted = FALSE;
    RETURN unread_count;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `get_complaint_status` (`p_complaint_id` INT) RETURNS VARCHAR(20) CHARSET utf8mb4 COLLATE utf8mb4_general_ci DETERMINISTIC READS SQL DATA BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM complaint
    WHERE complaint_id = p_complaint_id;

    RETURN v_status;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `admin`
--

CREATE TABLE `admin` (
  `admin_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `role` enum('admin','super_admin') NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `admin`
--

INSERT INTO `admin` (`admin_id`, `nama`, `email`, `password`, `no_telepon`, `role`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 'Ahmad Fauzi', 'ahmad.fauzi@admin.go.id', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '0811111111', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(2, 'Linda Pratiwi', 'linda.pratiwi@admin.go.id', '8f01f2e0a9140cd538f0874c0f72269395ebc55d7a17e2d883553e2a36170da3', '0811111112', 'super_admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(3, 'Rizky Hidayat', 'rizky.hidayat@admin.go.id', 'f3d63c9346b22494e1dd0aca73a12ed26270ad605bd8ba9824a404334582cf55', '0811111113', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(4, 'Sari Wulandari', 'sari.wulandari@admin.go.id', '6da7c83a5fc8a55e61da47c5b14c6680752a5f3791c563f0f3541bc50e13d1b2', '0811111114', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(5, 'Bayu Setiawan', 'bayu.setiawan@admin.go.id', '17e44eb889431f97e52b59f38671dfdc45ae0855fbf631834b470f1316d95a81', '0811111115', 'super_admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(6, 'Nina Rachmawati', 'nina.rachmawati@admin.go.id', '99351f88dd917f353be0e11ad19409d647c30c6b3cc2d4075e2127e011b4a3b0', '0811111116', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(7, 'Teguh Prakoso', 'teguh.prakoso@admin.go.id', 'a3c6f5ad4df48d3152443eef1b1e823cdb0bff37244405fe4cacd913b4f190e0', '0811111117', 'super_admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(8, 'Desi Amelia', 'desi.amelia@admin.go.id', '9773e4214d2a3c296ebd73a7e8cd4b8dcf885e838c34148e7aa247636f765af2', '0811111118', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(9, 'Budi Hartono', 'budi.hartono@admin.go.id', '4194d1706ed1f408d5e02d672777019f4d5385c766a8c6ca8acba3167d36a7b9', '0811111119', 'admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0),
(10, 'Yulia Safitri', 'yulia.safitri@admin.go.id', 'bc1ecaca1f3a8da6c0a060e2d2b2ff8bde07252bd4ad50e86d7df642ad0af9ec', '0811111120', 'super_admin', '2025-04-09 17:46:47', '2025-04-09 17:46:47', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `agency`
--

CREATE TABLE `agency` (
  `agency_id` int(11) NOT NULL,
  `nama_instansi` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `alamat` varchar(255) DEFAULT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `agency`
--

INSERT INTO `agency` (`agency_id`, `nama_instansi`, `deskripsi`, `alamat`, `no_telepon`, `email`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 'Dinas Kebersihan Kota', 'Mengelola kebersihan dan pengelolaan sampah kota.', 'Jl. Kebersihan No. 1', '0211234567', 'kebersihan@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(2, 'Dinas Perhubungan', 'Mengatur lalu lintas dan transportasi umum.', 'Jl. Transportasi No. 10', '0212345678', 'perhubungan@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(3, 'Dinas Kesehatan', 'Pelayanan dan pengawasan kesehatan masyarakat.', 'Jl. Kesehatan No. 5', '0213456789', 'kesehatan@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(4, 'Dinas Pendidikan', 'Mengelola pendidikan dan sekolah negeri.', 'Jl. Pendidikan No. 12', '0214567890', 'pendidikan@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(5, 'Dinas Pekerjaan Umum', 'Pembangunan infrastruktur dan jalan.', 'Jl. Infrastruktur No. 3', '0215678901', 'pu@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(6, 'Dinas Lingkungan Hidup', 'Menjaga kelestarian lingkungan dan penghijauan.', 'Jl. Hijau No. 8', '0216789012', 'lingkungan@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(7, 'Dinas Sosial', 'Pelayanan bantuan sosial dan kesejahteraan masyarakat.', 'Jl. Sosial No. 7', '0217890123', 'sosial@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(8, 'Dinas Pariwisata', 'Promosi pariwisata dan pengembangan destinasi wisata.', 'Jl. Pariwisata No. 4', '0218901234', 'pariwisata@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(9, 'Dinas Pemadam Kebakaran', 'Penanggulangan kebakaran dan bencana.', 'Jl. Damkar No. 9', '0219012345', 'damkar@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0),
(10, 'Dinas Catatan Sipil', 'Pencatatan kelahiran, kematian, dan dokumen kependudukan.', 'Jl. Sipil No. 6', '0210123456', 'dukcapil@dinas.go.id', '2025-04-09 17:45:10', '2025-04-09 17:45:10', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `agency_officer`
--

CREATE TABLE `agency_officer` (
  `officer_id` int(11) NOT NULL,
  `agency_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `agency_officer`
--

INSERT INTO `agency_officer` (`officer_id`, `agency_id`, `nama`, `email`, `password`, `no_telepon`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, 'Agus Santoso', 'agus.santoso@dinas.go.id', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', '081234567001', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(2, 2, 'Rina Wijaya', 'rina.wijaya@dinas.go.id', 'fbb4a8a163ffa958b4f02bf9cabb30cfefb40de803f2c4c346a9d39b3be1b544', '081234567002', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(3, 3, 'Dedi Prasetyo', 'dedi.prasetyo@dinas.go.id', 'becf77f3ec82a43422b7712134d1860e3205c6ce778b08417a7389b43f2b4661', '081234567003', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(4, 4, 'Siti Aminah', 'siti.aminah@dinas.go.id', 'ee0c4d2b2b45335c82d407b6851d82d16d46da9147eb22166b04c570c62838a1', '081234567004', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(5, 5, 'Bambang Sutrisno', 'bambang.sutrisno@dinas.go.id', 'f6597995cfa0bdeba5c74d6accd009f2d39127d5c9172a3230cc28512b4f2719', '081234567005', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(6, 6, 'Yuni Kartika', 'yuni.kartika@dinas.go.id', 'd43c150f00ba7bcddca29502e719f3c72b3b3150159e408cf839739b292fccd6', '081234567006', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(7, 7, 'Anton Subagyo', 'anton.subagyo@dinas.go.id', 'eb2a11486775d60850f090424bab2a9df67c579f9debfc539fb2be8ecdfc129c', '081234567007', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(8, 8, 'Dewi Lestari', 'dewi.lestari@dinas.go.id', '3f01877481f89bb1a90a3ba09abe2564eda7af82641e2e085e1011e32fbd2beb', '081234567008', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(9, 9, 'Fajar Nugroho', 'fajar.nugroho@dinas.go.id', '3fd8406c60896511671324763e09396ed8e0a7c01460b0af4f65ab8902350654', '081234567009', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0),
(10, 10, 'Mega Ayu', 'mega.ayu@dinas.go.id', '04fb9b5b7c3227f82c0d8fea8ead15e48d36adf82fa6b48f2f8aa1b8eccc495b', '081234567010', '2025-04-09 17:46:16', '2025-04-09 17:46:16', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `attachment`
--

CREATE TABLE `attachment` (
  `attachment_id` int(11) NOT NULL,
  `complaint_id` int(11) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `attachment`
--

INSERT INTO `attachment` (`attachment_id`, `complaint_id`, `file_path`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, '/uploads/lampiran/bukti_1.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(2, 2, '/uploads/lampiran/bukti_2.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(3, 3, '/uploads/lampiran/bukti_3.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(4, 4, '/uploads/lampiran/bukti_4.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(5, 5, '/uploads/lampiran/bukti_5.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(6, 6, '/uploads/lampiran/bukti_6.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(7, 7, '/uploads/lampiran/bukti_7.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(8, 8, '/uploads/lampiran/bukti_8.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(9, 9, '/uploads/lampiran/bukti_9.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0),
(10, 10, '/uploads/lampiran/bukti_10.jpg', '2025-04-09 17:51:04', '2025-04-09 17:51:04', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `citizen`
--

CREATE TABLE `citizen` (
  `citizen_id` int(11) NOT NULL,
  `nama` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `alamat` varchar(255) NOT NULL,
  `no_telepon` varchar(20) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `citizen`
--

INSERT INTO `citizen` (`citizen_id`, `nama`, `email`, `password`, `alamat`, `no_telepon`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 'Andi Setiawan', 'andi1@mail.com', 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f', 'Jl. Merpati No. 10', '081234567891', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(2, 'Budi Hartono', 'budi2@mail.com', 'bee5688aea66a47460b19c76f8f199c6b9585eb726f8322b1429793863609ca2', 'Jl. Kenanga No. 15', '081234567892', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(3, 'Citra Lestari', 'citra3@mail.com', 'da3f5b21acfffc0cd87606249241f7dc87c5038081e73439d222de4a8d28002f', 'Jl. Dahlia No. 7', '081234567893', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(4, 'Dewi Anggraini', 'dewi4@mail.com', 'e45dcfc4e2dbc52b15bb69f1c1bf26e27e8be8bfba0e4e834a622310f21cc618', 'Jl. Mawar No. 23', '081234567894', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(5, 'Eka Putra', 'eka5@mail.com', 'dd8db0312fd22a729cb6492e5bd10c1a257d3c798b273a1f136157542007e0a6', 'Jl. Melati No. 3', '081234567895', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(6, 'Fajar Prasetyo', 'fajar6@mail.com', 'ef1322b0f16fd6ac0e4af8688cbae8c08468c1ac9b2408120a432fd49fa8b1f1', 'Jl. Anggrek No. 18', '081234567896', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(7, 'Gita Sari', 'gita7@mail.com', 'ba236ecb3a47718586afee5e735c96fb2d0c4128e93922d71f8d8a0543cf2211', 'Jl. Kamboja No. 2', '081234567897', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(8, 'Hendra Gunawan', 'hendra8@mail.com', 'beb956c90458021898724632bb04df4e4cfc77727c01ad224be246a3eed0db4e', 'Jl. Cendana No. 12', '081234567898', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(9, 'Indah Permata', 'indah9@mail.com', 'c50c2b24bd6c1371ff788cc0b4e5765e9b6a91076d0726200376e2d5aa816b1f', 'Jl. Teratai No. 20', '081234567899', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0),
(10, 'Joko Santoso', 'joko10@mail.com', 'e17558363f9e584b0fab423988dd969fedbf0a3259fe2a7204254a397bd7a549', 'Jl. Flamboyan No. 1', '081234567900', '2025-04-09 17:42:43', '2025-04-09 17:42:43', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `complaint`
--

CREATE TABLE `complaint` (
  `complaint_id` int(11) NOT NULL,
  `citizen_id` int(11) NOT NULL,
  `agency_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `judul` varchar(255) NOT NULL,
  `deskripsi` text NOT NULL,
  `status` enum('diajukan','diproses','selesai') NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `complaint`
--

INSERT INTO `complaint` (`complaint_id`, `citizen_id`, `agency_id`, `category_id`, `judul`, `deskripsi`, `status`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, 1, 1, 'Jalan Berlubang di Jalan Raya', 'Terdapat lubang besar di jalan raya yang membahayakan pengendara.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(2, 2, 2, 2, 'Sampah Menumpuk di Pinggir Jalan', 'Sampah tidak diangkut selama seminggu terakhir.', 'diproses', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(3, 3, 3, 3, 'Lampu Jalan Mati', 'Lampu jalan di area kompleks perumahan mati sejak dua minggu lalu.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(4, 4, 4, 4, 'Air PDAM Tidak Mengalir', 'Sudah tiga hari air PDAM tidak mengalir di wilayah saya.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(5, 5, 5, 5, 'Pelayanan di Puskesmas Lambat', 'Antrian panjang dan hanya satu dokter yang melayani.', 'diproses', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(6, 1, 2, 1, 'Trotoar Rusak', 'Trotoar di depan sekolah rusak dan membahayakan anak-anak.', 'selesai', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(7, 2, 3, 2, 'Sungai Tercemar Limbah', 'Air sungai berwarna hitam dan berbau menyengat.', 'diproses', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(8, 3, 4, 3, 'Halte Bus Rusak', 'Atap halte bus roboh dan tidak ada perbaikan.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(9, 4, 5, 4, 'Tidak Ada Air di Sekolah', 'Kamar mandi di sekolah tidak memiliki air.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(10, 5, 1, 5, 'Rumah Sakit Kekurangan Obat', 'Obat-obatan dasar tidak tersedia di IGD.', 'diajukan', '2025-04-09 17:48:26', '2025-04-09 17:48:26', NULL, 0),
(11, 1, 2, 3, 'Jalan Rusak', 'Jalan di depan rumah berlubang dan membahayakan.', 'diajukan', '2025-04-14 09:08:33', '2025-04-14 09:18:29', '2025-04-14 09:18:29', 1),
(12, 1, 1, 1, 'Lampu Jalan Mati', 'Lampu jalan depan rumah mati selama 3 hari.', 'diajukan', '2025-04-14 10:21:29', '2025-04-14 10:21:29', NULL, 0);

--
-- Triggers `complaint`
--
DELIMITER $$
CREATE TRIGGER `trg_log_add_complaint` AFTER INSERT ON `complaint` FOR EACH ROW BEGIN
  INSERT INTO log_activity (
    citizen_id,
    aktivitas,
    deskripsi,
    created_at
  ) VALUES (
    NEW.citizen_id,
    'Tambah Pengaduan',
    CONCAT('Warga menambahkan pengaduan dengan judul "', NEW.judul, '"'),
    NOW()
  );
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_notify_agency_officer` AFTER INSERT ON `complaint` FOR EACH ROW BEGIN
  DECLARE officerId INT;

  SELECT officer_id INTO officerId
  FROM agency_officer
  WHERE agency_id = NEW.agency_id
  LIMIT 1;

  IF officerId IS NOT NULL THEN
    INSERT INTO notification (
      officer_id,
      complaint_id,
      pesan,
      status_dibaca,
      created_at,
      updated_at
    ) VALUES (
      officerId,
      NEW.complaint_id,
      CONCAT('Pengaduan baru dengan judul "', NEW.judul, '" telah diajukan oleh warga.'),
      FALSE,
      NOW(),
      NOW()
    );
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `complaint_category`
--

CREATE TABLE `complaint_category` (
  `category_id` int(11) NOT NULL,
  `nama_kategori` varchar(100) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `complaint_category`
--

INSERT INTO `complaint_category` (`category_id`, `nama_kategori`, `deskripsi`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 'Infrastruktur', 'Pengaduan terkait kerusakan jalan, jembatan, trotoar, dan fasilitas umum lainnya.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(2, 'Kebersihan', 'Masalah sampah, saluran air tersumbat, dan kebersihan lingkungan.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(3, 'Penerangan Jalan', 'Lampu jalan rusak atau tidak menyala.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(4, 'Air dan Sanitasi', 'Keluhan mengenai air bersih, sanitasi buruk, atau saluran pembuangan.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(5, 'Pelayanan Publik', 'Pengaduan terhadap layanan administrasi, pelayanan kesehatan, atau pelayanan publik lainnya.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(6, 'Keamanan', 'Masalah keamanan lingkungan, tindakan kriminal, atau gangguan ketertiban umum.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(7, 'Transportasi Umum', 'Keluhan mengenai angkutan umum, halte, atau jadwal transportasi.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(8, 'Lingkungan Hidup', 'Polusi udara, pencemaran sungai, pembakaran liar, dan sejenisnya.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(9, 'Pendidikan', 'Masalah fasilitas sekolah, guru, atau layanan pendidikan lainnya.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0),
(10, 'Kesehatan', 'Fasilitas kesehatan, tenaga medis, atau pelayanan di puskesmas/rumah sakit.', '2025-04-09 17:47:25', '2025-04-09 17:47:25', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `complaint_comment`
--

CREATE TABLE `complaint_comment` (
  `comment_id` int(11) NOT NULL,
  `complaint_id` int(11) NOT NULL,
  `citizen_id` int(11) DEFAULT NULL,
  `officer_id` int(11) DEFAULT NULL,
  `comment_text` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ;

--
-- Dumping data for table `complaint_comment`
--

INSERT INTO `complaint_comment` (`comment_id`, `complaint_id`, `citizen_id`, `officer_id`, `comment_text`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, 1, NULL, 'Saya berharap laporan ini segera ditindaklanjuti.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(2, 2, NULL, 1, 'Laporan Anda sedang kami proses, mohon bersabar.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(3, 3, 2, NULL, 'Terima kasih telah merespons laporan saya.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(4, 4, NULL, 2, 'Kami telah mengirim petugas ke lokasi.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(5, 5, 3, NULL, 'Masalah ini sangat mengganggu aktivitas warga.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(6, 6, NULL, 3, 'Sudah dilakukan pengecekan awal, akan dilanjutkan.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(7, 7, 4, NULL, 'Apakah ada update terkait laporan ini?', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(8, 8, NULL, 4, 'Akan kami tindaklanjuti segera.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(9, 9, 5, NULL, 'Saya ingin laporan ini diproses lebih cepat.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0),
(10, 10, NULL, 5, 'Silakan lampirkan bukti tambahan jika ada.', '2025-04-09 17:51:49', '2025-04-09 17:51:49', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `log_activity`
--

CREATE TABLE `log_activity` (
  `log_id` int(11) NOT NULL,
  `citizen_id` int(11) DEFAULT NULL,
  `officer_id` int(11) DEFAULT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `aktivitas` varchar(255) NOT NULL,
  `deskripsi` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp()
) ;

--
-- Dumping data for table `log_activity`
--

INSERT INTO `log_activity` (`log_id`, `citizen_id`, `officer_id`, `admin_id`, `aktivitas`, `deskripsi`, `created_at`) VALUES
(1, 1, NULL, NULL, 'Login', 'Warga melakukan login ke sistem', '2025-04-13 20:00:35'),
(2, 2, NULL, NULL, 'Mengajukan Aduan', 'Warga mengajukan aduan tentang jalan berlubang di Jalan Merdeka', '2025-04-13 20:00:35'),
(3, 3, NULL, NULL, 'Mengedit Profil', 'Warga memperbarui informasi nomor telepon', '2025-04-13 20:00:35'),
(4, NULL, 1, NULL, 'Menanggapi Aduan', 'Petugas memberikan respon pada aduan #5', '2025-04-13 20:00:35'),
(5, NULL, 2, NULL, 'Login', 'Petugas berhasil login ke dashboard instansi', '2025-04-13 20:00:35'),
(6, NULL, 3, NULL, 'Memperbarui Status Aduan', 'Petugas mengubah status aduan #7 menjadi \"diproses\"', '2025-04-13 20:00:35'),
(7, NULL, NULL, 1, 'Login', 'Admin melakukan login ke sistem', '2025-04-13 20:00:35'),
(8, NULL, NULL, 2, 'Menambahkan Kategori', 'Admin menambahkan kategori baru: \"Lingkungan\"', '2025-04-13 20:00:35'),
(9, NULL, NULL, 3, 'Menghapus Komentar', 'Admin menghapus komentar pada aduan #9 karena mengandung SARA', '2025-04-13 20:00:35'),
(10, NULL, NULL, 1, 'Menonaktifkan Akun Citizen', 'Admin menonaktifkan akun milik citizen_id #4 karena pelanggaran aturan', '2025-04-13 20:00:35'),
(11, 1, NULL, NULL, 'Tambah Pengaduan', 'Warga menambahkan pengaduan dengan judul \"Lampu Jalan Mati\"', '2025-04-14 10:21:29');

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `notification_id` int(11) NOT NULL,
  `citizen_id` int(11) DEFAULT NULL,
  `officer_id` int(11) DEFAULT NULL,
  `complaint_id` int(11) NOT NULL,
  `pesan` text NOT NULL,
  `status_dibaca` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`notification_id`, `citizen_id`, `officer_id`, `complaint_id`, `pesan`, `status_dibaca`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, NULL, 1, 'Pengaduan Anda sedang kami proses.', 0, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(2, NULL, 1, 2, 'Anda mendapat pengaduan baru.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(3, 2, NULL, 3, 'Tanggapan telah diberikan untuk pengaduan Anda.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(4, NULL, 2, 4, 'Pengaduan baru telah ditugaskan kepada Anda.', 0, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(5, 3, NULL, 5, 'Pengaduan Anda sudah selesai ditangani.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(6, NULL, 3, 6, 'Ada pengaduan yang membutuhkan perhatian Anda.', 0, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(7, 4, NULL, 7, 'Status pengaduan Anda telah diperbarui.', 0, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(8, NULL, 4, 8, 'Pengaduan masuk terkait kebersihan kota.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(9, 5, NULL, 9, 'Kami telah menanggapi keluhan Anda.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(10, NULL, 5, 10, 'Tugas Anda dalam pengaduan telah selesai.', 1, '2025-04-09 17:50:23', '2025-04-09 17:50:23', NULL, 0),
(11, NULL, 1, 12, 'Pengaduan baru dengan judul \"Lampu Jalan Mati\" telah diajukan oleh warga.', 0, '2025-04-14 10:21:29', '2025-04-14 10:21:29', NULL, 0),
(12, 1, NULL, 1, 'Pengaduan Anda dengan judul \"Jalan Berlubang di Jalan Raya\" telah direspon oleh instansi.', 0, '2025-04-14 10:22:39', '2025-04-14 10:22:39', NULL, 0);

-- --------------------------------------------------------

--
-- Table structure for table `response`
--

CREATE TABLE `response` (
  `response_id` int(11) NOT NULL,
  `complaint_id` int(11) NOT NULL,
  `officer_id` int(11) NOT NULL,
  `deskripsi` text NOT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `deleted_at` datetime DEFAULT NULL,
  `is_deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `response`
--

INSERT INTO `response` (`response_id`, `complaint_id`, `officer_id`, `deskripsi`, `created_at`, `updated_at`, `deleted_at`, `is_deleted`) VALUES
(1, 1, 1, 'Kami telah mengirim tim ke lokasi untuk meninjau kondisi jalan.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(2, 2, 2, 'Petugas kebersihan akan dijadwalkan ke lokasi besok pagi.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(3, 3, 3, 'Lampu jalan akan diganti dalam minggu ini.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(4, 4, 4, 'Kami sedang menyelidiki penyebab gangguan air.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(5, 5, 5, 'Manajemen Puskesmas telah diberi teguran dan akan menambah tenaga medis.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(6, 6, 1, 'Perbaikan trotoar telah selesai dilakukan.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(7, 7, 2, 'Dinas Lingkungan Hidup telah mengambil sampel air untuk uji laboratorium.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(8, 8, 3, 'Halte akan diperbaiki oleh kontraktor minggu depan.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(9, 9, 4, 'Kami telah memasang tangki air sementara di sekolah.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(10, 10, 5, 'Permintaan obat telah diajukan ke gudang farmasi pusat.', '2025-04-09 17:49:16', '2025-04-09 17:49:16', NULL, 0),
(11, 1, 1, 'Petugas akan datang besok pagi untuk perbaikan.', '2025-04-14 10:22:39', '2025-04-14 10:22:39', NULL, 0);

--
-- Triggers `response`
--
DELIMITER $$
CREATE TRIGGER `trg_notify_citizen_response` AFTER INSERT ON `response` FOR EACH ROW BEGIN
  DECLARE citizenId INT;
  DECLARE judulPengaduan VARCHAR(255);

  SELECT citizen_id, judul INTO citizenId, judulPengaduan
  FROM complaint
  WHERE complaint_id = NEW.complaint_id;

  IF citizenId IS NOT NULL THEN
    INSERT INTO notification (
      citizen_id,
      complaint_id,
      pesan,
      status_dibaca,
      created_at,
      updated_at
    ) VALUES (
      citizenId,
      NEW.complaint_id,
      CONCAT('Pengaduan Anda dengan judul "', judulPengaduan, '" telah direspon oleh instansi.'),
      FALSE,
      NOW(),
      NOW()
    );
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_citizen_complaints`
-- (See below for the actual view)
--
CREATE TABLE `view_citizen_complaints` (
`complaint_id` int(11)
,`nama_warga` varchar(100)
,`nama_instansi` varchar(100)
,`nama_kategori` varchar(100)
,`judul` varchar(255)
,`deskripsi` text
,`status` enum('diajukan','diproses','selesai')
,`created_at` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_complaint_with_responses`
-- (See below for the actual view)
--
CREATE TABLE `view_complaint_with_responses` (
`complaint_id` int(11)
,`judul` varchar(255)
,`complaint_description` text
,`status` enum('diajukan','diproses','selesai')
,`response_id` int(11)
,`response_description` text
,`officer_name` varchar(100)
,`response_created_at` datetime
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `view_unread_notifications_citizen`
-- (See below for the actual view)
--
CREATE TABLE `view_unread_notifications_citizen` (
`notification_id` int(11)
,`citizen_id` int(11)
,`citizen_name` varchar(100)
,`complaint_id` int(11)
,`complaint_title` varchar(255)
,`pesan` text
,`created_at` datetime
);

-- --------------------------------------------------------

--
-- Structure for view `view_citizen_complaints`
--
DROP TABLE IF EXISTS `view_citizen_complaints`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_citizen_complaints`  AS SELECT `c`.`complaint_id` AS `complaint_id`, `ct`.`nama` AS `nama_warga`, `a`.`nama_instansi` AS `nama_instansi`, `cc`.`nama_kategori` AS `nama_kategori`, `c`.`judul` AS `judul`, `c`.`deskripsi` AS `deskripsi`, `c`.`status` AS `status`, `c`.`created_at` AS `created_at` FROM (((`complaint` `c` join `citizen` `ct` on(`c`.`citizen_id` = `ct`.`citizen_id`)) join `agency` `a` on(`c`.`agency_id` = `a`.`agency_id`)) join `complaint_category` `cc` on(`c`.`category_id` = `cc`.`category_id`)) WHERE `c`.`is_deleted` = 0 ;

-- --------------------------------------------------------

--
-- Structure for view `view_complaint_with_responses`
--
DROP TABLE IF EXISTS `view_complaint_with_responses`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_complaint_with_responses`  AS SELECT `c`.`complaint_id` AS `complaint_id`, `c`.`judul` AS `judul`, `c`.`deskripsi` AS `complaint_description`, `c`.`status` AS `status`, `r`.`response_id` AS `response_id`, `r`.`deskripsi` AS `response_description`, `o`.`nama` AS `officer_name`, `r`.`created_at` AS `response_created_at` FROM ((`complaint` `c` left join `response` `r` on(`c`.`complaint_id` = `r`.`complaint_id`)) left join `agency_officer` `o` on(`r`.`officer_id` = `o`.`officer_id`)) WHERE `c`.`is_deleted` = 0 ;

-- --------------------------------------------------------

--
-- Structure for view `view_unread_notifications_citizen`
--
DROP TABLE IF EXISTS `view_unread_notifications_citizen`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `view_unread_notifications_citizen`  AS SELECT `n`.`notification_id` AS `notification_id`, `n`.`citizen_id` AS `citizen_id`, `ct`.`nama` AS `citizen_name`, `n`.`complaint_id` AS `complaint_id`, `c`.`judul` AS `complaint_title`, `n`.`pesan` AS `pesan`, `n`.`created_at` AS `created_at` FROM ((`notification` `n` join `citizen` `ct` on(`n`.`citizen_id` = `ct`.`citizen_id`)) join `complaint` `c` on(`n`.`complaint_id` = `c`.`complaint_id`)) WHERE `n`.`status_dibaca` = 0 AND `n`.`is_deleted` = 0 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `agency`
--
ALTER TABLE `agency`
  ADD PRIMARY KEY (`agency_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `agency_officer`
--
ALTER TABLE `agency_officer`
  ADD PRIMARY KEY (`officer_id`),
  ADD UNIQUE KEY `unique_officer_email` (`email`),
  ADD KEY `fk_officer_agency` (`agency_id`);

--
-- Indexes for table `attachment`
--
ALTER TABLE `attachment`
  ADD PRIMARY KEY (`attachment_id`),
  ADD KEY `fk_attachment_complaint` (`complaint_id`);

--
-- Indexes for table `citizen`
--
ALTER TABLE `citizen`
  ADD PRIMARY KEY (`citizen_id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `complaint`
--
ALTER TABLE `complaint`
  ADD PRIMARY KEY (`complaint_id`),
  ADD KEY `fk_complaint_citizen` (`citizen_id`),
  ADD KEY `fk_complaint_agency` (`agency_id`),
  ADD KEY `fk_complaint_category` (`category_id`);

--
-- Indexes for table `complaint_category`
--
ALTER TABLE `complaint_category`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `complaint_comment`
--
ALTER TABLE `complaint_comment`
  ADD PRIMARY KEY (`comment_id`),
  ADD KEY `fk_comment_complaint` (`complaint_id`),
  ADD KEY `fk_comment_citizen` (`citizen_id`),
  ADD KEY `fk_comment_officer` (`officer_id`);

--
-- Indexes for table `log_activity`
--
ALTER TABLE `log_activity`
  ADD PRIMARY KEY (`log_id`),
  ADD KEY `fk_log_citizen` (`citizen_id`),
  ADD KEY `fk_log_officer` (`officer_id`),
  ADD KEY `fk_log_admin` (`admin_id`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`notification_id`),
  ADD KEY `fk_notification_complaint` (`complaint_id`),
  ADD KEY `fk_notification_citizen` (`citizen_id`),
  ADD KEY `fk_notification_officer` (`officer_id`);

--
-- Indexes for table `response`
--
ALTER TABLE `response`
  ADD PRIMARY KEY (`response_id`),
  ADD KEY `fk_response_complaint` (`complaint_id`),
  ADD KEY `fk_response_officer` (`officer_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin`
--
ALTER TABLE `admin`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `agency`
--
ALTER TABLE `agency`
  MODIFY `agency_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `agency_officer`
--
ALTER TABLE `agency_officer`
  MODIFY `officer_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `attachment`
--
ALTER TABLE `attachment`
  MODIFY `attachment_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `citizen`
--
ALTER TABLE `citizen`
  MODIFY `citizen_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `complaint`
--
ALTER TABLE `complaint`
  MODIFY `complaint_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `complaint_category`
--
ALTER TABLE `complaint_category`
  MODIFY `category_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `complaint_comment`
--
ALTER TABLE `complaint_comment`
  MODIFY `comment_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `log_activity`
--
ALTER TABLE `log_activity`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `notification_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `response`
--
ALTER TABLE `response`
  MODIFY `response_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `agency_officer`
--
ALTER TABLE `agency_officer`
  ADD CONSTRAINT `fk_officer_agency` FOREIGN KEY (`agency_id`) REFERENCES `agency` (`agency_id`);

--
-- Constraints for table `attachment`
--
ALTER TABLE `attachment`
  ADD CONSTRAINT `fk_attachment_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaint` (`complaint_id`);

--
-- Constraints for table `complaint`
--
ALTER TABLE `complaint`
  ADD CONSTRAINT `fk_complaint_agency` FOREIGN KEY (`agency_id`) REFERENCES `agency` (`agency_id`),
  ADD CONSTRAINT `fk_complaint_category` FOREIGN KEY (`category_id`) REFERENCES `complaint_category` (`category_id`),
  ADD CONSTRAINT `fk_complaint_citizen` FOREIGN KEY (`citizen_id`) REFERENCES `citizen` (`citizen_id`);

--
-- Constraints for table `complaint_comment`
--
ALTER TABLE `complaint_comment`
  ADD CONSTRAINT `fk_comment_citizen` FOREIGN KEY (`citizen_id`) REFERENCES `citizen` (`citizen_id`),
  ADD CONSTRAINT `fk_comment_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaint` (`complaint_id`),
  ADD CONSTRAINT `fk_comment_officer` FOREIGN KEY (`officer_id`) REFERENCES `agency_officer` (`officer_id`);

--
-- Constraints for table `log_activity`
--
ALTER TABLE `log_activity`
  ADD CONSTRAINT `fk_log_admin` FOREIGN KEY (`admin_id`) REFERENCES `admin` (`admin_id`),
  ADD CONSTRAINT `fk_log_citizen` FOREIGN KEY (`citizen_id`) REFERENCES `citizen` (`citizen_id`),
  ADD CONSTRAINT `fk_log_officer` FOREIGN KEY (`officer_id`) REFERENCES `agency_officer` (`officer_id`);

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `fk_notification_citizen` FOREIGN KEY (`citizen_id`) REFERENCES `citizen` (`citizen_id`),
  ADD CONSTRAINT `fk_notification_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaint` (`complaint_id`),
  ADD CONSTRAINT `fk_notification_officer` FOREIGN KEY (`officer_id`) REFERENCES `agency_officer` (`officer_id`);

--
-- Constraints for table `response`
--
ALTER TABLE `response`
  ADD CONSTRAINT `fk_response_complaint` FOREIGN KEY (`complaint_id`) REFERENCES `complaint` (`complaint_id`),
  ADD CONSTRAINT `fk_response_officer` FOREIGN KEY (`officer_id`) REFERENCES `agency_officer` (`officer_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
