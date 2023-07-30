DROP SCHEMA IF EXISTS FLEX;
CREATE SCHEMA IF NOT EXISTS FLEX;
USE FLEX;

CREATE TABLE USERS(
    email               VARCHAR(45),
    usertype            ENUM('Client','Company') NOT NULL,
    username			VARCHAR(45),
    password            VARCHAR(45) NOT NULL,
    lastname            VARCHAR(45) NOT NULL,
    firstname           VARCHAR(45) NOT NULL,
    birthday            VARCHAR(45) NOT NULL,
    gender              ENUM('M','F'),
    addressline         VARCHAR(45) NOT NULL,
    city                VARCHAR(45) NOT NULL,
    country             VARCHAR(45) NOT NULL,
    zipcode             INT(8),
    PRIMARY KEY         (email)
);

CREATE TABLE COMPANYUSERS(
    email               VARCHAR(45),
    hiredate            DATE NOT NULL,
    leftdate            DATE,
    ec_lastname         VARCHAR(45) NOT NULL,
    ec_firstname        VARCHAR(45) NOT NULL,
    ec_address          VARCHAR(45) NOT NULL,
    ec_mobilenumber     INT(11) NULL NOT NULL,
    PRIMARY KEY         (email),
    FOREIGN KEY         (email)
        REFERENCES      USERS(email)
);

CREATE TABLE MANAGERS(
    email               VARCHAR(45),
    is_sysadmin         ENUM('Y', 'N'),
    PRIMARY KEY         (email),
    FOREIGN KEY         (email) 
        REFERENCES      USERS(email)
);
CREATE TABLE CLIENTUSERS(
    email               VARCHAR(45),
    status              ENUM('A', 'D', 'FA') NOT NULL,
    is_foreigner        ENUM('Y', 'N') NOT NULL,
    registered_through  ENUM('W', 'T') NOT NULL,
    reasons             VARCHAR(100),
    pp_no               INT(8),
    pp_country          VARCHAR(45),
    pp_expdate          DATE,
    manager_email       VARCHAR(45) NOT NULL,
    PRIMARY KEY         (email),
    FOREIGN KEY         (email)
         REFERENCES      USERS(email),
    FOREIGN KEY         (manager_email)
        REFERENCES      MANAGERS(email)          
);

CREATE TABLE SHIFTS(
    shiftcode           INT(8) UNSIGNED,
    starttime           DATE NOT NULL,
    endtime             DATE NOT NULL,
    daysofwork          VARCHAR(45),
    PRIMARY KEY         (shiftcode)
);

CREATE TABLE TRAVELOFFICERS(
    email               VARCHAR(45),
    shiftcode           INT UNSIGNED NOT NULL,
    PRIMARY KEY         (email),
    FOREIGN KEY         (shiftcode)
        REFERENCES      SHIFTS(shiftcode)
);

CREATE TABLE ISSUES(
    issues_no           INT(8),
    issues				VARCHAR(100),
    dateofissue         DATE,
    dateofresolve       DATE,
    manager_email       VARCHAR(45),
    client_email        VARCHAR(45) NOT NULL,
    PRIMARY KEY         (issues_no),
    FOREIGN KEY         (manager_email)
        REFERENCES      MANAGERS(email),
    FOREIGN KEY         (client_email)
        REFERENCES      CLIENTUSERS(email)
);

CREATE TABLE CREDITCARD(
    cc_no               INT(8),
    cc_exp              DATE,
    is_active           ENUM('Y','N'),
    client_email        VARCHAR(45) NOT NULL,
    PRIMARY KEY         (cc_no),
    FOREIGN KEY         (client_email)
        REFERENCES      CLIENTUSERS(email)
);

CREATE TABLE TGPROVIDERS(
    providerID          INT(8),
    email               VARCHAR(45) NOT NULL,
    is_active           ENUM('Y','N'),
    status              ENUM('A','D','FA'),
    f_firstname         VARCHAR(45) NOT NULL,
    f_lastname          VARCHAR(45) NOT NULL,
    yr_level            INT(1) NOT NULL,
    school_name         VARCHAR(45) NOT NULL,
    course_name         VARCHAR(45) NOT NULL,
    manager_email       VARCHAR(45) NOT NULL,
    PRIMARY KEY         (providerID),
    FOREIGN KEY         (email) 
        REFERENCES      CLIENTUSERS(email),
    FOREIGN KEY         (manager_email)
        REFERENCES      MANAGERS(email)
);

CREATE TABLE INCLUSIONS(
    inclusions_id       INT(8),
    transpo             VARCHAR(45),
    snacks              VARCHAR(45),
    entrance_fee        DECIMAL(9,2),
    PRIMARY KEY         (inclusions_id)
);

CREATE TABLE TOUR_ITEMS(
    tour_items_id       INT(8),
    descriptive         VARCHAR(100),
    tour_place          VARCHAR(45) NOT NULL,
    tour_name           VARCHAR(45),
    timeduration        INT(8) NOT NULL,
    start_time          TIME NOT NULL,
    end_date            TIME NOT NULL,
    PRIMARY KEY         (tour_items_id)
);

CREATE TABLE TOURS(
    tourid              INT(8),
    providerID          INT(8) NOT NULL,
    wholeday            ENUM('Y','N') NOT NULL,
    tour_description    VARCHAR(100),
    time_meetup         TIME NOT NULL,
    venue_meetup        VARCHAR(45) NOT NULL,
    meetup_coordinates  POINT,
    priceperperson      DECIMAL(9,2) NOT NULL,
    maxcap              INT(8) NOT NULL,
    is_offered          ENUM('Y','N') NOT NULL,
    tour_items_id       INT(8) NOT NULL,
    inclusions_id       INT(8) NOT NULL,
    PRIMARY KEY         (tourid),
    FOREIGN KEY         (providerID)
        REFERENCES      TGPROVIDERS(providerID),
    FOREIGN KEY         (tour_items_id)
        REFERENCES      TOUR_ITEMS(tour_items_id),
    FOREIGN KEY         (inclusions_id)
        REFERENCES      INCLUSIONS(inclusions_id)
);

CREATE TABLE TOUROFFERINGS(
    tourofferingscode   INT(8),
    tourofferingsdate   DATE,
    canceldate          DATE,
    confirmdate         DATE,
    maxcap              INT(8) NOT NULL,
    currparticipants    INT(8),
    tourid              INT(8) NOT NULL,
    alternativeTGP      INT(8),
    PRIMARY KEY         (tourofferingscode),
    FOREIGN KEY         (tourid)
        REFERENCES      TOURS (tourid),
    FOREIGN KEY         (alternativeTGP)
        REFERENCES      TGPROVIDERS(providerID)
);

CREATE TABLE CLIENTGROUPS(
    groupid             INT(8),
    starttime           DATE,
    endtime             DATE,
    grp_rep             VARCHAR(45) NOT NULL,
    PRIMARY KEY         (groupid),
    FOREIGN KEY         (grp_rep)
        REFERENCES      CLIENTUSERS(email)
);

CREATE TABLE BOOKINGS(
    bookingid           INT(8),
    bookdate            DATE,
    price               DECIMAL(9,2),
    confirmdate         DATE,
    canceldate          DATE,
    refunddate          DATE,
    refundamount        DECIMAL(9,2),
    lastdatemodified    DATE,
    feedback            VARCHAR(100),
    rating              ENUM ('1','2','3','4','5'),
    tourofferingscode   INT(8) NOT NULL,
    groupid             INT(8),
    client_email        VARCHAR(45),
    PRIMARY KEY (bookingid),
    FOREIGN KEY (tourofferingscode)
        REFERENCES TOUROFFERINGS (tourofferingscode),
    FOREIGN KEY (groupid)
        REFERENCES CLIENTGROUPS (groupid),
    FOREIGN KEY (client_email)
        REFERENCES CLIENTUSERS (email)
);

CREATE TABLE TRANSACTIONS(
    transid             INT(8),
    transdate           DATE,
    transamount         DECIMAL(9,2),
    transtype           ENUM('C','D'),
    cc_no               INT(8),
    bookingid           INT(8),
    PRIMARY KEY (transid),
    FOREIGN KEY (cc_no)
        REFERENCES CREDITCARD (cc_no),
    FOREIGN KEY (bookingid)
        REFERENCES BOOKINGS (bookingid)
);

CREATE TABLE FILES(
    fileid              INT(8),
    folder              VARCHAR(45) NOT NULL,
    filename            VARCHAR(45) NOT NULL,
    filetype            ENUM('D','I','V') NOT NULL,
    requirementtype     CHAR(2) NOT NULL,
    dateprocessed       DATE NOT NULL,
    daterecieved        DATE NOT NULL,
    datesubmitted       DATE NOT NULL,
    TO_email            VARCHAR(45),
    client_email        VARCHAR(45) NOT NULL,
    PRIMARY KEY (fileid),
    FOREIGN KEY (TO_email)
        REFERENCES TRAVELOFFICERS (email),
    FOREIGN KEY (client_email)
        REFERENCES CLIENTUSERS(email)
);

CREATE TABLE CELLNUMBERS(
    cellnumber      INT (11),
    email           VARCHAR(45) NOT NULL,
    PRIMARY KEY (cellnumber,email),
    FOREIGN KEY (email) 
        REFERENCES COMPANYUSERS(email)
);

CREATE TABLE GROUPINVITES(
    email           VARCHAR(45),
    groupid         INT(8),
    invitedate      DATE NOT NULL,
    accepted        ENUM ('Y','N'),
    removedate      DATE,
    PRIMARY KEY(email,groupid),
    FOREIGN KEY(email)
        REFERENCES CLIENTUSERS(email),
    FOREIGN KEY (groupid)
        REFERENCES CLIENTGROUPS(groupid)    
);
-- USER*                5
-- COMPANYUSERS*        5
-- MANAGERS*            5
-- CLIENTUSERS*         5
-- SHIFTS*              5
-- TRAVELOFFICERS*      5
-- ISSUES*              20
-- CREDICARDS*          10
-- TGPROVIDERS*         15
-- INCLUSIONS*          5
-- TOUR_ITEMS*          5
-- TOURS                50
-- TOUROFFERINGS        100
-- CLIENTGROUPS         10
-- BOOKINGS             230
-- TRANSACIONS          460
-- FILES                20
-- CELLNUMBERS          10
-- GROUPINVITES;        30
