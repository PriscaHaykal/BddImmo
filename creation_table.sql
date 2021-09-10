CREATE TABLE region (
                code_region VARCHAR(2) NOT NULL,
                nom_region VARCHAR(30) NOT NULL,
                CONSTRAINT region_pk PRIMARY KEY (code_region)
);


CREATE TABLE departement (
                code_departement VARCHAR(5) NOT NULL,
                nom_departement VARCHAR(25) NOT NULL,
                code_region VARCHAR(2) NOT NULL,
                CONSTRAINT departement_pk PRIMARY KEY (code_departement)
);


CREATE TABLE commune (
                id INTEGER NOT NULL,
                nom_commune VARCHAR(40) NOT NULL,
                code_postal VARCHAR(5) NOT NULL,
                code_departement VARCHAR(5) NOT NULL,
                CONSTRAINT commune_pk PRIMARY KEY (id)
);


CREATE TABLE type_voie (
                id INTEGER NOT NULL,
                type_voie VARCHAR(10) NOT NULL ,
                CONSTRAINT type_voie_pk PRIMARY KEY (id)
);


CREATE TABLE type_local (
                id INTEGER NOT NULL,
                type_local VARCHAR(40) NOT NULL,
                CONSTRAINT type_local_pk PRIMARY KEY (id)
);


CREATE TABLE adresse (
                id INTEGER NOT NULL,
                no_voie VARCHAR(5),
                id_type_voie INTEGER NOT NULL,
                nom_voie VARCHAR(50) NOT NULL,
                id_commune INTEGER NOT NULL,
                CONSTRAINT adresse_pk PRIMARY KEY (id)
);


CREATE TABLE local1 (
                id INTEGER NOT NULL,
                nb_pieces INTEGER NOT NULL,
                surface_bati INTEGER NOT NULL,
                id_type_local INTEGER NOT NULL,
                id_adresse INTEGER NOT NULL,
                CONSTRAINT local_pk PRIMARY KEY (id)
);


CREATE TABLE mutation (
                id INTEGER NOT NULL,
                nature_mutation VARCHAR(50) NOT NULL,
                date_mutation DATE NOT NULL,
                valeur_fonciere FLOAT NOT NULL,
                id_local INTEGER NOT NULL,
                CONSTRAINT mutation_pk PRIMARY KEY (id)
);


ALTER TABLE departement ADD CONSTRAINT region_departement_fk
FOREIGN KEY (code_region)
REFERENCES region (code_region)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE commune ADD CONSTRAINT departement_commune_fk
FOREIGN KEY (code_departement)
REFERENCES departement (code_departement)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE adresse ADD CONSTRAINT commune_adresse_fk
FOREIGN KEY (id_commune)
REFERENCES commune (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE adresse ADD CONSTRAINT type_voie_adresse_fk
FOREIGN KEY (id_type_voie)
REFERENCES type_voie (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE local1 ADD CONSTRAINT type_local_local1_fk
FOREIGN KEY (id_type_local)
REFERENCES type_local (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE local1 ADD CONSTRAINT adresse_local1_fk
FOREIGN KEY (id_adresse)
REFERENCES adresse (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION;

ALTER TABLE mutation ADD CONSTRAINT local1_mutation_fk
FOREIGN KEY (id_local)
REFERENCES local1 (id)
ON DELETE NO ACTION
ON UPDATE NO ACTION;