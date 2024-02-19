-- table creation where I put data from my csv

-- in some case better to import data in xlsx

-- i am using oracle db to do some dml on data with pl/sql  

CREATE TABLE cardiodiseasecleveland (
	id_person INT   
	, age INT   -- age in days 
	, gender INT  --  1 - women, 2 - men 
	, height INT   
	, weight FLOAT(126)   
	, ap_hi INT   -- Systolic blood pressure
	, ap_lo INT   -- Diastolic blood pressure
	, cholesterol INT  -- Cholesterol levels. Categorical variable (1: Normal, 2: Above Normal, 3: Well Above Normal) 
	, gluc INT   -- Glucose levels. Categorical variable (1: Normal, 2: Above Normal, 3: Well Above Normal)
	, smoke INT   -- Smoking status. Binary variable (0: Non-smoker, 1: Smoker)
	, alco INT   -- Alcohol intake. Binary variable (0: Does not consume alcohol, 1: Consumes alcohol)
	, active INT   -- Physical activity. Binary variable (0: Not physically active, 1: Physically active)
	, cardio INT  -- Presence or absence of cardiovascular disease. Target variable. Binary (0: Absence, 1: Presence) 
	, age_years INT   
	, bmi FLOAT(126) -- Body Mass Index, derived from weight and height. Calculated as ( \text{BMI} = \frac{\text{weight (kg)}}{\text{height (m)}^2}  
	, bp_category VARCHAR2(50) -- Blood pressure category based on ap_hi and ap_lo. Categories include "Normal", "Elevated", 
															-- "Hypertension Stage 1", "Hypertension Stage 2", and "Hypertensive Crisis".
	, bp_category_encoded VARCHAR2(50) -- Encoded form of bp_category for machine learning purposes
	, CONSTRAINT patient_pk PRIMARY KEY (id_person)
);
COMMIT;

select min (age_years) from cardiodiseasecleveland; -- 29
select max (age_years) from cardiodiseasecleveland; -- 64

/* now I need to add the col 'age_group' to classify the 'age_years' field
	
<= 30
31 - 40
41 - 50
51-60
>60


*/

ALTER TABLE cardiodiseasecleveland ADD age_group VARCHAR(30);
COMMIT;

-- now I need to populate the 'age_group' col 


SET SERVEROUTPUT ON;

DECLARE
  TYPE cardio_aa IS TABLE OF cardiodiseasecleveland%ROWTYPE INDEX BY BINARY_INTEGER;  
  l_cardio_aa cardio_aa := cardio_aa();
	l_age_group VARCHAR(500) := '';
BEGIN
  SELECT cardiodiseasecleveland.* 
		BULK COLLECT INTO l_cardio_aa
		FROM cardiodiseasecleveland; 
  FOR i IN l_cardio_aa.FIRST .. l_cardio_aa.LAST LOOP
    IF l_cardio_aa(i).age_years < 31 THEN
			l_age_group := UPPER('<= 30');
    ELSIF l_cardio_aa(i).age_years > 30 AND l_cardio_aa(i).age_years < 41 THEN
			l_age_group := UPPER('31 - 40');
		ELSIF l_cardio_aa(i).age_years > 40 AND l_cardio_aa(i).age_years < 51 THEN
			l_age_group := UPPER('41 - 50');
		ELSIF l_cardio_aa(i).age_years > 50 AND l_cardio_aa(i).age_years < 61 THEN
			l_age_group := UPPER('51 - 60');
    ELSE 
			l_age_group := UPPER('> 60');
    END IF;
		UPDATE cardiodiseasecleveland SET age_group = l_age_group
			WHERE id_person = l_cardio_aa(i).id_person;
		COMMIT; 
  END LOOP;
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line(SQLERRM);
			dbms_output.put_line(dbms_utility.format_error_backtrace);
		ROLLBACK;
		RAISE;
END;
/
 
COMMIT;

-- first step for analysis and data cleaning 

-- i need a table to store the next res

CREATE TABLE cardiodiseasecleveland_rev_1 (
	avg_age FLOAT
  , age_group VARCHAR(50)
  , gender CHAR(1)
  , gender_cnt 	INT
  , systolic_blood_press FLOAT
  , diastolic_blood_pressure FLOAT
  , chol FLOAT 
	, gluc FLOAT
  , smoker_prob FLOAT
  , alco_prob FLOAT
  , active_prob FLOAT 
  , cardio_probl_prob FLOAT
  , body_max_ix FLOAT
);

COMMIT;


-- -- -- -- -- -- -- 


INSERT INTO cardiodiseasecleveland_rev_1 (
	SELECT
		ROUND(AVG(c.age_years), 2) avg_age
		, c.age_group
		, DECODE(c.gender, 1, 'F', 2, 'M') gender
		, COUNT(c.gender) gender_count
		, ROUND(AVG(c.ap_hi), 2) syst_blood_pressure
		, ROUND(AVG(c.ap_lo), 2) diast_blood_pressure
		, ROUND(AVG(/*DECODE (c.chol, 1, 'NORM', 2, 'ABOVE NORM', 3, 'WELL ABOVE NORM')*/c.cholesterol), 2) chol
		, ROUND(AVG(c.gluc), 2) gluc 
		, ROUND(AVG(c.smoke), 2) smoker_prob
		, ROUND(AVG(c.alco), 2) alco_prob 
		, ROUND(AVG(c.active), 2) active_prob 
		, ROUND(AVG(c.cardio), 2) cardio_probl_prob 
		, ROUND(AVG(c.bmi), 2) body_max_ix
	FROM 
		cardiodiseasecleveland c
	GROUP BY 
		c.gender
		, c.age_group
);

COMMIT;

-- QUERY

SELECT
	ROUND(AVG(c.age_years), 2) avg_age
	, c.age_group
	, DECODE(c.gender, 1, 'F', 2, 'M') gender
	, COUNT(c.gender) gender_count
	, ROUND(AVG(c.ap_hi), 2) syst_blood_pressure
	, ROUND(AVG(c.ap_lo), 2) diast_blood_pressure
	, ROUND(AVG(/*DECODE (c.chol, 1, 'NORM', 2, 'ABOVE NORM', 3, 'WELL ABOVE NORM')*/c.cholesterol), 2) chol
	, ROUND(AVG(c.gluc), 2) gluc 
	, ROUND(AVG(c.smoke), 2) smoker_prob
	, ROUND(AVG(c.alco), 2) alco_prob 
	, ROUND(AVG(c.active), 2) active_prob 
	, ROUND(AVG(c.cardio), 2) cardio_probl_prob 
	, ROUND(AVG(c.bmi), 2) body_max_ix
FROM 
	cardiodiseasecleveland c
GROUP BY 
	c.gender
	, c.age_group
ORDER BY 
	3
	, 1