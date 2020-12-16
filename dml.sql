INSERT INTO institution
VALUES
('Dail', 'Leinster House', 'Joe Bloggs'),
('Seanad', 'Leinster House', 'Boe Jloggs'),
('European Parliament', 'Brussels Building', 'Donald Tusk'),
('Cork County Council', 'Cork City Hall', 'Arnold Parsimmons'),
('Dublin City Council', 'Dublin City Hall', 'Cian Walsh');

INSERT INTO constituency (name, pop)
VALUES
('Kerry', '50000'),
('Dublin', '1000000'),
('Cork', '500000'),
('Galway', '100000'),
('Limerick', '150000');

INSERT INTO election (constituency, institution)
VALUES
(1, 'Dail'),
(1, 'Seanad'),
(2, 'Dublin City Council'),
(3, 'Cork County Council'),
(4, 'European Parliament');

INSERT INTO polling_station
VALUES
('V23RW88', 'Aghatubrid NS'),
('A12BC34', 'Dublin City Hall'),
('X12RW43', 'Cork City Hall'),
('A43BC12', 'LimCity Secondary School'),
('A12DE54', 'Kerry County Hall'),
('D44HJ87', 'Galway College'),
('A22IM98', 'Blackrock College');

INSERT INTO station_register
VALUES
(1, 'V23RW88'),
(1, 'A12DE54'),
(2, 'A12BC34'),
(2, 'A22IM98'),
(3, 'X12RW43'),
(4, 'A43BC12'),
(5, 'D44HJ87');

INSERT INTO voter
VALUES
('1234567A', 'A', 'B', 'A12BC34'),
('1234567Z', 'A', 'B', 'A12BC34'),
('1234567B', 'B', 'C', 'A12BC34'),
('1234567C', 'D', 'E', 'A12BC34'),
('1234567D', 'F', 'G', 'X12RW43'),
('1234567E', 'H', 'I', 'X12RW43'),
('1234567F', 'J', 'K', 'A12DE54'),
('1234567G', 'L', 'M', 'A12DE54'),
('1234567H', 'N', 'O', 'V23RW88'),
('1234567I', 'Q', 'P', 'A12DE54'),
('1234567J', 'R', 'S', 'A22IM98'),
('1234567L', 'U', 'X', 'A22IM98'),
('1234567K', 'Y', 'V', 'V23RW88'),
('1234567M', 'Z', 'W', 'A22IM98'),
('1234567N', 'AA', 'BB', 'A22IM98'),
('1234567O', 'AB', 'BD', 'V23RW88'),
('1234567P', 'AC', 'BR', 'A43BC12'),
('1234567Q', 'AV', 'BQ', 'A43BC12'),
('1234567R', 'AG', 'BY', 'D44HJ87'),
('1234567S', 'AM', 'BY', 'D44HJ87');

INSERT INTO candidate (standing_election, fname, lname)
VALUES
(1, 'Cian', 'Walsh'),
(1, 'Andrew', 'Garfield'),
(1, 'James', 'Joyce'),
(2, 'Cian', 'Qalsh'),
(2, 'Randrew', 'Sarfield'),
(2, 'Matthew', 'Henry'),
(3, 'Spatthew', 'Menry'),
(3, 'Ondrow', 'Gorfald'),
(3, 'Kiera', 'Cullen'),
(4, 'Nessa', 'Walsh'),
(4, 'Cathal', 'Walsh'),
(4, 'Oscar', 'Wilde'),
(5, 'Ada', 'Lovelace'),
(5, 'George', 'Boole'),
(5, 'Robert', 'Emmet'),
(5, 'Martin', 'Emms'),
(5, 'Karl', 'Marx');

INSERT INTO vote
VALUES
('1234567O', 1, 1),
('1234567K', 1, 2),
('1234567H', 1, 2),
('1234567L', 3, 7),
('1234567M', 3, 7);
