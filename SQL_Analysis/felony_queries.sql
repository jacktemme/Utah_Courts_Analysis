-- Query the average number of charges in each felony case by the court district
-- Divided up into 4 charge amount categories

WITH charge_counts AS (
SELECT ca.court_district, count(ch.uniqueid) AS number_of_charges
FROM  cases AS ca
INNER JOIN  charges AS ch ON ca.uniqueid = ch.uniqueid
GROUP BY ca.uniqueid, ca.court_district
)

SELECT court_district, 
COUNT(CASE WHEN number_of_charges > 0 AND number_of_charges <= 3 THEN 1 END) AS charges_1_3,
COUNT(CASE WHEN number_of_charges > 3 AND number_of_charges <= 6 THEN 1 END) AS charges_4_6,
COUNT(CASE WHEN number_of_charges > 6 AND number_of_charges <= 9 THEN 1 END) AS charges_7_9,
COUNT(CASE WHEN number_of_charges > 9 THEN 1 END) AS charges_10plus
FROM charge_counts
GROUP BY court_district
ORDER BY court_district ASC;



-- Query the number of each charge for each court district
-- First find the max severity of felony charge per each case

WITH ranked_cases AS (
	WITH ranked_charges AS (
		SELECT uniqueid,
			   CASE TRIM(severity_description)
				   WHEN 'Capital' THEN 8
				   WHEN '1st Degree Felony' THEN 7
				   WHEN '2nd Degree Felony' THEN 6
				   WHEN '3rd Degree Felony' THEN 5
				   WHEN 'Class A Misdemeanor' THEN 4
				   WHEN 'Class B Misdemeanor' THEN 3
				   WHEN 'Class C Misdemeanor' THEN 2
				   WHEN 'Infraction' THEN 1
				   ELSE 0
			   END AS severity_rank
		FROM charges
	)
	SELECT uniqueid,
		   MAX(severity_rank) AS highest_severity_rank
	FROM ranked_charges
	GROUP BY uniqueid
)

--Then find number of each severity by court district
SELECT ca.court_district,
       COUNT(CASE WHEN rc.highest_severity_rank = 8 THEN 1 END) AS count_capital,
       COUNT(CASE WHEN rc.highest_severity_rank = 7 THEN 1 END) AS count_1st_degree_felony,
       COUNT(CASE WHEN rc.highest_severity_rank = 6 THEN 1 END) AS count_2nd_degree_felony,
       COUNT(CASE WHEN rc.highest_severity_rank = 5 THEN 1 END) AS count_3rd_degree_felony,
       COUNT(CASE WHEN rc.highest_severity_rank = 4 THEN 1 END) AS count_class_a_misdemeanor,
       COUNT(CASE WHEN rc.highest_severity_rank = 3 THEN 1 END) AS count_class_b_misdemeanor,
       COUNT(CASE WHEN rc.highest_severity_rank = 2 THEN 1 END) AS count_class_c_misdemeanor,
       COUNT(CASE WHEN rc.highest_severity_rank = 1 THEN 1 END) AS count_infraction
FROM ranked_cases AS rc
INNER JOIN cases AS ca ON ca.uniqueid = rc.uniqueid
GROUP BY ca.court_district
ORDER BY ca.court_district ASC;



-- Query the max violation and the max charge number for each case

WITH ranked_charges AS (
    SELECT uniqueid,
           CASE TRIM(severity_description)
               WHEN 'Capital' THEN 8
               WHEN '1st Degree Felony' THEN 7
               WHEN '2nd Degree Felony' THEN 6
               WHEN '3rd Degree Felony' THEN 5
               WHEN 'Class A Misdemeanor' THEN 4
               WHEN 'Class B Misdemeanor' THEN 3
               WHEN 'Class C Misdemeanor' THEN 2
               WHEN 'Infraction' THEN 1
               ELSE 0
           END AS severity_rank
    FROM charges
),
ranked_cases AS (
    SELECT uniqueid,
           MAX(severity_rank) AS highest_severity_rank
    FROM ranked_charges
    GROUP BY uniqueid
),
highest_charge AS (
    SELECT uniqueid, MAX(charge_number) AS max_charge
    FROM charges
    GROUP BY uniqueid
)

SELECT rc.uniqueid, rc.highest_severity_rank, hc.max_charge
FROM ranked_cases AS rc 
INNER JOIN highest_charge AS hc ON rc.uniqueid = hc.uniqueid;
