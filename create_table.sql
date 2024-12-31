CREATE TABLE Slimnica (
    arsta_registracijas_numurs NUMBER PRIMARY KEY,
    vards VARCHAR2(50),
    uzvards VARCHAR2(50),
    dzimums CHAR(1),
    alga NUMBER,
    specialitate NUMBER
);

CREATE TABLE Pacienti (
    personas_kods VARCHAR2(50),
    arsta_registracijas_numurs NUMBER,
    vecums NUMBER,
    svars NUMBER,
    dzimums CHAR(1),
    FOREIGN KEY ( arsta_registracijas_numurs )
    REFERENCES Slimnica ( arsta_registracijas_numurs )
);