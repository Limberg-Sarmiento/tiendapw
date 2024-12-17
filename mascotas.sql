
CREATE DATABASE IF NOT EXISTS mascotas;
USE mascotas;

CREATE TABLE pet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20),
    owner VARCHAR(20),
    species VARCHAR(20),
    sex VARCHAR(20),
    birth DATE,
    death DATE
);
INSERT INTO pet (name, owner, species, sex, birth, death) VALUES
    ('Fluffy', 'Harold', 'cat', 'f', '1993-02-04', NULL),
    ('Claws', 'Gwen', 'cat', 'm', '1994-03-17', NULL),
    ('Buffy', 'Harold', 'dog', 'f', '1989-05-13', NULL),
    ('Fang', 'Benny', 'dog', 'm', '1990-08-27', NULL),
    ('Bowser', 'Diane', 'dog', 'm', '1979-08-31', '1995-07-29'),
    ('Chirpy', 'Gwen', 'bird', 'f', '1998-09-11', NULL),
    ('Whistler', 'Gwen', 'bird', NULL, '1997-12-09', NULL),
    ('Slim', 'Benny', 'snake', 'm', '1996-04-29', NULL),
    ('Luigi', 'Limberg', 'dog', 'm', '2010-04-29', NULL);