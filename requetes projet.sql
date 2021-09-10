-- 1. Nombre total d’appartements vendus au 1er semestre 2020. 

SELECT COUNT(*) AS nombre_appartement_vendu_2020 FROM mutation
JOIN local1 ON mutation.id_local = local1.id
JOIN type_local ON type_local.id = local1.id_type_local
WHERE date_mutation BETWEEN '2020-01-01' AND '2020-06-30'
AND nature_mutation = 'Vente'
AND type_local = 'Appartement';

-- 2. Proportion des ventes d’appartements par le nombre de pièces.*

SELECT local1.nb_pieces AS nombre_de_pieces, CAST((COUNT(*)/ (SELECT COUNT(*) FROM mutation 
																										JOIN local1 ON local1.id = mutation.id_local 
																										JOIN type_local ON type_local.id = local1.id_type_local
																										WHERE type_local = 'Appartement'))*100 AS DECIMAL(6,4)) AS Proportion_ventes_appart  
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
WHERE type_local = 'Appartement'
AND nature_mutation = 'Vente'
GROUP BY local1.nb_pieces;

-- 3. Liste des 10 départements où le prix du mètre carré est le plus élevé.
SELECT nom_departement,departement.code_departement, CAST(AVG(valeur_fonciere/surface_bati) AS DECIMAL (8,2)) AS prix_du_metre_carre 
FROM mutation 
JOIN local1 ON local1.id = mutation.id_local 
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
JOIN departement ON departement.code_departement = commune.code_departement 
WHERE surface_bati > 0
AND departement.code_departement NOTNULL
AND valeur_fonciere > 0
GROUP BY nom_departement, departement.code_departement
ORDER BY AVG(valeur_fonciere/surface_bati)  DESC 
LIMIT 10 ; 

-- 4. Prix moyen du mètre carré d’une maison en Île-de-France.

SELECT CAST(AVG(valeur_fonciere/surface_bati) AS DECIMAL(6,2)) AS prix_moyen_metre_carre_iledefrance FROM mutation
JOIN local1 ON mutation.id_local = local1.id
JOIN type_local ON type_local.id = local1.id_type_local
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune
JOIN departement ON departement.code_departement = commune.code_departement 
JOIN region ON region.code_region = departement.code_region
WHERE type_local = 'Maison'
AND surface_bati > 0
AND valeur_fonciere > 0
AND nom_region = 'île-de-France';

-- 5. Liste des 10 appartements les plus chers avec le département et le nombre de mètres carrés.

SELECT valeur_fonciere AS prix_appartement, nom_departement, surface_bati AS nb_metres_carres
FROM mutation  
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
JOIN departement ON departement.code_departement = commune.code_departement 
WHERE type_local = 'Appartement'
AND valeur_fonciere > 0
ORDER BY valeur_fonciere DESC 
LIMIT 10 ; 

-- 6. Taux d’évolution du nombre de ventes entre le premier et le deuxième trimestres de 2020.


WITH 

table1 AS
(SELECT COUNT(*) AS nb1 FROM mutation 
WHERE date_mutation BETWEEN '2020-01-01' AND '2020-03-31'), 

 table2 AS
(SELECT COUNT(*) AS nb2 FROM mutation 
WHERE date_mutation BETWEEN '2020-04-01' AND '2020-06-30')

 SELECT nb1 AS nb_ventes_1er_trimestre, nb2 AS nb_ventes_2nd_trimestre,((nb2-nb1)/nb1*100) AS taux_devolution
 FROM table1, table2
 WHERE nb1 >0;

-- 7. Liste des communes où le taux d’évolution des ventes est supérieur à 20 % entre le premier et le second semestres de 2020.

WITH 
table1 AS 
(SELECT COUNT(*) as nb1, commune.id as commune
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
WHERE date_mutation  BETWEEN '2020-01-01' AND '2020-06-30'
GROUP BY commune.id),

table2 AS 
(SELECT COUNT(*) as nb2, commune.id as commune
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
WHERE date_mutation  BETWEEN '2020-07-01' AND '2020-12-31'
GROUP BY commune.id)


SELECT nb1, nb2, table1.commune, ((nb2-nb1)/nb1)*100 AS taux_devolution  FROM table1
JOIN table2 ON table1.commune = table2.commune
WHERE  ((nb2-nb1)/nb1)*100>0
AND nb1 >0
ORDER BY table1.commune;

-- 8. Différence en pourcentage du prix au mètre carré entre un appartement de 2 pièces et un appartement de 3 pièces.


WITH 

table1 AS 
(SELECT AVG(valeur_fonciere/surface_bati) AS prix2
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
WHERE type_local = 'Appartement'
AND nb_pieces = 2
AND surface_bati >0
AND valeur_fonciere>0),

table2 AS 
(SELECT AVG(valeur_fonciere/surface_bati) AS prix3
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
WHERE type_local = 'Appartement'
AND nb_pieces = 3
AND surface_bati >0
AND valeur_fonciere>0)

SELECT CAST(prix2 AS DECIMAL(6,2)) AS prix_2_pieces, CAST(prix3 AS DECIMAL(6,2)) AS prix_3_pieces,
			CAST( (prix3-prix2)/prix2*100 AS DECIMAL(6,2)) AS difference
FROM table1, table2
WHERE prix2>0;

-- 9. Taux d’appartements qui ont été vendus à un prix du mètre carré deux fois plus élevé que le prix du mètre carré moyen du département.

WITH 
table1 AS
(SELECT AVG(valeur_fonciere/surface_bati) AS prix_moyen_departement, departement.code_departement AS departement
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
JOIN departement ON departement.code_departement = commune.code_departement 
WHERE type_local = 'Appartement'
AND surface_bati >0
AND valeur_fonciere>0
GROUP BY departement.code_departement),

table2 AS 
(SELECT valeur_fonciere/surface_bati AS prix, departement.code_departement AS departement
FROM mutation
JOIN local1 ON local1.id = mutation.id_local 
JOIN type_local ON type_local.id = local1.id_type_local
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
JOIN departement ON departement.code_departement = commune.code_departement 
WHERE type_local = 'Appartement'
AND surface_bati >0
AND valeur_fonciere>0)

SELECT  (COUNT(*)/(SELECT COUNT(*) FROM table2))*100 AS taux FROM table2
LEFT JOIN table1 ON table2.departement = table1.departement
WHERE prix>(prix_moyen_departement*2);

-- 10. Donnez les moyennes de valeurs foncières pour le top 20 des communes.

SELECT CAST(AVG(valeur_fonciere) AS DECIMAL(10,2)), commune.id, commune.code_postal, commune.nom_commune
FROM mutation 
JOIN local1 ON local1.id = mutation.id_local 
JOIN adresse ON adresse.id = local1.id_adresse 
JOIN commune ON commune.id = adresse.id_commune 
WHERE valeur_fonciere >0
GROUP BY commune.id, commune.code_postal, commune.nom_commune
ORDER BY AVG(valeur_fonciere) DESC 
LIMIT 20; 