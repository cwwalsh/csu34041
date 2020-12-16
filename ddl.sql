CREATE DATABASE voting_system;
CREATE USER 'ec'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON voting_system TO 'ec'@'localhost' WITH GRANT OPTION;
GRANT CREATE USER, CREATE ROLE TO 'ec'@'localhost';
GRANT SUPER ON *.* TO 'ec'@'localhost';

CREATE TABLE institution (
                             name VARCHAR(24) NOT NULL,
                             building VARCHAR(24) NOT NULL,
                             chair VARCHAR(24) NOT NULL,
                             PRIMARY KEY (name)
);

CREATE TABLE constituency (
                              constituency_id INT NOT NULL AUTO_INCREMENT,
                              name VARCHAR(24) NOT NULL,
                              pop INT NOT NULL,
                              PRIMARY KEY (constituency_id)
);

CREATE TABLE election (
                          election_id INT NOT NULL AUTO_INCREMENT,
                          winning_cand INT,
                          constituency INT NOT NULL,
                          institution VARCHAR(24) NOT NULL,
                          PRIMARY KEY (election_id),
                          FOREIGN KEY (constituency) REFERENCES constituency(constituency_id)
                              ON DELETE CASCADE ON UPDATE CASCADE,
                          FOREIGN KEY (institution) REFERENCES institution(name)
                              ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE polling_station (
                                 eircode NCHAR(7) NOT NULL CHECK (eircode RLIKE '[A-Z][0-9]{2}[A-Z]{2}[0-9]{2}'),
                                 name VARCHAR(24) NOT NULL,
                                 PRIMARY KEY (eircode)
);

CREATE TABLE station_register (
                                  constituency INT NOT NULL,
                                  polling_station NCHAR(7) NOT NULL,
                                  PRIMARY KEY (constituency, polling_station),
                                  FOREIGN KEY (constituency) REFERENCES constituency(constituency_id)
                                      ON DELETE CASCADE ON UPDATE CASCADE,
                                  FOREIGN KEY (polling_station) REFERENCES polling_station(eircode)
                                      ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE candidate (
                           candidate_id INT NOT NULL AUTO_INCREMENT,
                           standing_election INT NOT NULL,
                           fname VARCHAR(8) NOT NULL,
                           lname VARCHAR(8) NOT NULL,
                           PRIMARY KEY (candidate_id),
                           FOREIGN KEY (standing_election) REFERENCES election(election_id)
                               ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE voter (
                       pps NCHAR(8) NOT NULL CHECK (pps RLIKE '[0-9]{6}[A-Z]'),
                       fname VARCHAR(8) NOT NULL,
                       lname VARCHAR(8) NOT NULL,
                       polling_station NCHAR(7) NOT NULL,
                       PRIMARY KEY (pps),
                       FOREIGN KEY (polling_station) REFERENCES polling_station(eircode)
                           ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE vote (
                      pps NCHAR(8) NOT NULL,
                      election INT NOT NULL,
                      voted_candidate INT NOT NULL,
                      PRIMARY KEY (pps, election),
                      FOREIGN KEY (pps) REFERENCES voter(pps)
                          ON UPDATE CASCADE ON DELETE CASCADE,
                      FOREIGN KEY (election) REFERENCES election(election_id)
                          ON UPDATE CASCADE ON DELETE CASCADE,
                      FOREIGN KEY (voted_candidate) REFERENCES candidate(candidate_id)
                          ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE FUNCTION check_voter_valid(v_id NCHAR(8), election INT)
    RETURNS BOOLEAN
    DETERMINISTIC
BEGIN
    DECLARE is_valid BOOLEAN;
    SET is_valid = IF(
            (v_id IN (
                SELECT v.pps FROM voter v
                                      INNER JOIN polling_station p ON v.polling_station = p.eircode
                                      INNER JOIN station_register sr ON p.eircode = sr.polling_station
                                      INNER JOIN constituency c on sr.constituency = c.constituency_id
                                      INNER JOIN election e on c.constituency_id = e.constituency
                WHERE e.election_id = election
            )),
            TRUE, FALSE);
    RETURN is_valid;
END;

CREATE FUNCTION check_candidate_valid(c_id INT, election INT)
    RETURNS BOOLEAN
    DETERMINISTIC
BEGIN
    DECLARE is_valid BOOLEAN;
    SET is_valid = IF(
            (c_id IN (
                SELECT candidate_id FROM candidate
                WHERE standing_election = election
            )),
            TRUE, FALSE);
    RETURN is_valid;
END;

CREATE FUNCTION check_vote_valid(c INT, v NCHAR(8), e INT)
    RETURNS BOOLEAN
    DETERMINISTIC
BEGIN
    DECLARE cand_valid BOOLEAN;
    DECLARE voter_valid BOOLEAN;
    DECLARE vote_valid BOOLEAN;
    SET cand_valid = check_candidate_valid(c, e);
    SET voter_valid = check_voter_valid(v, e);

    SET vote_valid = IF(cand_valid IS TRUE && voter_valid IS TRUE,  TRUE, FALSE);
    RETURN vote_valid;
END;


CREATE TRIGGER check_vote_insert_valid
    BEFORE INSERT ON vote FOR EACH ROW BEGIN
    DECLARE valid BOOLEAN;
    SET valid = check_vote_valid(NEW.voted_candidate, NEW.pps, NEW.election);
    IF (NOT VALID) THEN
        SIGNAL sqlstate '45000'
            SET MESSAGE_TEXT = 'Vote insert not valid!';
    END IF;
END;

CREATE TRIGGER check_vote_update_valid
    BEFORE UPDATE ON vote FOR EACH ROW BEGIN
    DECLARE valid BOOLEAN;
    SET valid = check_vote_valid(NEW.voted_candidate, NEW.pps, NEW.election);
    IF (NOT VALID) THEN
        SIGNAL sqlstate '45000'
            SET MESSAGE_TEXT = 'Vote update not valid!';
    END IF;
END;

CREATE PROCEDURE update_winning_cand(IN e INT) BEGIN
    DECLARE winner INT;
    SET winner = (SELECT voted_candidate FROM vote
                  WHERE election = e
                  GROUP BY voted_candidate
                  ORDER BY COUNT(voted_candidate)
                      DESC LIMIT 1);
    UPDATE election SET winning_cand = winner
    WHERE election_id = e;
END;


CREATE TRIGGER update_winning_cand_update
    AFTER UPDATE ON vote FOR EACH ROW
    CALL update_winning_cand(NEW.election);

CREATE TRIGGER update_winning_cand_insert
    AFTER INSERT ON vote FOR EACH ROW
    CALL update_winning_cand(NEW.election)