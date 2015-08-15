DROP PROCEDURE IF EXISTS tpg_change;

-- This might be long - patience.

DELIMITER $$
CREATE PROCEDURE tpg_change()
BEGIN
	DECLARE done INT DEFAULT false;
	DECLARE _table CHAR(255);
	DECLARE _stmt VARCHAR(1000);
	DECLARE cur1 CURSOR FOR
	SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
	WHERE TABLE_SCHEMA = DATABASE()
	AND (TABLE_NAME LIKE "parts\_%" OR TABLE_NAME="parts");
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	OPEN cur1;
	myloop: loop FETCH cur1 INTO _table;
		IF done THEN LEAVE myloop; END IF;
		SET @sql1 := 
			CONCAT("ALTER TABLE ", _table,
			" DROP INDEX binaryid,
			DROP INDEX ix_parts_collection_id,
			DROP PRIMARY KEY,
			DROP COLUMN collection_id,
			DROP COLUMN id,
			ADD PRIMARY KEY(binaryid,number),
			MODIFY COLUMN partnumber mediumint(10) unsigned NOT NULL DEFAULT '0',
			MODIFY COLUMN size mediumint(10) unsigned NOT NULL DEFAULT '0'");
		PREPARE _stmt FROM @sql1; EXECUTE _stmt; DROP PREPARE _stmt;
	END loop;
	CLOSE cur1;
END $$
DELIMITER ;

CALL tpg_change();
DROP PROCEDURE tpg_change;

DROP TRIGGER IF EXISTS delete_collections;
