CREATE VIEW registrar_view AS
SELECT v.pps, CONCAT(v.fname, ' ', v.lname) AS voter_name, ps.eircode, ps.name AS polling_station
FROM voter v
         INNER JOIN polling_station ps on v.polling_station = ps.eircode;

CREATE FUNCTION has_voter_voted(v NCHAR(8), e INT) RETURNS BOOLEAN
    DETERMINISTIC
BEGIN
    DECLARE voted BOOLEAN;
    SET voted = IF(v IN (SELECT pps FROM vote WHERE election = e), TRUE, FALSE);
    RETURN voted;
END
;


CREATE VIEW polling_official_view AS
SELECT e.election_id, v.pps, CONCAT(v.fname, ' ', v.lname) AS candidate_name,
       ps.eircode, ps.name AS polling_station, has_voter_voted(v.pps, e.election_id) AS voted
FROM voter v
         INNER JOIN polling_station ps on v.polling_station = ps.eircode
         INNER JOIN station_register sr on ps.eircode = sr.polling_station
         INNER JOIN constituency c on sr.constituency = c.constituency_id
         INNER JOIN election e on c.constituency_id = e.constituency;

CREATE VIEW returner_view AS
SELECT e.*, i.building, i.chair FROM election e
                         INNER JOIN institution i on e.institution = i.name;

CREATE VIEW voter_view AS
SELECT DISTINCT CONCAT(c.fname, ' ', c.lname) AS cand_name, e.election_id, ps.eircode, ps.name AS polling_station, co.name AS constituency
FROM candidate c
         INNER JOIN election e on c.standing_election = e.election_id
         INNER JOIN constituency co on e.constituency = co.constituency_id
         INNER JOIN station_register sr on co.constituency_id = sr.constituency
         INNER JOIN polling_station ps on sr.polling_station = ps.eircode
         INNER JOIN voter v on ps.eircode = v.polling_station;

CREATE ROLE registrar;
GRANT SELECT, UPDATE ON registrar_view TO registrar;
CREATE ROLE polling_official;
GRANT SELECT ON polling_official_view TO polling_official;
CREATE ROLE returner;
GRANT SELECT ON returner_view TO returner;
CREATE ROLE voter;
GRANT SELECT ON voter_view TO voter;
GRANT INSERT ON vote TO voter;
