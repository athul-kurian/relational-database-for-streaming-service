-- ad-hoc queries and their outputs

-------------OUTPUT FORMATTING------------
COLUMN Type FORMAT A12
COLUMN Name FORMAT A30
COLUMN Genre FORMAT A15
COLUMN IP_Address FORMAT A20
COLUMN Profile_ID FORMAT A10
COLUMN Total_Watch_Time_Minutes FORMAT 999,999.00

SET LINESIZE 120
SET PAGESIZE 50
SET WRAP OFF
SET TRIMSPOOL ON
SET HEADING ON

-------------QUERY ONE------------
-- Which device type (TV, PC, Mobile, or Console) did the most traffic (highest total watch session duration) come from? 

SELECT D.Type, SUM((CAST(WS.Stop_timestamp AS DATE) - CAST(WS.Start_timestamp AS DATE)) * 1440) AS Total_Watch_Time_Minutes
FROM Spring25_S003_T6_WATCH_SESSION WS
JOIN Spring25_S003_T6_DEVICE D ON WS.Device_ID = D.Device_ID
GROUP BY D.Type
HAVING SUM((CAST(WS.Stop_timestamp AS DATE) - CAST(WS.Start_timestamp AS DATE)) * 1440) =
       (SELECT MAX(SUM((CAST(W.Stop_timestamp AS DATE) - CAST(W.Start_timestamp AS DATE)) * 1440))
        FROM Spring25_S003_T6_WATCH_SESSION W
        JOIN Spring25_S003_T6_DEVICE D2 ON W.Device_ID = D2.Device_ID
        GROUP BY D2.Type);

-- TYPE						                                    TOTAL_WATCH_TIME_MINUTES
-- -------------------------------------------------- ------------------------
-- Console								                                            2,666.00

-------------QUERY TWO------------
-- Identify the actor or actress whose movies have the highest total watch time among adult male users.

SELECT A.Name, ROUND(SUM((CAST(WS.Stop_timestamp AS DATE) - CAST(WS.Start_timestamp AS DATE)) * 1440)) AS Total_Watch_Time_Minutes
FROM Spring25_S003_T6_WATCH_SESSION WS
JOIN Spring25_S003_T6_USER_PROFILE UP ON WS.Profile_ID = UP.Profile_ID
JOIN Spring25_S003_T6_MOVIE M ON WS.Movie_ID = M.Movie_ID
JOIN Spring25_S003_T6_STARRING S ON M.Movie_ID = S.Movie_ID
JOIN Spring25_S003_T6_ACTOR A ON S.Actor_ID = A.Actor_ID
WHERE UP.Gender = 'Male'
  AND FLOOR(MONTHS_BETWEEN(SYSDATE, UP.DOB)/12) >= 18
GROUP BY A.Name
ORDER BY Total_Watch_Time_Minutes DESC
FETCH FIRST 1 ROW ONLY;

-- NAME			                       Total_Watch_Time_Minutes
-- ------------------------------ ------------------------
-- Tom Hanks					                              316.00

-------------QUERY THREE------------
-- Find the user profiles who have watched at least one movie in every genre available in the system.

SELECT UP.Profile_ID, UP.Name
FROM Spring25_S003_T6_USER_PROFILE UP
WHERE NOT EXISTS (
    SELECT G.Genre
    FROM (SELECT DISTINCT Genre FROM Spring25_S003_T6_MOVIE) G
    WHERE NOT EXISTS (
        SELECT 1
        FROM Spring25_S003_T6_WATCH_SESSION WS
        JOIN Spring25_S003_T6_MOVIE M ON WS.Movie_ID = M.Movie_ID
        WHERE WS.Profile_ID = UP.Profile_ID
          AND M.Genre = G.Genre
    )
);

-- PROFILE_ID  NAME
-- ---------- ------------------------------
-- P81	      Mike Wazowski
-- P82	      Ella Sinclair

-------------QUERY FOUR------------
-- Show the total watch time per genre, and include subtotals for each genre and a grand total at the end.

SELECT NVL(M.Genre, 'TOTAL') AS Genre, SUM((CAST(WS.Stop_timestamp AS DATE) - CAST(WS.Start_timestamp AS DATE)) * 1440) AS Total_Watch_Time_Minutes
FROM Spring25_S003_T6_WATCH_SESSION WS
JOIN Spring25_S003_T6_MOVIE M ON WS.Movie_ID = M.Movie_ID
GROUP BY ROLLUP(M.Genre);

-- GENRE		       TOTAL_WATCH_TIME_MINUTES
-- --------------- ------------------------
-- Action				                     719.00
-- Adventure			                   645.00
-- Comedy				                   1,060.00
-- Drama				                     328.00
-- Fantasy 			                     695.00
-- Horror				                     404.00
-- Mystery 			                     614.00
-- Romance 			                     516.00
-- Sci-Fi				                     464.00
-- Thriller			                     215.00
-- TOTAL				                   5,660.00

-- 11 rows selected.

-------------QUERY FIVE------------
-- For all adult female users, show the total watch time grouped by IP subnet starting with 192.168.0, and include a grand total of watch time for that region.

SELECT NVL(WS.IP_Address, 'TOTAL') AS IP_Region, ROUND(SUM((CAST(WS.Stop_timestamp AS DATE) - CAST(WS.Start_timestamp AS DATE)) * 1440)) AS Total_Watch_Time_Minutes
FROM Spring25_S003_T6_WATCH_SESSION WS
JOIN Spring25_S003_T6_USER_PROFILE UP ON WS.Profile_ID = UP.Profile_ID
WHERE UP.Gender = 'Female'
AND FLOOR(MONTHS_BETWEEN(SYSDATE, UP.DOB)/12) >= 18
AND WS.IP_Address LIKE '192.168.0.%'
GROUP BY ROLLUP(WS.IP_Address);

-- IP_REGION					                                TOTAL_WATCH_TIME_MINUTES
-- -------------------------------------------------- ------------------------
-- 192.168.0.103							                                           94.00
-- 192.168.0.138							                                           86.00
-- 192.168.0.158							                                           65.00
-- 192.168.0.163							                                           64.00
-- 192.168.0.19							                                             39.00
-- 192.168.0.211							                                          105.00
-- 192.168.0.212							                                          105.00
-- 192.168.0.213							                                           90.00
-- 192.168.0.214							                                           90.00
-- 192.168.0.215							                                           80.00
-- 192.168.0.216							                                           90.00
-- 192.168.0.217							                                          105.00
-- 192.168.0.218							                                           90.00
-- 192.168.0.219							                                          105.00
-- 192.168.0.220							                                          110.00
-- 192.168.0.33							                                            150.00
-- 192.168.0.41							                                             80.00
-- 192.168.0.94							                                            118.00
-- TOTAL								                                              1,666.00

-- 9 rows selected.