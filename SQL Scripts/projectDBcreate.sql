-- DDL script to create tables, constraints, and database triggers to enforce constraints

-- MOVIE table
CREATE TABLE Spring25_S003_T6_MOVIE (
    Movie_ID VARCHAR(50) PRIMARY KEY,
    Title VARCHAR(255) NOT NULL,
    Genre VARCHAR(100) NOT NULL CHECK (Genre IN (
        'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy',
        'Horror', 'Mystery', 'Romance', 'Sci-Fi', 'Thriller'
    )),
    Critics_score DECIMAL(4,2) CHECK (Critics_score BETWEEN 0 AND 10),
    Runtime INT NOT NULL CHECK (Runtime > 0),
    Release_year INT NOT NULL CHECK (Release_year >= 1888),
    Censor_rating VARCHAR(10)
);

-- SUBSCRIPTION_TIER table
CREATE TABLE Spring25_S003_T6_SUBSCRIPTION_TIER (
    Tier_ID VARCHAR(50) PRIMARY KEY,
    Tier_name VARCHAR(100) NOT NULL UNIQUE,
    Tier_price DECIMAL(6,2) CHECK (Tier_price >= 0),
    Currency VARCHAR(10) NOT NULL,
    Ad_frequency VARCHAR(50) NOT NULL,
    Video_quality VARCHAR(50) NOT NULL,
    Audio_quality VARCHAR(50) NOT NULL,
    N_devices INT CHECK (N_devices > 0)
);

-- ACTOR table
CREATE TABLE Spring25_S003_T6_ACTOR (
    Actor_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    DOB DATE NOT NULL,
    Nationality VARCHAR(100) NOT NULL
);

-- ACCOUNT table
CREATE TABLE Spring25_S003_T6_ACCOUNT (
    Account_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    DOB DATE NOT NULL,
    Email VARCHAR(255) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Subscription_Tier_ID VARCHAR(50),
    Subscription_date DATE,
    Auto_renew CHAR(1) NOT NULL CHECK (Auto_renew IN ('Y', 'N')),
    FOREIGN KEY (Subscription_Tier_ID)
        REFERENCES Spring25_S003_T6_SUBSCRIPTION_TIER(Tier_ID)
        ON DELETE SET NULL
);

-- DEVICE table 
CREATE TABLE Spring25_S003_T6_DEVICE (
    Device_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Model VARCHAR(100) NOT NULL,
    Type VARCHAR(50) NOT NULL CHECK (Type IN ('TV', 'PC', 'Mobile', 'Console')),
    OS VARCHAR(100) NOT NULL,
    HDR CHAR(1) NOT NULL CHECK (HDR IN ('Y', 'N')),
    Screen_resolution VARCHAR(50) NOT NULL,
    Device_linked_date DATE NOT NULL,
    Linked_Account_ID VARCHAR(50) NOT NULL,
    FOREIGN KEY (Linked_Account_ID)
        REFERENCES Spring25_S003_T6_ACCOUNT(Account_ID)
        ON DELETE CASCADE
);

-- USER_PROFILE table
CREATE TABLE Spring25_S003_T6_USER_PROFILE (
    Profile_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    DOB DATE NOT NULL,
    Gender VARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    Account_ID VARCHAR(50) NOT NULL,
    FOREIGN KEY (Account_ID)
        REFERENCES Spring25_S003_T6_ACCOUNT(Account_ID)
        ON DELETE CASCADE
);

-- STARRING table
CREATE TABLE Spring25_S003_T6_Starring (
    Movie_ID VARCHAR(50),
    Actor_ID VARCHAR(50),
    PRIMARY KEY (Movie_ID, Actor_ID),
    FOREIGN KEY (Movie_ID) REFERENCES Spring25_S003_T6_MOVIE(Movie_ID) ON DELETE CASCADE,
    FOREIGN KEY (Actor_ID) REFERENCES Spring25_S003_T6_ACTOR(Actor_ID) ON DELETE CASCADE
);

-- MOVIE_Audio_Languages table
CREATE TABLE Spring25_S003_T6_MOVIE_Audio_Languages (
    Movie_ID VARCHAR(50),
    Audio_Languages VARCHAR(50),
    PRIMARY KEY (Movie_ID, Audio_Languages),
    FOREIGN KEY (Movie_ID) REFERENCES Spring25_S003_T6_MOVIE(Movie_ID) ON DELETE CASCADE
);

-- MOVIE_Subtitle_Languages table
CREATE TABLE Spring25_S003_T6_MOVIE_Subtitle_Languages (
    Movie_ID VARCHAR(50),
    Subtitle_Languages VARCHAR(50),
    PRIMARY KEY (Movie_ID, Subtitle_Languages),
    FOREIGN KEY (Movie_ID) REFERENCES Spring25_S003_T6_MOVIE(Movie_ID) ON DELETE CASCADE
);

-- PAYMENT table
CREATE TABLE Spring25_S003_T6_PAYMENT (
    Payment_ID VARCHAR(50) PRIMARY KEY,
    Type VARCHAR(50) NOT NULL CHECK (Type IN (
        'First-Time Subscription',
        'Reactivated Subscription',
        'Auto-renewal',
        'Tier Upgrade',
        'Tier downgrade'
    )),
    Method VARCHAR(50) NOT NULL CHECK (Method IN (
        'Credit Card',
        'E-check',
        'PayPal',
        'Apple Pay',
        'Venmo',
        'Google Pay'
    )),
    Tax_Rate DECIMAL(5,2) NOT NULL CHECK (Tax_Rate >= 0),
    Discount_code VARCHAR(50),
    Discount_rate DECIMAL(5,2) CHECK (Discount_rate BETWEEN 0 AND 1),
    Currency_used VARCHAR(10) NOT NULL,
    Account_ID VARCHAR(50) NOT NULL,
    Timestamp TIMESTAMP NOT NULL,
    Subscription_Tier_ID VARCHAR(50) NOT NULL,
    FOREIGN KEY (Account_ID) REFERENCES Spring25_S003_T6_ACCOUNT(Account_ID) ON DELETE CASCADE,
    FOREIGN KEY (Subscription_Tier_ID) REFERENCES Spring25_S003_T6_SUBSCRIPTION_TIER(Tier_ID) ON DELETE CASCADE,
    CONSTRAINT uq_payment_account_timestamp UNIQUE (Account_ID, Timestamp)
);


-- WATCH_SESSION table 
CREATE TABLE Spring25_S003_T6_WATCH_SESSION (
    Session_ID VARCHAR(50) PRIMARY KEY,
    Start_timestamp TIMESTAMP NOT NULL,
    Stop_timestamp TIMESTAMP NOT NULL,
    IP_Address VARCHAR(50) NOT NULL,
    Movie_ID VARCHAR(50) NOT NULL,
    Device_ID VARCHAR(50) NOT NULL,
    Profile_ID VARCHAR(50) NOT NULL,
    FOREIGN KEY (Movie_ID) REFERENCES Spring25_S003_T6_MOVIE(Movie_ID) ON DELETE SET NULL,
    FOREIGN KEY (Device_ID) REFERENCES Spring25_S003_T6_DEVICE(Device_ID) ON DELETE SET NULL,
    FOREIGN KEY (Profile_ID) REFERENCES Spring25_S003_T6_USER_PROFILE(Profile_ID) ON DELETE SET NULL
);

-- TRRIGGERS TO ENFORCE RELATIONAL INTEGRITY CONSTRAINTS

-- Trigger: Ensure valid Subscription_Tier_ID in ACCOUNT table
CREATE OR REPLACE TRIGGER trg_account_subscription_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_ACCOUNT
FOR EACH ROW
WHEN (NEW.Subscription_Tier_ID IS NOT NULL)
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Spring25_S003_T6_SUBSCRIPTION_TIER
    WHERE Tier_ID = :NEW.Subscription_Tier_ID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Invalid Subscription_Tier_ID');
    END IF;
END;
/

-- Trigger: Ensure valid Account_ID in USER_PROFILE table
CREATE OR REPLACE TRIGGER trg_user_profile_account_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_USER_PROFILE
FOR EACH ROW
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Spring25_S003_T6_ACCOUNT
    WHERE Account_ID = :NEW.Account_ID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'Invalid Account_ID for USER_PROFILE');
    END IF;
END;
/

-- Trigger: Ensure valid Linked_Account_ID in DEVICE table
CREATE OR REPLACE TRIGGER trg_device_account_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_DEVICE
FOR EACH ROW
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Spring25_S003_T6_ACCOUNT
    WHERE Account_ID = :NEW.Linked_Account_ID;

    IF v_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'Invalid Linked_Account_ID for DEVICE');
    END IF;
END;
/

-- Trigger: Ensure valid Movie_ID, Device_ID, and Profile_ID in WATCH_SESSION table
CREATE OR REPLACE TRIGGER trg_watch_session_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_WATCH_SESSION
FOR EACH ROW
DECLARE
    v_count_movie INT;
    v_count_device INT;
    v_count_profile INT;
BEGIN
    SELECT COUNT(*) INTO v_count_movie
    FROM Spring25_S003_T6_MOVIE
    WHERE Movie_ID = :NEW.Movie_ID;
    
    IF v_count_movie = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Invalid Movie_ID');
    END IF;

    SELECT COUNT(*) INTO v_count_device
    FROM Spring25_S003_T6_DEVICE
    WHERE Device_ID = :NEW.Device_ID;

    IF v_count_device = 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Invalid Device_ID');
    END IF;

    SELECT COUNT(*) INTO v_count_profile
    FROM Spring25_S003_T6_USER_PROFILE
    WHERE Profile_ID = :NEW.Profile_ID;

    IF v_count_profile = 0 THEN
        RAISE_APPLICATION_ERROR(-20006, 'Invalid Profile_ID');
    END IF;
END;
/

-- Trigger: Ensure valid Account_ID and Subscription_Tier_ID in PAYMENT table
CREATE OR REPLACE TRIGGER trg_payment_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_PAYMENT
FOR EACH ROW
DECLARE
    v_count_account INT;
    v_count_tier INT;
BEGIN
    SELECT COUNT(*) INTO v_count_account
    FROM Spring25_S003_T6_ACCOUNT
    WHERE Account_ID = :NEW.Account_ID;

    IF v_count_account = 0 THEN
        RAISE_APPLICATION_ERROR(-20007, 'Invalid Account_ID in PAYMENT');
    END IF;

    SELECT COUNT(*) INTO v_count_tier
    FROM Spring25_S003_T6_SUBSCRIPTION_TIER
    WHERE Tier_ID = :NEW.Subscription_Tier_ID;

    IF v_count_tier = 0 THEN
        RAISE_APPLICATION_ERROR(-20008, 'Invalid Subscription_Tier_ID in PAYMENT');
    END IF;
END;
/

-- Trigger: Ensure valid Movie_ID in MOVIE_Audio_Languages table
CREATE OR REPLACE TRIGGER trg_audio_lang_movie_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_MOVIE_Audio_Languages
FOR EACH ROW
DECLARE
    v_count_movie INT;
BEGIN
    SELECT COUNT(*) INTO v_count_movie
    FROM Spring25_S003_T6_MOVIE
    WHERE Movie_ID = :NEW.Movie_ID;

    IF v_count_movie = 0 THEN
        RAISE_APPLICATION_ERROR(-20009, 'Invalid Movie_ID in MOVIE_Audio_Languages');
    END IF;
END;
/

-- Trigger: Ensure valid Movie_ID in MOVIE_Subtitle_Languages table
CREATE OR REPLACE TRIGGER trg_subtitle_lang_movie_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_MOVIE_Subtitle_Languages
FOR EACH ROW
DECLARE
    v_count_movie INT;
BEGIN
    SELECT COUNT(*) INTO v_count_movie
    FROM Spring25_S003_T6_MOVIE
    WHERE Movie_ID = :NEW.Movie_ID;

    IF v_count_movie = 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Invalid Movie_ID in MOVIE_Subtitle_Languages');
    END IF;
END;
/

-- Trigger: Ensure valid Movie_ID and Actor_ID in STARRING table
CREATE OR REPLACE TRIGGER trg_starring_fk
BEFORE INSERT OR UPDATE ON Spring25_S003_T6_Starring
FOR EACH ROW
DECLARE
    v_count_movie INT;
    v_count_actor INT;
BEGIN
    SELECT COUNT(*) INTO v_count_movie
    FROM Spring25_S003_T6_MOVIE
    WHERE Movie_ID = :NEW.Movie_ID;

    IF v_count_movie = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Invalid Movie_ID in STARRING');
    END IF;

    SELECT COUNT(*) INTO v_count_actor
    FROM Spring25_S003_T6_ACTOR
    WHERE Actor_ID = :NEW.Actor_ID;

    IF v_count_actor = 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Invalid Actor_ID in STARRING');
    END IF;
END;
/

-- TRRIGGERS TO ENFORCE BUSINESS-SPECIFIC CONSTRAINTS

--Trigger: Prevent deleting the last user profile of an account
CREATE OR REPLACE TRIGGER trg_restrict_last_profile_delete
BEFORE DELETE ON Spring25_S003_T6_USER_PROFILE
FOR EACH ROW
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM Spring25_S003_T6_USER_PROFILE
    WHERE Account_ID = :OLD.Account_ID;

    IF v_count = 1 THEN
        RAISE_APPLICATION_ERROR(-20100, 'Cannot delete the last user profile of an account.');
    END IF;
END;
/

-- Trigger: Enforce 1 ≤ #devices ≤ N_devices per account
CREATE OR REPLACE TRIGGER trg_enforce_device_count
BEFORE INSERT OR DELETE ON Spring25_S003_T6_DEVICE
FOR EACH ROW
DECLARE
    v_count INT;
    v_max_devices INT := 1;  -- default max
BEGIN
    -- On DELETE: check min 1 device
    IF DELETING THEN
        SELECT COUNT(*) INTO v_count
        FROM Spring25_S003_T6_DEVICE
        WHERE Linked_Account_ID = :OLD.Linked_Account_ID;

        IF v_count = 1 THEN
            RAISE_APPLICATION_ERROR(-20105, 'Each account must have at least one linked device.');
        END IF;
    END IF;

    -- On INSERT: check max N_devices allowed
    IF INSERTING THEN
        -- Get current count of devices linked to this account
        SELECT COUNT(*) INTO v_count
        FROM Spring25_S003_T6_DEVICE
        WHERE Linked_Account_ID = :NEW.Linked_Account_ID;

        -- Try to get N_devices from the subscription tier, if present
        BEGIN
            SELECT T.N_devices INTO v_max_devices
            FROM Spring25_S003_T6_ACCOUNT A
            JOIN Spring25_S003_T6_SUBSCRIPTION_TIER T
              ON A.Subscription_Tier_ID = T.Tier_ID
            WHERE A.Account_ID = :NEW.Linked_Account_ID;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                v_max_devices := 1;  -- fallback default
        END;

        IF v_count >= v_max_devices THEN
            RAISE_APPLICATION_ERROR(-20106, 'Device limit exceeded for this account’s subscription tier.');
        END IF;
    END IF;
END;
/

-- Trigger: Prevent deletion from STARRING if it causes a movie or actor to be unlinked
CREATE OR REPLACE TRIGGER trg_restrict_orphan_starring
BEFORE DELETE ON Spring25_S003_T6_Starring
FOR EACH ROW
DECLARE
    v_count_movie INT;
    v_count_actor INT;
BEGIN
    SELECT COUNT(*) INTO v_count_movie
    FROM Spring25_S003_T6_Starring
    WHERE Movie_ID = :OLD.Movie_ID;

    SELECT COUNT(*) INTO v_count_actor
    FROM Spring25_S003_T6_Starring
    WHERE Actor_ID = :OLD.Actor_ID;

    IF v_count_movie = 1 THEN
        RAISE_APPLICATION_ERROR(-20102, 'Cannot remove the last actor from a movie.');
    ELSIF v_count_actor = 1 THEN
        RAISE_APPLICATION_ERROR(-20103, 'Cannot remove the last movie from an actor.');
    END IF;
END;
/