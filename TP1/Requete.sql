/* EXERCICE 1 */
/**************/

/* A */ -- IL PASSE DU RANG 4 À 6
SELECT DEPTNO, ENAME, SAL, RANK() OVER 
  (PARTITION BY DEPTNO ORDER BY SAL DESC) AS RANG
FROM EMP
WHERE DEPTNO = 10 OR DEPTNO = 30;

/* B */ -- IL PASSE DU RANG 4 À 5
SELECT DEPTNO, ENAME, SAL, DENSE_RANK() OVER 
  (PARTITION BY DEPTNO ORDER BY SAL DESC) AS RANG
FROM EMP
WHERE DEPTNO = 10 OR DEPTNO = 30;

/* C */
SELECT DISTINCT DEPTNO, SAL, DENSE_RANK() OVER 
  (PARTITION BY DEPTNO ORDER BY SAL DESC) AS "RANG"
FROM EMP
WHERE DEPTNO = 10 OR DEPTNO = 20
ORDER BY DEPTNO, SAL DESC;

/* D */
SELECT JOB, SUM(SAL) AS TOT_SAL_JOB
FROM EMP
GROUP BY JOB;

SELECT DISTINCT JOB, SUM(SAL) OVER 
  (PARTITION BY JOB) AS TOT_SAL_JOB
FROM EMP;

SELECT DISTINCT JOB, 
  (SELECT SUM(SAL) FROM EMP E2 WHERE E1.JOB=E2.JOB) 
  AS TOT_SAL_JOB
FROM EMP E1;

/* E */
-- ILS FONT LA MÊME CHOSE, SAUF QUE PARTITION BY 
-- APPLIQUE LE CALCUL EN RETOURNANT $
-- L'ENSEMBLE DES LIGNES CONTRAIREMENT AU GROUP BY.

/* F */
SELECT DEPTNO, JOB, SUM(SAL)
FROM EMP
GROUP BY ROLLUP (DEPTNO, JOB);

/* G */ -- TO_CHAR PERMET DE CASTER LA COLONNE EN CHAR
SELECT NVL(TO_CHAR(DEPTNO),'TOUSDEP'), 
  NVL(TO_CHAR(JOB),'TOUSEMPLOYES'), SUM(SAL)
FROM EMP
GROUP BY ROLLUP (DEPTNO, JOB)
ORDER BY DEPTNO, JOB DESC;


/* EXERCICE 2 */
/**************/

/* 1 */
SELECT T.ANNEE, C.CL_R, P.CATEGORY, AVG(V.QTE*V.PU) AS CA_MOYEN
FROM VENTES V 
  JOIN TEMPS T ON T.TID=V.TID 
  JOIN CLIENTS C ON V.CID=C.CL_ID 
  JOIN PRODUITS P ON V.PID=P.PID
WHERE T.ANNEE=2009 OR T.ANNEE=2010
GROUP BY ROLLUP (ANNEE, CL_R, CATEGORY);

/* 2 */
SELECT T.ANNEE, C.CL_R, P.CATEGORY, AVG(V.QTE*V.PU) AS CA_MOYEN
FROM VENTES V 
  JOIN TEMPS T ON T.TID=V.TID 
  JOIN CLIENTS C ON V.CID=C.CL_ID 
  JOIN PRODUITS P ON V.PID=P.PID
WHERE T.ANNEE=2009 OR T.ANNEE=2010
GROUP BY CUBE (ANNEE, CL_R, CATEGORY);

/* 3 */
SELECT ANNEE, CATEGORY, PNAME
FROM (
  SELECT T.ANNEE, P.CATEGORY, P.PNAME, RANK() OVER 
    (PARTITION BY T.ANNEE, P.CATEGORY ORDER BY SUM(V.QTE*V.PU) DESC) AS RANG
  FROM VENTES V 
    JOIN TEMPS T ON V.TID=T.TID
    JOIN PRODUITS P ON V.PID=P.PID
  GROUP BY (T.ANNEE, P.CATEGORY, P.PNAME)
)
WHERE RANG=1;

/* 4 */
SELECT T.ANNEE, P.CATEGORY, SUM(V.QTE*V.PU)
FROM VENTES V
  JOIN TEMPS T ON V.TID=T.TID
  JOIN PRODUITS P ON V.PID=P.PID
GROUP BY CUBE(ANNEE, CATEGORY)
HAVING GROUPING_ID(ANNEE) < 1;

/* 5 */
SELECT ANNEE, MOIS, CA_TOTAL 
FROM (
  SELECT T.ANNEE, T.MOIS, SUM(V.QTE*V.PU) AS CA_TOTAL, RANK() OVER 
    (PARTITION BY T.ANNEE ORDER BY SUM(V.QTE*V.PU) DESC) AS RANG
  FROM VENTES V
    JOIN TEMPS T ON V.TID=T.TID
    JOIN PRODUITS P ON V.PID=P.PID
  WHERE P.PNAME = 'Sirop d érable'
  GROUP BY T.ANNEE, T.MOIS
) TMP
WHERE TMP.RANG = 1;

/* 6 */
SELECT T.ANNEE, C.CL_NAME, P.CATEGORY, SUM(V.QTE*V.PU) AS "CA_TOTAL"
FROM VENTES V
  JOIN PRODUITS P ON V.PID=P.PID
  JOIN TEMPS T ON V.TID=T.TID
  JOIN CLIENTS C ON V.CID=C.CL_ID
GROUP BY T.ANNEE, 
GROUPING SETS(P.CATEGORY, C.CL_NAME);

/* 7 */
SELECT CATEGORY, SUM(QTE) AS QTE_VENDU_2010, NTILE(3) 
  OVER(ORDER BY SUM(QTE) DESC) AS TIERS
FROM VENTES 
  NATURAL JOIN TEMPS 
  NATURAL JOIN PRODUITS
WHERE ANNEE = 2010
GROUP BY CATEGORY;

/* 8 */
SELECT CATEGORY, MOIS, SUM(QTE) AS QTE_VENDUE
FROM VENTES 
  NATURAL JOIN TEMPS 
  NATURAL JOIN PRODUITS
WHERE ANNEE =2010 AND JOUR <=5
GROUP BY CATEGORY, ANNEE, MOIS
ORDER BY CATEGORY, MOIS;

