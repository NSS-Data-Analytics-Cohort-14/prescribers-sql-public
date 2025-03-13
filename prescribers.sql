-- 1. 
--     a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.
    SELECT 
		prescriber.npi
		, SUM (prescription.total_claim_count) AS total_claim_count
		, prescriber.nppes_provider_last_org_name AS provider_last_name
	FROM prescriber
	LEFT JOIN prescription
	ON prescriber.npi = prescription.npi
	WHERE total_claim_count IS NOT NULL
	GROUP BY prescriber.npi, prescriber.nppes_provider_last_org_name
	ORDER BY total_claim_count DESC
	LIMIT 5;
	
	NPI is 1881634483, total claims is 99,707
--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

    SELECT 
		prescriber.npi
		, SUM (prescription.total_claim_count) AS total_claim_count
		, prescriber.nppes_provider_last_org_name AS provider_last_name
		, prescriber.nppes_provider_first_name AS provider_first_name
		, prescriber.specialty_description AS specialty_description
	FROM prescriber
	LEFT JOIN prescription
	ON prescriber.npi = prescription.npi
	WHERE total_claim_count IS NOT NULL
	GROUP BY prescriber.npi
				, prescriber.nppes_provider_last_org_name
				, prescriber.nppes_provider_first_name
				, prescriber.specialty_description
	ORDER BY total_claim_count DESC
	LIMIT 5;

BRUCE PENDLEY - FAMILY PRACTICE - 1881634483 - 99707 total claims
	
-- 2. 
--     a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT 
	pr.specialty_description
	, SUM (pn.total_claim_count) AS total_claim_count
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
GROUP BY pr.specialty_description
ORDER BY SUM (pn.total_claim_count) DESC NULLS LAST;

Family practice had the most numer of claims with 9,752,347

--     b. Which specialty had the most total number of claims for opioids?

SELECT 
	pr.specialty_description
	, SUM (pn.total_claim_count)
	, opioid_drug_flag
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY pr.specialty_description,
		opioid_drug_flag
ORDER BY SUM (pn.total_claim_count) DESC;

NURSE PRACTICIONERS with 900,845

SELECT drug.opioid_drug_flag
FROM drug;

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

SELECT 
	pr.specialty_description,
	SUM (pn.total_claim_count) AS total_claims
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
GROUP BY pr.specialty_description
ORDER BY SUM (pn.total_claim_count) DESC;

YES there are 15 specialty descriptions where there are no claims

--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* 
--     For each specialty, report the percentage of total claims by that specialty which are 
--     for opioids. Which specialties have a high percentage of opioids?

SELECT 
	pr.specialty_description
	, SUM (pn.total_claim_count)
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
GROUP BY pr.specialty_description
ORDER BY SUM(pn.total_claim_count)DESC;

SELECT 
	 SUM (pn.total_claim_count)
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
WHERE opioid_drug_flag = 'Y'
GROUP BY pr.specialty_description;

SELECT 
	pr.specialty_description
	, SUM (pn.total_claim_count)
	, SUM CASE WHEN (d.opioid_drug_flag = 'Y') THEN 1
		ELSE 0
		END
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
GROUP BY pr.specialty_description
ORDER BY SUM(pn.total_claim_count)DESC;

SELECT 
	SUM (CASE WHEN d.opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) AS opioid
	, SUM(pn.total_claim_count) AS total_claim_count
	, (SUM (CASE WHEN d.opioid_drug_flag = 'Y' THEN total_claim_count ELSE 0 END) 
		/ SUM(pn.total_claim_count)) * 100 AS percent
	, pr.specialty_description 
FROM prescriber AS pr
LEFT JOIN prescription AS pn
ON pr.npi = pn.npi
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
GROUP BY pr.specialty_description
ORDER BY percent DESC NULLS LAST;

-- 3. 
--     a. Which drug (generic_name) had the highest total drug cost?

SELECT 
	d.generic_name
	,pn.total_drug_cost
FROM prescription AS pn
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
ORDER BY pn.total_drug_cost DESC
LIMIT 5;

SELECT 
	d.generic_name
	,SUM(pn.total_drug_cost) AS total_cost
FROM prescription AS pn
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
GROUP BY d.generic_name
ORDER BY SUM(pn.total_drug_cost) DESC
LIMIT 5;

The highest total drug cost is Insulin at 104,264,066.35

--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.**

SELECT 
	ROUND (SUM(pn.total_drug_cost) / (SUM(total_day_supply)),2) AS cost_per_day
	, d.generic_name
FROM prescription AS pn
LEFT JOIN drug AS d
ON pn.drug_name = d.drug_name
GROUP BY d.generic_name
ORDER BY cost_per_day DESC
;

The drug with the highest total cost per day is C1 esterase inhibitor

-- 4. 
--     a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. **Hint:** You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/ 

SELECT 
	drug_name
,CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END
FROM drug;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

SELECT
	SUM (total_drug_cost) AS money,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug AS d
LEFT JOIN prescription AS pn
ON d.drug_name = pn.drug_name
GROUP BY d.opioid_drug_flag, antibiotic_drug_flag;

-- 5. 
--     a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

SELECT
	COUNT (*)
FROM cbsa
LEFT JOIN fips_county
USING (fipscounty)
WHERE fips_county.state = 'TN';

42

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

SELECT 
	DISTINCT (cbsaname)
	, SUM (population) AS combined_population
FROM cbsa AS c
LEFT JOIN population AS p
ON c.fipscounty = p.fipscounty
WHERE population IS NOT NULL
GROUP BY cbsaname
ORDER BY SUM (population) DESC;

Nashville-Davidson-Murfreesboro-Franklin, TN with the most at 1830410
Morristown TN with the least at 116352


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

SELECT 
	county
	, cbsa
	, p.population
FROM fips_county AS f
LEFT JOIN cbsa AS c
ON f.fipscounty = c.fipscounty
LEFT JOIN population AS p
ON f.fipscounty = p.fipscounty
WHERE cbsa IS NULL
AND population IS NOT NULL
ORDER BY population DESC;

The largest county without a CBSA code is SEVIER County with a population of 95523

-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT
	prescription.total_claim_count
	, prescription.drug_name
FROM 
	prescription
WHERE
	total_claim_count >= 3000;

--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT
	prescription.total_claim_count
	, prescription.drug_name
	, drug.opioid_drug_flag
FROM 
	prescription
LEFT JOIN
	drug
ON
	prescription.drug_name = drug.drug_name
WHERE
	total_claim_count >= 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT
	prescription.total_claim_count
	, prescription.drug_name
	, drug.opioid_drug_flag
	, nppes_provider_first_name
	, nppes_provider_last_org_name
FROM 
	prescription
LEFT JOIN
	drug
ON
	prescription.drug_name = drug.drug_name
LEFT JOIN
	prescriber
ON
	prescription.npi = prescriber.npi
WHERE
	total_claim_count >= 3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.

--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT 
	pr.npi
	, d.drug_name
	, d.opioid_drug_flag
	, pr.specialty_description
	, pr.nppes_provider_city
FROM prescriber AS pr
CROSS JOIN drug AS d
WHERE pr.specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
ORDER BY d.drug_name;

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT 
	pr.npi
	, d.drug_name
	, d.opioid_drug_flag
	, pr.specialty_description
	, pr.nppes_provider_city
	, pn.total_claim_count
FROM prescriber AS pr
CROSS JOIN drug AS d
LEFT JOIN prescription AS pn
USING (npi, drug_name)
WHERE pr.specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
ORDER BY d.drug_name;

--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count
--         with 0. Hint - Google the COALESCE function.

SELECT 
	pr.npi
	, d.drug_name
	, d.opioid_drug_flag
	, pr.specialty_description
	, pr.nppes_provider_city
	, COALESCE(pn.total_claim_count,0)
FROM prescriber AS pr
CROSS JOIN drug AS d
LEFT JOIN prescription AS pn
USING (npi, drug_name)
WHERE pr.specialty_description = 'Pain Management'
AND nppes_provider_city = 'NASHVILLE'
AND d.opioid_drug_flag = 'Y'
ORDER BY d.drug_name;