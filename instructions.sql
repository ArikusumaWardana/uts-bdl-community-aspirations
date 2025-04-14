-- FUNCTION --

-- Function 1 --

DELIMITER ||

CREATE FUNCTION get_complaint_status(p_complaint_id INT)
RETURNS VARCHAR(20)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_status VARCHAR(20);

    SELECT status INTO v_status
    FROM complaint
    WHERE complaint_id = p_complaint_id;

    RETURN v_status;
END ||

DELIMITER ;

-- Use Function 1 --
SELECT get_complaint_status(1) AS complaint_status;


-- Function 2 --

DELIMITER ||

CREATE FUNCTION count_unread_notifications_by_citizen(citizenId INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE unread_count INT;
    SELECT COUNT(*) INTO unread_count
    FROM notification
    WHERE citizen_id = citizenId
      AND status_dibaca = FALSE
      AND is_deleted = FALSE;
    RETURN unread_count;
END ||

DELIMITER ;

-- Use Function 2 --
SELECT count_unread_notifications_by_citizen(1) AS unread_notifications_by_citizen;


-- Function 3 --
CREATE FUNCTION count_unread_notifications_by_officer(officerId INT)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE unread_count INT;
    SELECT COUNT(*) INTO unread_count
    FROM notification
    WHERE officer_id = officerId
      AND status_dibaca = FALSE
      AND is_deleted = FALSE;
    RETURN unread_count;
END;

-- Use Function 3 --
SELECT count_unread_notifications_by_officer(2) AS unread_notifications_by_officer;


-- VIEW --

-- View 1 --
CREATE VIEW view_citizen_complaints AS
SELECT
    c.complaint_id,
    ct.nama AS nama_warga,
    a.nama_instansi,
    cc.nama_kategori,
    c.judul,
    c.deskripsi,
    c.status,
    c.created_at
FROM complaint c
JOIN citizen ct ON c.citizen_id = ct.citizen_id
JOIN agency a ON c.agency_id = a.agency_id
JOIN complaint_category cc ON c.category_id = cc.category_id
WHERE c.is_deleted = FALSE;

-- Use View 1 --
SELECT * FROM view_citizen_complaints;


-- View 2 --




-- PROCEDURE --

-- Procedure 1 --
DELIMITER ||

CREATE PROCEDURE add_complaint (
    IN p_citizen_id INT,
    IN p_agency_id INT,
    IN p_category_id INT,
    IN p_judul VARCHAR(255),
    IN p_deskripsi TEXT
)
BEGIN
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
END ||

DELIMITER ;

-- Call Procedure 1 --
CALL add_complaint(
    1,
    2,
    3,
    'Jalan Rusak',
    'Jalan di depan rumah berlubang dan membahayakan.'
);

SELECT * FROM complaint;


-- Procedure 2 --
DELIMITER $$

CREATE PROCEDURE respond_to_complaint (
    IN p_complaint_id INT,
    IN p_officer_id INT,
    IN p_deskripsi TEXT
)
BEGIN
    DECLARE complaint_status ENUM('diajukan', 'diproses', 'selesai');

    -- Ambil status dari pengaduan
    SELECT status INTO complaint_status
    FROM complaint
    WHERE complaint_id = p_complaint_id AND is_deleted = FALSE;

    -- Jika pengaduan tidak ditemukan
    IF complaint_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengaduan tidak ditemukan atau telah dihapus.';

    -- Jika status sudah selesai, tidak boleh merespon lagi
    ELSEIF complaint_status = 'selesai' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Pengaduan sudah selesai, tidak bisa diberikan respon lagi.';

    -- Jika status valid, maka bisa melakukan insert
    ELSE
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

        -- Jika status masih berstatus diajukan, maka ubah status menjadi diproses
        IF complaint_status = 'diajukan' THEN
            UPDATE complaint
            SET status = 'diproses',
                updated_at = NOW()
            WHERE complaint_id = p_complaint_id;
        END IF;

    END IF;
END $$

DELIMITER ;

-- Call Procedure 2 --
CALL respond_to_complaint(
    1,
    2,
    'Kami sudah mengirim tim untuk survei ke lokasi.'
);


-- Procedure 3 --
DELIMITER ||

CREATE PROCEDURE soft_delete_complaint (
    IN p_complaint_id INT
)
BEGIN
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
END ||

DELIMITER ;



-- Call Procedure 3 --
CALL soft_delete_complaint(11);

SELECT * FROM complaint;