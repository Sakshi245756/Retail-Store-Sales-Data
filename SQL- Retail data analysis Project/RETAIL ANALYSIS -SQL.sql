USE [db_SQLCaseStudies];

SELECT  * FROM CUSTOMER AS C;
SELECT  * FROM Transactions AS T;
SELECT  * FROM prod_cat_info AS P;

SELECT TOP 2 * FROM Customer AS C;
SELECT TOP 2 * FROM TRANSACTIONS AS T;
SELECT TOP 2 * FROM prod_cat_info AS P;

-------------------DATA PREPARATION AND UNDERSTANDING

--Q1--BEGIN

SELECT * FROM (
SELECT 'Customer' AS TABLE_NAME, COUNT(*) AS NO_OF_ROWS FROM CUSTOMER UNION ALL
SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_ROWS FROM TRANSACTIONS UNION ALL
SELECT 'prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_ROWS FROM PROD_CAT_INFO
) TBL;

--Q1--END


--Q2--BEGIN

SELECT COUNT (DISTINCT(T.transaction_id)) AS TOTAL_TRANSACTIONS_RETURN FROM Transactions AS T
WHERE T.total_amt < 0;

--Q2--END

--Q3--BEGIN

SELECT * ,CONVERT(varchar(10), C.DOB, 101) AS DATES FROM Customer AS C;
SELECT * ,CONVERT(varchar(10), T.tran_date, 101) AS DATE_ FROM TRANSACTIONS AS T;

--Q3--END

--4--BEGIN

SELECT  DATEDIFF (DAY, MIN(T.TRAN_DATE), MAX(T.TRAN_DATE)) AS DAYS_,
DATEDIFF (MONTH, MIN(T.TRAN_DATE), MAX(T.TRAN_DATE)) AS MONTHS_,
DATEDIFF (YEAR, MIN(T.TRAN_DATE), MAX(T. TRAN_DATE)) AS YEARS_
FROM TRANSACTIONS AS T;

--Q4--END

--Q5--BEGIN

SELECT P.prod_cat, P.prod_subcat FROM prod_cat_info AS P
WHERE P.prod_subcat = 'DIY';

--Q5--END

--------------DATA ANALYSIS

--Q1--BEGIN

SELECT TOP 1 T.Store_type,  COUNT(T.transaction_id) AS CHANNEL_TRANSECTIONS FROM Transactions AS T
GROUP BY T. Store_type 
ORDER BY CHANNEL_TRANSECTIONS DESC;

--Q1--END

--Q2--BEGIN

SELECT C.Gender, COUNT(C.customer_Id) AS COUNT_CUST FROM Customer AS C
GROUP BY C.Gender
HAVING C.Gender = 'M' OR C.Gender = 'F';

--Q2--END

--Q3--BEGIN

SELECT TOP 1 C.CITY_CODE, COUNT(C.CUSTOMER_ID) AS MAX_CUST FROM Customer AS C 
GROUP BY C.city_code
ORDER BY  COUNT(C.CUSTOMER_ID) DESC;

--Q3--END

--Q4--BEGIN  

 SELECT COUNT(DISTINCT (P.prod_subcat)) AS COUNT_SUB_CAT FROM prod_cat_info AS P
 WHERE P.prod_cat = 'BOOKS'
 GROUP BY P.prod_cat;

 --Q4--END

 --Q5--BEGIN

 SELECT TOP 1  T.prod_cat_code, MAX(T.Qty) AS COUNT_PROD FROM Transactions AS T
 GROUP BY T.prod_cat_code;

 --Q5--END
 
 --Q6--BEGIN 

 SELECT SUM(T.TOTAL_AMT) AS TOTAL_REVENUE FROM Transactions AS T
 INNER JOIN prod_cat_info AS P
 ON T.prod_cat_code = P.prod_cat_code 
 AND T.prod_subcat_code = P.prod_sub_cat_code                                                                                   
 WHERE P.prod_cat = 'ELECTRONICS' OR P.prod_cat = 'BOOKS';   
 
 --Q6--END

    
--Q7--BEGIN

SELECT T.cust_id, COUNT(T.cust_id) AS COUNT_ FROM TRANSACTIONS AS T
WHERE T.total_amt >= 0                                               
GROUP BY T.cust_id
HAVING COUNT( T.cust_id) > '10';

--Q7--END
                                                                        

--Q8--BEGIN 

SELECT SUM(T.TOTAL_AMT) FROM TRANSACTIONS AS T
INNER JOIN PROD_CAT_INFO AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat IN ('ELECTRONICS' , 'CLOTHING') AND T.Store_type = 'FLAGSHIP STORE';

--Q8--END


--Q9--BEGIN

SELECT P.prod_subcat, P.prod_sub_cat_code, SUM(T.TOTAL_AMT) AS TOTAL_REVENUE FROM Transactions AS T
INNER JOIN CUSTOMER AS C
ON  T.cust_id = C. customer_Id
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE C.Gender = 'M' OR P.prod_cat = 'ELECTRONICS'
GROUP BY P.prod_subcat, P.prod_sub_cat_code;

--Q9--END


--Q10--BEGIN

SELECT TOP 5 P.prod_subcat,
(SUM(T.TOTAL_AMT)/(SELECT SUM(T. TOTAL_AMT) FROM Transactions AS T))*100 AS PERCNT_SALES,
(COUNT (CASE WHEN T.Qty < 0 THEN  T.Qty ELSE NULL END)/SUM(T.Qty))*100 AS PERCNT_RETURN FROM Transactions AS T
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P. prod_sub_cat_code
GROUP BY P. prod_subcat
ORDER BY SUM(T.total_amt) DESC;

--Q10--END

--Q11--BEGIN


  SELECT  SUM(T.total_amt) AS NET_TOTAL_REVENUE_ FROM Customer AS C
  INNER JOIN Transactions AS T
  ON C.customer_Id = T.cust_id
  WHERE T.tran_date >= (SELECT DATEADD(DAY,-30,MAX(tran_date)) FROM Transactions AS T) AND
 ( DATEDIFF(YEAR,C.DOB,GETDATE()) >= '25' AND DATEDIFF(YEAR,C.DOB,GETDATE()) <= '35');

--Q11--END

--Q12--BEGIN

SELECT P.prod_cat, T.Qty, T.total_amt, MAX(T.tran_date) AS MAX_DATE FROM Transactions AS T
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code = P.prod_cat_code
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE tran_date >= (SELECT DATEADD(MONTH,-3,MAX(T.tran_date)) FROM Transactions AS T)
GROUP BY  P.prod_cat, T.Qty, T.total_amt;

--Q12--END

--Q13--BEGIN

SELECT T.Store_type, SUM(T.total_amt) AS TOTAL_SALES, SUM(T.Qty) AS TOTAL_QTY FROM Transactions AS T
GROUP BY T.Store_type
HAVING SUM(T.total_amt) > = ALL(SELECT SUM(T.total_amt) AS TOTAL_SALES FROM Transactions AS T 
						    GROUP BY T.Store_type) AND
        SUM(T.Qty) >= ALL (SELECT SUM(T.Qty) AS TOTAL_QTY FROM Transactions AS T
                           GROUP BY T.Store_type);

--Q13--END


--Q14--BEGIN

SELECT P.prod_cat, AVG(T.total_amt) AS AVERAGE_ FROM Transactions AS T
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code = P. prod_cat_code
GROUP BY P.prod_cat
HAVING AVG(T.total_amt) > (SELECT AVG(T.total_amt) FROM Transactions AS T);

--Q14--END


--Q15--BEGIN

SELECT  P.prod_cat,P.prod_subcat,  SUM(T.Qty) AS SUM_QTY,AVG(T.total_amt) AS AVG_REVENUE, 
SUM(T.total_amt) AS SUM_REVENUE FROM Transactions AS T
INNER JOIN prod_cat_info AS P
ON T.prod_cat_code=P.prod_cat_code 
AND T.prod_subcat_code = P.prod_sub_cat_code
WHERE P.prod_cat IN (SELECT TOP 5 P.prod_cat FROM Transactions AS T 
                     INNER JOIN prod_cat_info AS P
                     ON T.prod_cat_code=P.prod_cat_code 
                    AND T.prod_subcat_code = P.prod_sub_cat_code
                    GROUP BY P.prod_cat
                    ORDER BY SUM(T.Qty) DESC)
GROUP BY P.prod_cat, P.prod_subcat;

--Q15--END
