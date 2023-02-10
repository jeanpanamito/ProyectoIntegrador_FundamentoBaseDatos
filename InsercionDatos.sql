USE bddfinal;
#-------------------Tabla Genre---------------------

DROP PROCEDURE IF EXISTS TablaGenre;

DELIMITER $$
CREATE PROCEDURE TablaGenre()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE nameGenre VARCHAR(100);

-- Declarar el cursor
DECLARE Cursorgenre CURSOR FOR
    SELECT DISTINCT CONVERT(REPLACE(REPLACE(genres, 'Science Fiction', 'Science-Fiction'),
        'TV Movie', 'TV-Movie') USING UTF8MB4) from bddfinal.movie_dataset;

-- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

-- Abrir el cursor
OPEN Cursorgenre;
drop table if exists temperolgenre;
    SET @sql_text = 'CREATE TABLE temperolgenre (name VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
CursorDirector_loop: LOOP
    FETCH Cursorgenre INTO nameGenre;

    -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorDirector_loop;
    END IF;

    -- Separar los géneros en una tabla temporal
    DROP TEMPORARY TABLE IF EXISTS temp_genres;
    CREATE TEMPORARY TABLE temp_genres (genre VARCHAR(50));
    SET @_genres = nameGenre;
    WHILE (LENGTH(@_genres) > 0) DO
        SET @_genre = TRIM(SUBSTRING_INDEX(@_genres, ' ', 1));
        INSERT INTO temp_genres (genre) VALUES (@_genre);
        SET @_genres = SUBSTRING(@_genres, LENGTH(@_genre) + 2);
    END WHILE;

    -- Insertar los géneros separados en filas individuales
    INSERT INTO temperolgenre (name)
    SELECT genre FROM temp_genres;
END LOOP CursorDirector_loop;

select distinct * from temperolgenre;
    INSERT INTO genre (genre.nameGenre)
    SELECT DISTINCT name
    FROM temperolgenre;
drop table if exists temperolgenre;

CLOSE Cursorgenre;
END $$
DELIMITER ;

CALL TablaGenre();
#------------------------------------------------------------------------------------
#-------------------Tabla Status---------------------
DROP PROCEDURE IF EXISTS TablaStatus;
DELIMITER $$
CREATE PROCEDURE TablaStatus()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE nameStatus VARCHAR(100);

 -- Declarar el cursor
DECLARE CursorStatus CURSOR FOR
    SELECT DISTINCT CONVERT(status USING UTF8MB4) AS names from bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorStatus;
CursorStatus_loop: LOOP
    FETCH CursorStatus INTO nameStatus;

-- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorStatus_loop;
    END IF;
    IF nameStatus IS NULL THEN
        SET nameStatus = '';
    END IF;
    SET @_oStatement = CONCAT('INSERT INTO Status (nameStatus) VALUES (\'',nameStatus,'\');');
    PREPARE sent1 FROM @_oStatement;
    EXECUTE sent1;
    DEALLOCATE PREPARE sent1;

END LOOP;
CLOSE CursorStatus;
END $$
DELIMITER ;
CALL TablaStatus();
#------------------------------------------------------------------------------------

#-------------------Tabla OriLanguage---------------------
DROP PROCEDURE IF EXISTS TablaOriLanguage;
DELIMITER $$
CREATE PROCEDURE TablaOriLanguage()
BEGIN
DECLARE done INT DEFAULT FALSE;
DECLARE originalLanguage VARCHAR(2);
 -- Declarar el cursor
DECLARE CursorStatus CURSOR FOR
    SELECT DISTINCT CONVERT(original_language USING UTF8MB4) AS languages from bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorStatus;
CursorStatus_loop: LOOP
    FETCH CursorStatus INTO originalLanguage;

-- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorStatus_loop;
    END IF;
    IF originalLanguage IS NULL THEN
        SET originalLanguage = '';
    END IF;
    SET @_oStatement = CONCAT('INSERT INTO original_language (name_original_language) VALUES (\'',originalLanguage,'\');');
    PREPARE sent1 FROM @_oStatement;
    EXECUTE sent1;
    DEALLOCATE PREPARE sent1;
END LOOP;
CLOSE CursorStatus;
END $$
DELIMITER ;

CALL TablaOriLanguage();

#------------------------------------------------------------------------------------

#-------------------Tabla Movie-------------------
DROP PROCEDURE IF EXISTS TablaMovie;

DELIMITER $$
CREATE PROCEDURE TablaMovie()
BEGIN

DECLARE done INT DEFAULT FALSE;

DECLARE Mov_idMovie INT;
DECLARE Mov_index INT;
DECLARE Mov_budget BIGINT;
DECLARE Mov_homepage VARCHAR(255);
DECLARE Mov_keywords VARCHAR(255);
DECLARE Mov_name_original_language VARCHAR(2);
DECLARE Mov_original_title VARCHAR(255);
DECLARE Mov_overview TEXT;
DECLARE Mov_popularity DOUBLE;
DECLARE Mov_release_date DATE;
DECLARE Mov_revenue BIGINT;
DECLARE Mov_runtime DOUBLE;
DECLARE Mov_nameStatus VARCHAR(15);
DECLARE Mov_tagline VARCHAR(255);
DECLARE Mov_title VARCHAR(255);
DECLARE Mov_vote_average DOUBLE;
DECLARE Mov_vote_count INT;

DECLARE Status_idStatus int;
DECLARE OL_idOriginal_language int;

 -- Declarar el cursor
DECLARE CursorMovie CURSOR FOR
    SELECT id,`index`,budget,homepage, keywords, original_language, original_title, overview,
           popularity, release_date, revenue, runtime, `status`, tagline, title,
           vote_average, vote_count FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

 -- Abrir el cursor
OPEN CursorMovie;
CursorMovie_loop: LOOP
    FETCH CursorMovie INTO Mov_idMovie,Mov_index,Mov_budget, Mov_homepage, Mov_keywords,Mov_name_original_language,
        Mov_original_title, Mov_overview, Mov_popularity, Mov_release_date, Mov_revenue, Mov_runtime,
        Mov_nameStatus, Mov_tagline, Mov_title, Mov_vote_average, Mov_vote_count;

    -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorMovie_loop;
    END IF;

    SELECT `idStatus` INTO Status_idStatus
                      FROM Status WHERE nameStatus = Mov_nameStatus;
    SELECT `idOringLang` INTO OL_idOriginal_language
                         FROM original_language WHERE name_original_language = Mov_name_original_language;

    INSERT INTO Movie (`idMovie`,`index`,budget,homepage,keywords,idOrigLang,original_title,
                       overview,popularity,release_date,revenue,runtime, idStatus,
		                tagline,title,vote_average,vote_count)
    VALUES (Mov_idMovie,Mov_index,Mov_budget, Mov_homepage, Mov_keywords,OL_idOriginal_language,
        Mov_original_title, Mov_overview, Mov_popularity, Mov_release_date, Mov_revenue, Mov_runtime,
        Status_idStatus, Mov_tagline, Mov_title, Mov_vote_average, Mov_vote_count);

END LOOP;
CLOSE CursorMovie;
END $$
DELIMITER ;

CALL TablaMovie ();

#-------------------Tabla Production Companies-------------------
DROP PROCEDURE IF EXISTS TablaProduction_companies;

DELIMITER $$
CREATE PROCEDURE TablaProduction_companies ()

BEGIN

 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(production_companies USING UTF8MB4), '$[*]') FROM bddfinal.movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists production_companietem;
    SET @sql_text = 'CREATE TABLE production_companieTem ( id int, nameCom VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO

  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].id')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO production_companieTem VALUES (', REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;

 select distinct * from production_companieTem;
    INSERT INTO production_companies
    SELECT DISTINCT id, nameCom
    FROM production_companieTem;
    drop table if exists production_companieTem;
 CLOSE myCursor ;

END$$
DELIMITER ;

CALL TablaProduction_companies();

#-------------------Tabla Production Countries-------------------
DROP PROCEDURE IF EXISTS TablaProduction_countries;
DELIMITER $$
CREATE PROCEDURE TablaProduction_countries ()

BEGIN

 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(production_countries USING UTF8MB4), '$[*]') FROM bddfinal.movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists production_companietem;
    SET @sql_text = 'CREATE TABLE production_countrieTem ( id VARCHAR(100), nameCom VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO

  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].iso_3166_1')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO production_countrieTem VALUES (', REPLACE(jsonId,'\'',''), ', ', jsonLabel, '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;

 select distinct * from production_countrieTem;
    INSERT INTO production_countries
    SELECT DISTINCT id, nameCom
    FROM production_countrieTem;
    drop table if exists production_countrieTem;
 CLOSE myCursor ;

END$$
DELIMITER ;

CALL TablaProduction_countries();
#-------------------Tabla Spoken Language-------------------

DROP PROCEDURE IF EXISTS TablaSpoken_Languages ;
DELIMITER $$
CREATE PROCEDURE TablaSpoken_Languages ()
BEGIN
 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId varchar(250) ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(spoken_languages USING UTF8), '$[*]') FROM bddfinal.movie_dataset ;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;
 drop table if exists spokenlanguageTem;
    SET @sql_text = 'CREATE TABLE spokenlanguageTem ( iso VARCHAR(5), nameLang VARCHAR(100));';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH myCursor INTO jsonData;

   -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL ) DO

  SET jsonId = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i ,'].iso_639_1')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT (jsonData, CONCAT('$[', i ,'].name')), '') ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO spokenlanguageTem VALUES (', jsonId, ', ', jsonLabel, '); ');
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END WHILE;

END LOOP;

  select distinct * from spokenlanguageTem;
    INSERT INTO spoken_language
    SELECT DISTINCT iso, nameLang
    FROM spokenlanguageTem;
    drop table if exists spokenlanguageTem;
 CLOSE myCursor ;

END;
DELIMITER $$;
CALL TablaSpoken_Languages ();

#-------------------Tabla Relacion Movies-Companies-------------------

DROP PROCEDURE IF EXISTS TablaMovie_production_companies;

DELIMITER $$
CREATE PROCEDURE TablaMovie_production_companies ()

BEGIN

 DECLARE done INT DEFAULT FALSE;
 DECLARE idMovie int;
 DECLARE idProdComp JSON;
 DECLARE idJSON text;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT id, production_companies FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;

 drop table if exists MovieProdCompTemp;
    SET @sql_text = 'CREATE TABLE MovieProdCompTemp ( id int, idGenre int );';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

 cursorLoop: LOOP

     FETCH myCursor INTO idMovie, idProdComp;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(idProdComp, CONCAT('$[', i, '].id')) IS NOT NULL) DO

  SET idJSON = JSON_EXTRACT(idProdComp,  CONCAT('$[', i, '].id')) ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO MovieProdCompTemp VALUES (', idMovie, ', ', REPLACE(idJSON,'\'',''), '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;

 select distinct * from MovieProdCompTemp;
    INSERT INTO Movie_production_companies
    SELECT DISTINCT id, idGenre
    FROM MovieProdCompTemp;
    drop table if exists MovieProdCompTemp;
 CLOSE myCursor ;

END$$
DELIMITER ;

call TablaMovie_production_companies();

#-------------------Tabla Relacion Movies-Countries-------------------
DROP PROCEDURE IF EXISTS TablaMovie_production_countries;

DELIMITER $$
CREATE PROCEDURE TablaMovie_production_countries ()

BEGIN

 DECLARE done INT DEFAULT FALSE;
 DECLARE idMovie int;
 DECLARE idProdCoun text;
 DECLARE idJSON text;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT id, production_countries FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;

 drop table if exists MovieProdCompTemp;

    SET @sql_text = 'CREATE TABLE MovieProdCountrTemp ( id int, prodCountr varchar(255) );';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

 cursorLoop: LOOP

     FETCH myCursor INTO idMovie, idProdCoun;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(idProdCoun, CONCAT('$[', i, '].iso_3166_1')) IS NOT NULL) DO

  SET idJSON = JSON_EXTRACT(idProdCoun,  CONCAT('$[', i, '].iso_3166_1')) ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO MovieProdCountrTemp VALUES (', idMovie, ', ', REPLACE(idJSON,'\'',''), '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;

 select distinct * from MovieProdCountrTemp;
    INSERT INTO movie_production_countries
    SELECT DISTINCT id, prodCountr
    FROM MovieProdCountrTemp;
    drop table if exists MovieProdCountrTemp;
 CLOSE myCursor ;

END$$
DELIMITER ;

call TablaMovie_production_countries();
#-------------------Tabla Relacion Movies-Languages-------------------
DROP PROCEDURE IF EXISTS TablaMovie_spoken_languages;

DELIMITER $$
CREATE PROCEDURE TablaMovie_spoken_languages ()

BEGIN

 DECLARE done INT DEFAULT FALSE;
 DECLARE idMovie int;
 DECLARE idSpokLang text;
 DECLARE idJSON text;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT id, spoken_languages FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;

  drop table if exists MovieProdCompTemp;

    SET @sql_text = 'CREATE TABLE MovieSpokenLanguagesTemp ( id int, spokenLang varchar(255) );';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

 cursorLoop: LOOP

     FETCH myCursor INTO idMovie, idSpokLang;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(idSpokLang, CONCAT('$[', i, '].iso_639_1')) IS NOT NULL) DO

  SET idJSON = JSON_EXTRACT(idSpokLang,  CONCAT('$[', i, '].iso_639_1')) ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO MovieSpokenLanguagesTemp VALUES (', idMovie, ', ', REPLACE(idJSON,'\'',''), '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;

 select distinct * from MovieSpokenLanguagesTemp;
    INSERT INTO movie_spoken_languages
    SELECT DISTINCT id, spokenLang
    FROM MovieSpokenLanguagesTemp;
    drop table if exists MovieSpokenLanguagesTemp;
 CLOSE myCursor ;

END$$
DELIMITER ;

call TablaMovie_spoken_languages();


#----------------------------------------------------------------------------------------------------------------------
#----------------------------------------------Tabla Persona-----------------------------------------------
DROP PROCEDURE IF EXISTS TablaPersona;

DELIMITER $$
CREATE PROCEDURE TablaPersona ()
BEGIN
 DECLARE done INT DEFAULT FALSE ;
 DECLARE jsonData json ;
 DECLARE jsonId INT ;
 DECLARE jsonLabel varchar(250) ;
 DECLARE jsongenre VARCHAR(250);
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE CursorPerson
  CURSOR FOR
   SELECT JSON_EXTRACT(CONVERT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
       (REPLACE(crew, '"', '\''), '{\'', '{"'),
    '\': \'', '": "'),'\', \'', '", "'),'\': ', '": '),', \'', ', "')
    USING UTF8mb4 ), '$[*]') FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN CursorPerson  ;
 drop table if exists personTem;
    SET @sql_text = 'CREATE TABLE personTem ( idcrew int, name VARCHAR(255), gender int);';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
 cursorLoop: LOOP
  FETCH CursorPerson INTO jsonData;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(jsonData, CONCAT('$[', i, ']')) IS NOT NULL) DO
  SET jsonId = IFNULL(JSON_EXTRACT(jsonData,  CONCAT('$[', i, '].id')), '') ;
  SET jsonLabel = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].name')), '') ;
  SET jsongenre = IFNULL(JSON_EXTRACT(jsonData, CONCAT('$[', i,'].gender')), '') ;
  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO personTem VALUES (', REPLACE(jsonId,'\'',''),', ',
      jsonLabel,',', REPLACE(jsongenre,'\'',''), ');');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;
 END LOOP ;
 select distinct * from personTem;
    INSERT IGNORE INTO Persona
    SELECT DISTINCT idcrew, name, gender
    FROM personTem;
    drop table if exists personTem;
 CLOSE CursorPerson ;
END$$
DELIMITER ;

CALL TablaPersona();
#----------------------------------------------Tabla Crew-----------------------------------------------
DROP PROCEDURE IF EXISTS TablaCrew;

DELIMITER $$
CREATE PROCEDURE TablaCrew ()

BEGIN

 DECLARE done INT DEFAULT FALSE;
 DECLARE idMovie int;
 DECLARE idCrew text;
 DECLARE idJSON text;
 DECLARE jobJSON text;
 DECLARE departmentJSON text;
 DECLARE credit_idJSON text;
 DECLARE i INT;

 -- Declarar el cursor
 DECLARE myCursor
  CURSOR FOR
   SELECT id, CONVERT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
       (REPLACE(crew, '"', '\''), '{\'', '{"'),
    '\': \'', '": "'),'\', \'', '", "'),'\': ', '": '),', \'', ', "')
    USING UTF8mb4 ) FROM bddfinal.movie_dataset;

 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
 DECLARE CONTINUE HANDLER
  FOR NOT FOUND SET done = TRUE ;

 -- Abrir el cursor
 OPEN myCursor  ;

 cursorLoop: LOOP

     FETCH myCursor INTO idMovie, idCrew;

  -- Controlador para buscar cada uno de los arrays
    SET i = 0;

  -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
  IF done THEN
   LEAVE  cursorLoop ;
  END IF ;

  WHILE(JSON_EXTRACT(idCrew, CONCAT('$[', i, '].id')) IS NOT NULL) DO

  SET idJSON = JSON_EXTRACT(idCrew,  CONCAT('$[', i, '].id')) ;
  SET jobJSON = JSON_EXTRACT(idCrew,  CONCAT('$[', i, '].job')) ;
  SET departmentJSON = JSON_EXTRACT(idCrew,  CONCAT('$[', i, '].department')) ;
  SET credit_idJSON = JSON_EXTRACT(idCrew,  CONCAT('$[', i, '].credit_id')) ;

  SET i = i + 1;

  SET @sql_text = CONCAT('INSERT INTO Crew VALUES (', idMovie, ', ', REPLACE(idJSON,'\'',''), ', ', REPLACE(jobJSON,'\'',''), ', ', REPLACE(departmentJSON,'\'',''), ', ', REPLACE(credit_idJSON,'\'',''), '); ');
	PREPARE stmt FROM @sql_text;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

  END WHILE;

 END LOOP ;
 CLOSE myCursor ;

END$$
DELIMITER ;

call TablaCrew();

#----------------------------------------------Tabla Director-----------------------------------------------

DROP PROCEDURE IF EXISTS TablaDirector;

DELIMITER $$
CREATE PROCEDURE TablaDirector()
BEGIN
DECLARE done INT DEFAULT FALSE ;
DECLARE idPersonas INT;
DECLARE Movid INT;
DECLARE MovDirector VARCHAR(100);

 -- Declarar el cursor
DECLARE CursorDirector CURSOR FOR
    SELECT id,director FROM movie_dataset;
 -- Declarar el handler para NOT FOUND (esto es marcar cuando el cursor ha llegado a su fin)
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
 -- Abrir el cursor
OPEN CursorDirector;
drop table if exists directorTemp;
    SET @sql_text = 'CREATE TABLE directorTemp ( idPer int,
    idMov int);';
    PREPARE stmt FROM @sql_text;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
CursorMovie_loop: LOOP
    FETCH CursorDirector INTO Movid,MovDirector;
      -- Si alcanzo el final del cursor entonces salir del ciclo repetitivo
    IF done THEN
        LEAVE CursorMovie_loop;
    END IF;
    SELECT MAX(idPerson) INTO idPersonas FROM Persona WHERE Persona.name=MovDirector;
    If idPersonas IS NOT NULL THEN
    INSERT INTO directorTemp VALUES (idPersonas,Movid);
    END IF;
    END LOOP;
CLOSE CursorDirector;
select distinct * from directorTemp;
INSERT INTO Director
    SELECT DISTINCT idMov, idPer
    FROM directorTemp;
drop table if exists directorTemp;
END $$
DELIMITER ;

CALL TablaDirector();
