-- ---------------------------------------------------------------------------
-- Ledger protection (SPEC §9.4, §16): the application DB user must NOT be able
-- to UPDATE or DELETE rows of `inv_movement` and `common_audit_log`.
--
-- MySQL has no negative (deny) grants and partial revokes only work at the
-- database level, so "GRANT ALL ON wms.* ... REVOKE UPDATE ON wms.inv_movement"
-- is impossible. The pattern is therefore inverted:
--   * wms_app holds database-level SELECT, INSERT only            (01-users.sql)
--   * UPDATE, DELETE are granted PER TABLE for every table that is not a ledger
--
-- The tables do not exist at init time (EF Core migrations create them later),
-- so the logic lives in a stored procedure that is re-run after EVERY migration:
--   scripts/db-ledger-grants.sh  ->  deploy/mysql/post-migrate/ledger-grants.sql
--   k8s: deploy/k8s/base/job-migrator.yaml (container "ledger-grants")
--
-- The procedure lives in its own schema `wms_ops` (root-only) so the `wms`
-- schema stays fully owned by the migrator. Idempotent: safe to run any time.
-- ---------------------------------------------------------------------------

CREATE DATABASE IF NOT EXISTS `wms_ops`;

DROP PROCEDURE IF EXISTS `wms_ops`.`apply_ledger_grants`;

DELIMITER $$

CREATE PROCEDURE `wms_ops`.`apply_ledger_grants`()
    COMMENT 'Grants per-table UPDATE/DELETE to wms_app for all non-ledger tables in wms; ledger tables stay SELECT+INSERT only'
BEGIN
    DECLARE v_done       BOOLEAN     DEFAULT FALSE;
    DECLARE v_table      VARCHAR(64);
    DECLARE v_granted    INT         DEFAULT 0;
    DECLARE v_violations INT         DEFAULT 0;

    DECLARE cur CURSOR FOR
        SELECT TABLE_NAME
          FROM information_schema.TABLES
         WHERE TABLE_SCHEMA = 'wms'
           AND TABLE_TYPE   = 'BASE TABLE'
           AND TABLE_NAME NOT IN ('inv_movement', 'common_audit_log')
         ORDER BY TABLE_NAME;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = TRUE;

    -- 1) baseline (idempotent, mirrors 01-users.sql)
    GRANT SELECT, INSERT ON `wms`.* TO 'wms_app'@'%';

    -- 2) per-table UPDATE, DELETE for everything that is not an append-only ledger
    OPEN cur;
    grant_loop: LOOP
        FETCH cur INTO v_table;
        IF v_done THEN
            LEAVE grant_loop;
        END IF;
        SET @stmt = CONCAT('GRANT UPDATE, DELETE ON `wms`.`', v_table, '` TO ''wms_app''@''%''');
        PREPARE p FROM @stmt;
        EXECUTE p;
        DEALLOCATE PREPARE p;
        SET v_granted = v_granted + 1;
    END LOOP;
    CLOSE cur;

    -- 3) verify the invariant: no UPDATE/DELETE on the ledger tables
    SELECT COUNT(*) INTO v_violations
      FROM information_schema.TABLE_PRIVILEGES
     WHERE GRANTEE        = '''wms_app''@''%'''
       AND TABLE_SCHEMA   = 'wms'
       AND TABLE_NAME    IN ('inv_movement', 'common_audit_log')
       AND PRIVILEGE_TYPE IN ('UPDATE', 'DELETE');

    IF v_violations > 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'wms_app holds UPDATE/DELETE on a ledger table (inv_movement/common_audit_log) - revoke it manually';
    END IF;

    FLUSH PRIVILEGES;

    SELECT v_granted AS tables_with_update_delete,
           (SELECT COUNT(*) FROM information_schema.TABLES
             WHERE TABLE_SCHEMA = 'wms' AND TABLE_NAME IN ('inv_movement', 'common_audit_log')) AS ledger_tables_present;
END$$

DELIMITER ;
