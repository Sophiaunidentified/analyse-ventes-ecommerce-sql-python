
-- =========================================================
-- PROJET : ANALYSE DES VENTES E-COMMERCE
-- Outils : PostgreSQL / pgAdmin
-- Période : décembre 2009 - décembre 2011
--
-- Les deux tables sources doivent déjà être importées :
-- retail_09_10 et retail_10_11
-- =========================================================


-- =========================================================
-- 1. EXPLORATION ET QUALITÉ DES DONNÉES
-- =========================================================

-- Vérification des données 2009-2010

SELECT
    COUNT(*) AS total_lignes,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL OR TRIM(customer_id) = ''
    ) AS clients_manquants,
    COUNT(*) FILTER (
        WHERE description IS NULL OR TRIM(description) = ''
    ) AS descriptions_manquantes,
    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS quantites_non_positives,
    COUNT(*) FILTER (
        WHERE price <= 0
    ) AS prix_non_positifs
FROM retail_09_10;


-- Vérification des données 2010-2011

SELECT
    COUNT(*) AS total_lignes,
    COUNT(*) FILTER (
        WHERE customer_id IS NULL OR TRIM(customer_id) = ''
    ) AS clients_manquants,
    COUNT(*) FILTER (
        WHERE description IS NULL OR TRIM(description) = ''
    ) AS descriptions_manquantes,
    COUNT(*) FILTER (
        WHERE quantity <= 0
    ) AS quantites_non_positives,
    COUNT(*) FILTER (
        WHERE price <= 0
    ) AS prix_non_positifs
FROM retail_10_11;


-- Vérification des factures d'annulation

SELECT
    COUNT(*) AS total_annulations,
    COUNT(*) FILTER (
        WHERE quantity < 0
    ) AS annulations_quantite_negative
FROM retail_10_11
WHERE invoice LIKE 'C%';


-- Vérification des périodes couvertes par les fichiers
-- Les dates sont au format MM/DD/YYYY HH24:MI

SELECT
    '2009-2010' AS periode,
    MIN(TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI')) AS premiere_vente,
    MAX(TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI')) AS derniere_vente
FROM retail_09_10

UNION ALL

SELECT
    '2010-2011' AS periode,
    MIN(TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI')) AS premiere_vente,
    MAX(TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI')) AS derniere_vente
FROM retail_10_11;


-- =========================================================
-- 2. TRAITEMENT DU CHEVAUCHEMENT ENTRE LES FICHIERS
-- =========================================================

-- Les deux fichiers contiennent des lignes communes.
-- INTERSECT ALL permet de compter les occurrences identiques.

SELECT COUNT(*) AS lignes_communes
FROM (
    SELECT *
    FROM retail_09_10

    INTERSECT ALL

    SELECT *
    FROM retail_10_11
) AS doublons;


-- Création d'une vue réunissant les deux fichiers.
-- EXCEPT ALL retire du deuxième fichier les occurrences
-- déjà présentes dans le premier, sans supprimer
-- les répétitions internes aux fichiers.

CREATE OR REPLACE VIEW retail_sans_chevauchement AS

SELECT *
FROM retail_09_10

UNION ALL

SELECT *
FROM (
    SELECT *
    FROM retail_10_11

    EXCEPT ALL

    SELECT *
    FROM retail_09_10
) AS nouvelles_lignes;


-- Vérification du nombre de lignes après traitement

SELECT COUNT(*) AS total_lignes
FROM retail_sans_chevauchement;


-- =========================================================
-- 3. CRÉATION DE LA VUE DES VENTES FINALES
-- =========================================================

-- Conservation des ventes avec :
-- - une quantité positive
-- - un prix positif
-- - une facture ne commençant pas par C
--
-- Le chiffre d'affaires est calculé par ligne.

CREATE OR REPLACE VIEW ventes_finales AS

SELECT
    invoice,
    stockcode,
    description,
    quantity,
    price,
    customer_id,
    country,
    invoicedate,
    quantity * price AS chiffre_affaires
FROM retail_sans_chevauchement
WHERE quantity > 0
  AND price > 0
  AND invoice NOT LIKE 'C%';


-- =========================================================
-- 4. INDICATEURS GLOBAUX
-- =========================================================

SELECT
    COUNT(*) AS nombre_lignes,
    ROUND(SUM(chiffre_affaires), 2) AS chiffre_affaires_total,
    COUNT(DISTINCT invoice) AS nombre_factures
FROM ventes_finales;


-- =========================================================
-- 5. ÉVOLUTION MENSUELLE DU CHIFFRE D'AFFAIRES
-- =========================================================

-- Résultat utilisé pour le graphique evolution_ca.png

SELECT
    DATE_TRUNC(
        'month',
        TO_TIMESTAMP(invoicedate, 'MM/DD/YYYY HH24:MI')
    )::date AS mois,
    ROUND(SUM(chiffre_affaires), 2) AS chiffre_affaires
FROM ventes_finales
GROUP BY mois
ORDER BY mois;


-- =========================================================
-- 6. TOP 10 DES PRODUITS
-- =========================================================

-- Les codes M, DOT et POST sont exclus
-- pour concentrer le classement sur les produits.
-- Résultat utilisé pour le graphique top_10_produits.png

SELECT
    stockcode,
    MAX(description) AS produit,
    ROUND(SUM(chiffre_affaires), 2) AS chiffre_affaires
FROM ventes_finales
WHERE stockcode NOT IN ('M', 'DOT', 'POST')
GROUP BY stockcode
ORDER BY chiffre_affaires DESC
LIMIT 10;


-- =========================================================
-- 7. TOP 10 DES PAYS
-- =========================================================

-- Résultat utilisé pour le graphique top_10_pays.png

SELECT
    country AS pays,
    ROUND(SUM(chiffre_affaires), 2) AS chiffre_affaires
FROM ventes_finales
GROUP BY country
ORDER BY chiffre_affaires DESC
LIMIT 10;


-- =========================================================
-- FIN DU SCRIPT
-- =========================================================
