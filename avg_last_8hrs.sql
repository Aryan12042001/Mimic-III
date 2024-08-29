-- Average of the data for the last 8 hours before death/discharge time

WITH icu_stay_filtered AS (
    SELECT
        i.subject_id,
        i.hadm_id,
        i.icustay_id,
        i.first_careunit,
        i.last_careunit,
        i.intime,
        i.outtime,
        i.los AS length_of_stay,
		ROW_NUMBER() OVER (PARTITION BY i.subject_id ORDER BY i.intime DESC) AS rn
    FROM
        icustays i
    WHERE
        i.first_careunit NOT ILIKE '%NICU%' AND
        i.first_careunit NOT ILIKE '%PICU%' AND
        i.last_careunit NOT ILIKE '%NICU%' AND
        i.last_careunit NOT ILIKE '%PICU%' AND
        i.los >= 2
),
last_admission AS (
    SELECT
        subject_id,
        hadm_id,
        icustay_id,
        first_careunit,
        last_careunit,
        intime,
        outtime,
        length_of_stay
    FROM
        icu_stay_filtered
    WHERE
        rn = 1
),
first_last_vitals AS (
    SELECT
        subject_id,
        MIN(charttime) AS first_vital_time,
        MAX(charttime) AS last_vital_time
    FROM
        chartevents
    WHERE
        itemid IN (220045, 220051, 220050, 220052, 223762, 220277, 220210, 227456, 225624, 225651, 220632, 227443, 225638, 220602, 220615, 220621, 220228, 220545, 227457, 227442, 227466, 220645, 220546)
    GROUP BY
        subject_id
),
eligible_patients AS (
    SELECT
        l.subject_id,
        l.hadm_id,
        l.icustay_id,
        l.length_of_stay,
        f.first_vital_time,
        f.last_vital_time
    FROM
        last_admission l
    JOIN
        first_last_vitals f ON l.subject_id = f.subject_id
    WHERE
        EXTRACT(EPOCH FROM (f.last_vital_time - f.first_vital_time))/86400 >= 2
),
mean_vitals AS (
    SELECT
        c.subject_id,
		-- Vital Tests
        AVG(CASE WHEN c.itemid = 220045 THEN c.valuenum END) AS heart_rate,
		AVG(CASE WHEN c.itemid = 220051 THEN c.valuenum END) AS diastolic_blood_pressure,
		AVG(CASE WHEN c.itemid = 220050 THEN c.valuenum END) AS systolic_blood_pressure,
		AVG(CASE WHEN c.itemid = 220052 THEN c.valuenum END) AS blood_pressure,
		AVG(CASE WHEN c.itemid = 223762 THEN c.valuenum END) AS temperature,
		AVG(CASE WHEN c.itemid = 220277 THEN c.valuenum END) AS pheripheral_oxygen_saturation,
        AVG(CASE WHEN c.itemid = 220210 THEN c.valuenum END) AS respiratory_rate,
		-- Lab Tests
		AVG(CASE WHEN c.itemid = 227456 THEN c.valuenum END) AS albumin,
		AVG(CASE WHEN c.itemid = 225624 THEN c.valuenum END) AS blood_urea_nitrogen,
		AVG(CASE WHEN c.itemid = 225651 THEN c.valuenum END) AS bilirubin,
		AVG(CASE WHEN c.itemid = 220632 THEN c.valuenum END) AS lactate,
		AVG(CASE WHEN c.itemid = 227443 THEN c.valuenum END) AS bicarbonate,
		AVG(CASE WHEN c.itemid = 225638 THEN c.valuenum END) AS band_neutrophil,
		AVG(CASE WHEN c.itemid = 220602 THEN c.valuenum END) AS chloride,
		AVG(CASE WHEN c.itemid = 220615 THEN c.valuenum END) AS creatinine,
		AVG(CASE WHEN c.itemid = 220621 THEN c.valuenum END) AS glucose,
		AVG(CASE WHEN c.itemid = 220228 THEN c.valuenum END) AS hemoglobin,
		AVG(CASE WHEN c.itemid = 220545 THEN c.valuenum END) AS hematocrit,
		AVG(CASE WHEN c.itemid = 227457 THEN c.valuenum END) AS platelet_count,
		AVG(CASE WHEN c.itemid = 227442 THEN c.valuenum END) AS potassium,
		AVG(CASE WHEN c.itemid = 227466 THEN c.valuenum END) AS partial_thromboplastin_time,
		AVG(CASE WHEN c.itemid = 220645 THEN c.valuenum END) AS sodium,
		AVG(CASE WHEN c.itemid = 220546 THEN c.valuenum END) AS white_blood_cells
    FROM
        chartevents c
    WHERE
        c.itemid IN (220045, 220051, 220050, 220052, 223762, 220277, 220210, 227456, 225624, 225651, 220632, 227443, 225638, 220602, 220615, 220621, 220228, 220545, 227457, 227442, 227466, 220645, 220546)
    GROUP BY
        c.subject_id
)
SELECT DISTINCT ON (e.subject_id)
    e.subject_id,
	a.hospital_expire_flag,
	e.last_vital_time AS death_discharge_time,
    e.length_of_stay,
	p.gender,
    p.dob AS dob,
    a.ethnicity,
	-- Vital Tests
    v.heart_rate,
	v.diastolic_blood_pressure,
	v.systolic_blood_pressure,
	v.blood_pressure,
	v.temperature,
	v.pheripheral_oxygen_saturation,
    v.respiratory_rate,
	-- Lab Tests
	v.albumin,
	v.blood_urea_nitrogen,
	v.bilirubin,
	v.lactate,
	v.bicarbonate,
	v.band_neutrophil,
	v.chloride,
	v.creatinine,
	v.glucose,
	v.hemoglobin,
	v.hematocrit,
	v.platelet_count,
	v.potassium,
	v.partial_thromboplastin_time,
	v.sodium,
	v.white_blood_cells
FROM
    eligible_patients e
JOIN
    mean_vitals v ON e.subject_id = v.subject_id
JOIN
    patients p ON e.subject_id = p.subject_id
JOIN
    admissions a ON e.hadm_id = a.hadm_id;
