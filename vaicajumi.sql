SELECT 
    s.arsta_registracijas_numurs AS "?rsta Re?. Nr.",
    s.vards AS "V?rds",
    s.uzvards AS "Uzv?rds",
    ms.nosaukums AS "Specialit?te",
    ROUND(s.alga, 2) AS "Alga",
    COUNT(p.personas_kods) AS "Pacientu Skaits",
    ROUND(AVG(p.vecums), 1) AS "Vid?jais Pacientu Vecums"
FROM 
    Slimnica s
    JOIN MedicinasSpecialisti ms ON s.specialitate = ms.id
    LEFT JOIN Pacienti p ON s.arsta_registracijas_numurs = p.arsta_registracijas_numurs
GROUP BY 
    s.arsta_registracijas_numurs,
    s.vards,
    s.uzvards,
    ms.nosaukums,
    s.alga
ORDER BY 
    s.alga DESC;

SELECT 
    ms.nosaukums AS "Specialit?te",
    COUNT(DISTINCT s.arsta_registracijas_numurs) AS "?rstu Skaits",
    COUNT(p.personas_kods) AS "Kop?jais Pacientu Skaits",
    ROUND(COUNT(p.personas_kods) / COUNT(DISTINCT s.arsta_registracijas_numurs), 1) AS "Vid?jais pacientu skaits uz ?rstu",
    ROUND(AVG(s.alga), 2) AS "Vid?j? Alga",
    ROUND(AVG(p.vecums), 1) AS "Vid?jais Pacientu Vecums"
FROM 
    MedicinasSpecialisti ms
    JOIN Slimnica s ON ms.id = s.specialitate
    LEFT JOIN Pacienti p ON s.arsta_registracijas_numurs = p.arsta_registracijas_numurs
GROUP BY 
    ms.nosaukums
ORDER BY 
    "Vid?jais pacientu skaits uz ?rstu" DESC;

WITH DoctorStats AS (
    SELECT 
        s.arsta_registracijas_numurs,
        s.vards,
        s.uzvards,
        s.alga,
        s.specialitate,
        COUNT(p.personas_kods) as pacientu_skaits,
        AVG(COUNT(p.personas_kods)) OVER (PARTITION BY s.specialitate) as avg_pacientu_skaits,
        AVG(s.alga) OVER (PARTITION BY s.specialitate) as avg_speciality_salary
    FROM 
        Slimnica s
        LEFT JOIN Pacienti p ON s.arsta_registracijas_numurs = p.arsta_registracijas_numurs
    GROUP BY 
        s.arsta_registracijas_numurs, s.vards, s.uzvards, s.alga, s.specialitate
)
SELECT 
    d.arsta_registracijas_numurs AS "?rsta Re?. Nr.",
    d.vards AS "V?rds",
    d.uzvards AS "Uzv?rds",
    ms.nosaukums AS "Specialit?te",
    ROUND(d.alga, 2) AS "Alga",
    ROUND(d.avg_speciality_salary, 2) AS "Vid?j? Specialit?tes Alga",
    ROUND(d.alga - d.avg_speciality_salary, 2) AS "Starp?ba no Vid?j?s",
    d.pacientu_skaits AS "Pacientu Skaits",
    ROUND(d.avg_pacientu_skaits, 1) AS "Vid. Pacientu Skaits Specialit??"
FROM 
    DoctorStats d
    JOIN MedicinasSpecialisti ms ON d.specialitate = ms.id
WHERE 
    d.alga < d.avg_speciality_salary
    AND d.pacientu_skaits > d.avg_pacientu_skaits
ORDER BY 
    (d.alga - d.avg_speciality_salary) ASC;

SELECT 
    ms.nosaukums AS "Specialit?te",
    COUNT(CASE WHEN p.vecums < 18 THEN 1 END) AS "B?rni (<18)",
    COUNT(CASE WHEN p.vecums BETWEEN 18 AND 30 THEN 1 END) AS "Jaunieši (18-30)",
    COUNT(CASE WHEN p.vecums BETWEEN 31 AND 50 THEN 1 END) AS "Pieaugušie (31-50)",
    COUNT(CASE WHEN p.vecums BETWEEN 51 AND 70 THEN 1 END) AS "Vec?ki (51-70)",
    COUNT(CASE WHEN p.vecums > 70 THEN 1 END) AS "Seniori (>70)",
    COUNT(*) AS "Kop? Pacientu"
FROM 
    MedicinasSpecialisti ms
    JOIN Slimnica s ON ms.id = s.specialitate
    JOIN Pacienti p ON s.arsta_registracijas_numurs = p.arsta_registracijas_numurs
GROUP BY 
    ms.nosaukums
ORDER BY 
    "B?rni (<18)" DESC;

SELECT 
    ms.nosaukums AS "Specialit?te",
    COUNT(CASE WHEN s.dzimums = 'V' THEN 1 END) AS "V?rieši ?rsti",
    COUNT(CASE WHEN s.dzimums = 'S' THEN 1 END) AS "Sievietes ?rstes",
    ROUND(AVG(CASE WHEN s.dzimums = 'V' THEN s.alga END), 2) AS "Vid. Alga V?riešiem",
    ROUND(AVG(CASE WHEN s.dzimums = 'S' THEN s.alga END), 2) AS "Vid. Alga Sieviet?m",
    ROUND(AVG(s.alga), 2) AS "Kop?j? Vid. Alga"
FROM 
    MedicinasSpecialisti ms
    JOIN Slimnica s ON ms.id = s.specialitate
GROUP BY 
    ms.nosaukums
ORDER BY 
    ABS(COUNT(CASE WHEN s.dzimums = 'V' THEN 1 END) - COUNT(CASE WHEN s.dzimums = 'S' THEN 1 END)) DESC;
    
SELECT 
    ms.nosaukums AS "Specialit?te",
    COUNT(CASE WHEN p.dzimums = 'V' THEN 1 END) AS "V?riešu Skaits",
    COUNT(CASE WHEN p.dzimums = 'S' THEN 1 END) AS "Sieviešu Skaits",
    ROUND(AVG(CASE WHEN p.dzimums = 'V' THEN p.svars END), 1) AS "Vid. V?riešu Svars",
    ROUND(AVG(CASE WHEN p.dzimums = 'S' THEN p.svars END), 1) AS "Vid. Sieviešu Svars",
    ROUND(AVG(p.svars), 1) AS "Kop?jais Vid. Svars",
    ROUND(STDDEV(p.svars), 2) AS "Svara Standartnovirze"
FROM 
    MedicinasSpecialisti ms
    JOIN Slimnica s ON ms.id = s.specialitate
    JOIN Pacienti p ON s.arsta_registracijas_numurs = p.arsta_registracijas_numurs
GROUP BY 
    ms.nosaukums
ORDER BY 
    ABS(COUNT(CASE WHEN p.dzimums = 'V' THEN 1 END) - 
        COUNT(CASE WHEN p.dzimums = 'S' THEN 1 END)) DESC;    