DECLARE
    v_specialitate NUMBER;
    v_personas_kods VARCHAR2(50);
    v_vecums NUMBER;
    v_dzimums CHAR(1);
    v_vards VARCHAR2(50);
    v_uzvards VARCHAR2(50);
    v_max_spec_id NUMBER;
    v_min_alga NUMBER;
    v_max_alga NUMBER;
    v_alga NUMBER;
BEGIN
    SELECT MAX(id) INTO v_max_spec_id FROM MedicinasSpecialisti;
    
    FOR i IN 1..1000 LOOP
        v_specialitate := TRUNC(DBMS_RANDOM.VALUE(1, v_max_spec_id + 1));
        
        SELECT minimala_alga, maksimala_alga 
        INTO v_min_alga, v_max_alga
        FROM MedicinasSpecialisti
        WHERE id = v_specialitate;
    
        v_alga := v_min_alga + DBMS_RANDOM.VALUE(0, v_max_alga - v_min_alga);
        v_dzimums := CASE WHEN DBMS_RANDOM.VALUE(0, 1) < 0.5 THEN 'V' ELSE 'S' END;

        IF v_dzimums = 'V' THEN
            SELECT vards INTO v_vards 
            FROM (SELECT vards FROM ViriesuVardi ORDER BY DBMS_RANDOM.VALUE) 
            WHERE ROWNUM = 1;
            
            SELECT uzvards INTO v_uzvards 
            FROM (SELECT uzvards FROM ViriesuUzvardi ORDER BY DBMS_RANDOM.VALUE) 
            WHERE ROWNUM = 1;
        ELSE
            SELECT vards INTO v_vards 
            FROM (SELECT vards FROM SievietesVardi ORDER BY DBMS_RANDOM.VALUE) 
            WHERE ROWNUM = 1;
            
            SELECT uzvards INTO v_uzvards 
            FROM (SELECT uzvards FROM SievietesUzvardi ORDER BY DBMS_RANDOM.VALUE) 
            WHERE ROWNUM = 1;
        END IF;
        
        INSERT INTO Slimnica (
            arsta_registracijas_numurs,
            vards,
            uzvards,
            dzimums,
            alga,
            specialitate
        )
        VALUES (
            i,
            v_vards,
            v_uzvards,
            v_dzimums,
            ROUND(v_alga, 2),
            v_specialitate
        );
    END LOOP;
    COMMIT;
END;
/

DECLARE
    v_personas_kods VARCHAR2(50);
    v_vecums NUMBER;
    v_svars NUMBER;
    v_dzimums CHAR(1);
    v_videjais_vecums NUMBER;
    v_arsta_reg_num NUMBER;
    v_random_factor NUMBER;
    v_deviation NUMBER;
BEGIN
    FOR i IN 1..100000 LOOP
        v_arsta_reg_num := TRUNC(DBMS_RANDOM.VALUE(1, 1001));
        v_svars := DBMS_RANDOM.VALUE(0, 150);
        v_dzimums := CASE WHEN DBMS_RANDOM.VALUE(0, 1) < 0.5 THEN 'V' ELSE 'S' END;
        
        SELECT ms.videjais_pacientu_vecums 
        INTO v_videjais_vecums
        FROM Slimnica s
        JOIN MedicinasSpecialisti ms ON s.specialitate = ms.id
        WHERE s.arsta_registracijas_numurs = v_arsta_reg_num;
        
        v_random_factor := (DBMS_RANDOM.VALUE(0, 1) + 
                           DBMS_RANDOM.VALUE(0, 1) + 
                           DBMS_RANDOM.VALUE(0, 1) +
                           DBMS_RANDOM.VALUE(0, 1)) / 2;
        
        v_deviation := (v_random_factor - 1) * 100;
        v_vecums := TRUNC(v_videjais_vecums + v_deviation);
        v_vecums := GREATEST(0, LEAST(100, v_vecums));
        
        v_personas_kods := 
            DBMS_RANDOM.STRING('N', 2) ||
            LPAD(TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(0, 13))), 2, '0') ||
            DBMS_RANDOM.STRING('N', 2) ||
            DBMS_RANDOM.STRING('N', 4) ||
            DBMS_RANDOM.STRING('N', 1);
        
        INSERT INTO Pacienti (
            personas_kods,
            arsta_registracijas_numurs,
            vecums,
            svars,
            dzimums
        )
        VALUES (
            v_personas_kods,
            v_arsta_reg_num,
            v_vecums,
            ROUND(v_svars, 0),
            v_dzimums
        );
    END LOOP;
    
    COMMIT;
END;
/