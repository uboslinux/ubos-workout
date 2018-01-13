/*
 * Copyright (C) 2014 and later, Indie Computing Corp. All rights reserved. License: see package.
 */

CREATE TABLE `happenings` (
    ts    TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    event VARCHAR(1024)
);
INSERT INTO `happenings` ( event )
       VALUES            ( 'create.sql' );
