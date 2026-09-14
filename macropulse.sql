


/* ============================================================
   1. DATABASE
   ============================================================ */

DROP DATABASE IF EXISTS macropulse;

CREATE DATABASE macropulse
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE macropulse;


/* ============================================================
   2. COUNTRIES
   ============================================================ */

CREATE TABLE countries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    income_group VARCHAR(50)
);


/* ============================================================
   3. COMMODITIES
   ============================================================ */

CREATE TABLE commodities (
    commodity_id INT AUTO_INCREMENT PRIMARY KEY,

    commodity_name VARCHAR(100) NOT NULL,

    category VARCHAR(100),

    strategic_importance DECIMAL(5,2) DEFAULT 0,

    description VARCHAR(255)
);


/* ============================================================
   4. ECONOMIC SECTORS
   ============================================================ */

CREATE TABLE economic_sectors (
    sector_id INT AUTO_INCREMENT PRIMARY KEY,

    sector_name VARCHAR(100) NOT NULL,

    strategic_importance DECIMAL(5,2) DEFAULT 0,

    description VARCHAR(255)
);


/* ============================================================
   5. RAW GDELT EVENTS
   ============================================================ */

CREATE TABLE raw_events (

    global_event_id BIGINT PRIMARY KEY,

    event_date DATE NOT NULL,

    date_added DATETIME NOT NULL,

    actor1_name VARCHAR(255),

    actor1_country_code CHAR(3),

    actor2_name VARCHAR(255),

    actor2_country_code CHAR(3),

    event_code VARCHAR(4),

    event_base_code VARCHAR(3),

    event_root_code VARCHAR(2),

    quad_class TINYINT,

    goldstein_scale DECIMAL(5,2),

    num_mentions INT,

    num_sources INT,

    num_articles INT,

    avg_tone DECIMAL(8,4),

    action_country_code CHAR(2),

    latitude DECIMAL(10,6),

    longitude DECIMAL(10,6),

    source_url TEXT,

    imported_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_event_date (event_date),
    INDEX idx_date_added (date_added),
    INDEX idx_root_code (event_root_code),
    INDEX idx_action_country (action_country_code)

);


/* ============================================================
   6. EVENT CLASSIFICATION RULES
   ============================================================ */

CREATE TABLE event_classification_rules (

    rule_id INT AUTO_INCREMENT PRIMARY KEY,

    event_root_code VARCHAR(2) NOT NULL,

    classification VARCHAR(100) NOT NULL,

    economic_relevance DECIMAL(5,2) DEFAULT 0,

    description VARCHAR(255),

    UNIQUE KEY uq_root_classification (event_root_code)

);


/* ============================================================
   7. MAJOR EVENTS
   ============================================================ */

CREATE TABLE major_events (

    major_event_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    global_event_id BIGINT NOT NULL,

    significance_score DECIMAL(5,2) NOT NULL,

    significance_level ENUM(
        'REGIONAL',
        'MAJOR',
        'GLOBAL',
        'SYSTEMIC'
    ) NOT NULL,

    classification VARCHAR(100) NOT NULL,

    economic_relevance DECIMAL(5,2) DEFAULT 0,

    detected_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (global_event_id)
        REFERENCES raw_events(global_event_id),

    UNIQUE KEY uq_major_event (global_event_id),

    INDEX idx_significance (significance_score),
    INDEX idx_level (significance_level),
    INDEX idx_classification (classification)

);


/* ============================================================
   8. EVENT → COUNTRIES
   ============================================================ */

CREATE TABLE event_countries (

    major_event_id BIGINT NOT NULL,

    country_code CHAR(2) NOT NULL,

    impact_role ENUM(
        'ACTOR',
        'TARGET',
        'AFFECTED',
        'EXPOSED'
    ) DEFAULT 'AFFECTED',

    exposure_score DECIMAL(5,2) DEFAULT 0,

    PRIMARY KEY (
        major_event_id,
        country_code,
        impact_role
    ),

    FOREIGN KEY (major_event_id)
        REFERENCES major_events(major_event_id),

    FOREIGN KEY (country_code)
        REFERENCES countries(country_code)
);


/* ============================================================
   9. EVENT → COMMODITIES
   ============================================================ */

CREATE TABLE event_commodities (

    major_event_id BIGINT NOT NULL,

    commodity_id INT NOT NULL,

    impact_score DECIMAL(5,2) DEFAULT 0,

    impact_type ENUM(
        'SUPPLY',
        'DEMAND',
        'PRICE',
        'TRADE',
        'TRANSPORT',
        'STRATEGIC'
    ) DEFAULT 'STRATEGIC',

    PRIMARY KEY (
        major_event_id,
        commodity_id
    ),

    FOREIGN KEY (major_event_id)
        REFERENCES major_events(major_event_id),

    FOREIGN KEY (commodity_id)
        REFERENCES commodities(commodity_id)
);


/* ============================================================
   10. EVENT → ECONOMIC SECTORS
   ============================================================ */

CREATE TABLE event_sectors (

    major_event_id BIGINT NOT NULL,

    sector_id INT NOT NULL,

    impact_score DECIMAL(5,2) DEFAULT 0,

    impact_direction ENUM(
        'NEGATIVE',
        'POSITIVE',
        'MIXED'
    ) DEFAULT 'NEGATIVE',

    PRIMARY KEY (
        major_event_id,
        sector_id
    ),

    FOREIGN KEY (major_event_id)
        REFERENCES major_events(major_event_id),

    FOREIGN KEY (sector_id)
        REFERENCES economic_sectors(sector_id)
);


/* ============================================================
   11. TRADE / SUPPLY-CHAIN EXPOSURE
   ============================================================ */

CREATE TABLE trade_exposure (

    exposure_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    major_event_id BIGINT NOT NULL,

    country_code CHAR(2) NOT NULL,

    commodity_id INT,

    sector_id INT,

    exposure_percent DECIMAL(7,2),

    dependency_score DECIMAL(5,2),

    estimated_impact DECIMAL(5,2),

    exposure_type ENUM(
        'IMPORT',
        'EXPORT',
        'TRANSIT',
        'SUPPLY_CHAIN',
        'ENERGY_DEPENDENCY',
        'FOOD_DEPENDENCY'
    ),

    FOREIGN KEY (major_event_id)
        REFERENCES major_events(major_event_id),

    FOREIGN KEY (country_code)
        REFERENCES countries(country_code),

    FOREIGN KEY (commodity_id)
        REFERENCES commodities(commodity_id),

    FOREIGN KEY (sector_id)
        REFERENCES economic_sectors(sector_id),

    INDEX idx_exposure_country (country_code),
    INDEX idx_exposure_score (estimated_impact)

);


/* ============================================================
   12. ECONOMIC INDICATORS
   ============================================================ */

CREATE TABLE economic_indicators (

    indicator_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    country_code CHAR(2) NOT NULL,

    indicator_date DATE NOT NULL,

    indicator_name VARCHAR(100) NOT NULL,

    indicator_value DECIMAL(18,4),

    unit VARCHAR(50),

    source_name VARCHAR(100),

    FOREIGN KEY (country_code)
        REFERENCES countries(country_code),

    INDEX idx_indicator_country_date (
        country_code,
        indicator_date
    )

);


/* ============================================================
   13. EVENT IMPACT ASSESSMENT
   ============================================================ */

CREATE TABLE impact_assessments (

    assessment_id BIGINT AUTO_INCREMENT PRIMARY KEY,

    major_event_id BIGINT NOT NULL,

    impact_score DECIMAL(5,2) NOT NULL,

    economic_risk ENUM(
        'LOW',
        'MODERATE',
        'HIGH',
        'SEVERE',
        'CRITICAL'
    ) NOT NULL,

    assessment_reason TEXT,

    assessed_at DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (major_event_id)
        REFERENCES major_events(major_event_id),

    UNIQUE KEY uq_event_assessment (major_event_id)

);


/* ============================================================
   14. COUNTRIES
   ============================================================ */

INSERT INTO countries
(country_code, country_name, region, income_group)
VALUES

('MA', 'Morocco', 'Africa', 'Upper-middle'),
('US', 'United States', 'North America', 'High'),
('CN', 'China', 'Asia', 'Upper-middle'),
('DE', 'Germany', 'Europe', 'High'),
('FR', 'France', 'Europe', 'High'),
('GB', 'United Kingdom', 'Europe', 'High'),
('JP', 'Japan', 'Asia', 'High'),
('IN', 'India', 'Asia', 'Lower-middle'),
('BR', 'Brazil', 'South America', 'Upper-middle'),
('SA', 'Saudi Arabia', 'Middle East', 'High');


/* ============================================================
   15. COMMODITIES
   ============================================================ */

INSERT INTO commodities
(commodity_name, category, strategic_importance, description)
VALUES

('Crude Oil',
 'Energy',
 100,
 'Strategic global energy commodity'),

('Natural Gas',
 'Energy',
 100,
 'Major energy and industrial input'),

('Wheat',
 'Agriculture',
 90,
 'Strategic food commodity'),

('Corn',
 'Agriculture',
 80,
 'Major agricultural commodity'),

('Semiconductors',
 'Technology',
 100,
 'Critical strategic technology input'),

('Rare Earth Elements',
 'Minerals',
 100,
 'Strategic minerals for advanced industries'),

('Copper',
 'Metals',
 85,
 'Important industrial metal'),

('Gold',
 'Precious Metals',
 75,
 'Financial and strategic asset');


/* ============================================================
   16. ECONOMIC SECTORS
   ============================================================ */

INSERT INTO economic_sectors
(sector_name, strategic_importance, description)
VALUES

('Energy',
 100,
 'Oil, gas and electricity'),

('Manufacturing',
 90,
 'Industrial production'),

('Technology',
 100,
 'Technology and semiconductor industries'),

('Agriculture',
 90,
 'Food and agricultural production'),

('Financial Services',
 85,
 'Banking and financial markets'),

('Transportation',
 95,
 'Shipping, logistics and transport'),

('Defense',
 95,
 'Defense and military industries'),

('Automotive',
 90,
 'Vehicle manufacturing and supply chains'),

('Pharmaceuticals',
 85,
 'Medicine and pharmaceutical production'),

('Construction',
 75,
 'Infrastructure and construction');


/* ============================================================
   17. CAMEO-BASED CLASSIFICATION RULES
   ============================================================

   These are broad event-family rules.

   17 = COERCION
   18 = ASSAULT
   19 = FIGHT
   20 = UNCONVENTIONAL MASS VIOLENCE

   13 = THREATEN
   14 = PROTEST
   15 = EXHIBIT FORCE POSTURE
   16 = REDUCE RELATIONS

   03-08 = COOPERATION / DIPLOMATIC ACTIONS

   NOTE:
   Economic categories such as sanctions, tariffs, export bans,
   etc. will later be refined using specific event codes.
   ============================================================ */

INSERT INTO event_classification_rules
(event_root_code, classification, economic_relevance, description)
VALUES

('03',
 'COOPERATION',
 35,
 'Express intent to cooperate'),

('04',
 'CONSULTATION',
 35,
 'Consultation between actors'),

('05',
 'DIPLOMATIC_COOPERATION',
 40,
 'Diplomatic cooperation'),

('06',
 'MATERIAL_COOPERATION',
 55,
 'Material cooperation'),

('07',
 'AID',
 60,
 'Provision of assistance'),

('08',
 'YIELD',
 50,
 'Yield or concession'),

('13',
 'THREAT',
 75,
 'Threatening action'),

('14',
 'PROTEST',
 55,
 'Political protest'),

('15',
 'FORCE_POSTURE',
 80,
 'Military force posture'),

('16',
 'RELATIONS_REDUCTION',
 85,
 'Reduction in diplomatic relations'),

('17',
 'COERCION',
 95,
 'Coercive action'),

('18',
 'ASSAULT',
 95,
 'Physical assault'),

('19',
 'FIGHT',
 100,
 'Military or physical conflict'),

('20',
 'MASS_VIOLENCE',
 100,
 'Unconventional or mass violence');


/* ============================================================
   18. TEST EVENTS
   ============================================================ */

INSERT INTO raw_events
(
    global_event_id,
    event_date,
    date_added,
    actor1_name,
    actor1_country_code,
    actor2_name,
    actor2_country_code,
    event_code,
    event_base_code,
    event_root_code,
    quad_class,
    goldstein_scale,
    num_mentions,
    num_sources,
    num_articles,
    avg_tone,
    action_country_code,
    latitude,
    longitude,
    source_url
)

VALUES

(
    1000001,
    '2026-09-09',
    '2026-09-09 09:00:00',
    'Country A',
    'AAA',
    'Country B',
    'BBB',
    '172',
    '172',
    '17',
    4,
    -8.5,
    250,
    35,
    120,
    -6.20,
    'MA',
    33.5731,
    -7.5898,
    'https://example.com/event1'
),

(
    1000002,
    '2026-09-09',
    '2026-09-09 09:15:00',
    'Country C',
    'CCC',
    'Country D',
    'DDD',
    '030',
    '030',
    '03',
    1,
    2.5,
    15,
    3,
    8,
    1.20,
    'US',
    38.9072,
    -77.0369,
    'https://example.com/event2'
),

(
    1000003,
    '2026-09-09',
    '2026-09-09 09:30:00',
    'Country E',
    'EEE',
    'Country F',
    'FFF',
    '070',
    '070',
    '07',
    3,
    -4.0,
    100,
    18,
    60,
    -3.50,
    'CN',
    39.9042,
    116.4074,
    'https://example.com/event3'
);


/* ============================================================
   19. CREATE MAJOR EVENTS
   ============================================================ */

INSERT INTO major_events
(
    global_event_id,
    significance_score,
    significance_level,
    classification,
    economic_relevance
)

SELECT

    r.global_event_id,

    LEAST(

        100,

        (
            CASE
                WHEN r.quad_class = 4 THEN 30
                WHEN r.quad_class = 3 THEN 20
                WHEN r.quad_class = 2 THEN 10
                ELSE 5
            END

            +

            CASE
                WHEN r.num_sources >= 30 THEN 25
                WHEN r.num_sources >= 15 THEN 20
                WHEN r.num_sources >= 5 THEN 12
                WHEN r.num_sources >= 2 THEN 6
                ELSE 0
            END

            +

            CASE
                WHEN r.num_articles >= 100 THEN 20
                WHEN r.num_articles >= 50 THEN 15
                WHEN r.num_articles >= 20 THEN 10
                WHEN r.num_articles >= 5 THEN 5
                ELSE 0
            END

            +
            CASE
                WHEN r.num_mentions >= 200 THEN 15
                WHEN r.num_mentions >= 100 THEN 12
                WHEN r.num_mentions >= 50 THEN 8
                WHEN r.num_mentions >= 10 THEN 4
                ELSE 0
            END

            +

            CASE
                WHEN r.goldstein_scale <= -7 THEN 10
                WHEN r.goldstein_scale <= -4 THEN 7
                WHEN r.goldstein_scale <= -2 THEN 4
                ELSE 0
            END
        )

    ) AS significance_score,

    CASE

        WHEN
        (
            CASE
                WHEN r.quad_class = 4 THEN 30
                WHEN r.quad_class = 3 THEN 20
                WHEN r.quad_class = 2 THEN 10
                ELSE 5
            END

            +
            CASE
                WHEN r.num_sources >= 30 THEN 25
                WHEN r.num_sources >= 15 THEN 20
                WHEN r.num_sources >= 5 THEN 12
                WHEN r.num_sources >= 2 THEN 6
                ELSE 0
            END

            +
            CASE
                WHEN r.num_articles >= 100 THEN 20
                WHEN r.num_articles >= 50 THEN 15
                WHEN r.num_articles >= 20 THEN 10
                WHEN r.num_articles >= 5 THEN 5
                ELSE 0
            END

            +
            CASE
                WHEN r.num_mentions >= 200 THEN 15
                WHEN r.num_mentions >= 100 THEN 12
                WHEN r.num_mentions >= 50 THEN 8
                WHEN r.num_mentions >= 10 THEN 4
                ELSE 0
            END

            +
            CASE
                WHEN r.goldstein_scale <= -7 THEN 10
                WHEN r.goldstein_scale <= -4 THEN 7
                WHEN r.goldstein_scale <= -2 THEN 4
                ELSE 0
            END

        ) >= 80

        THEN 'GLOBAL'


        WHEN
        (
            CASE
                WHEN r.quad_class = 4 THEN 30
                WHEN r.quad_class = 3 THEN 20
                WHEN r.quad_class = 2 THEN 10
                ELSE 5
            END

            +
            CASE
                WHEN r.num_sources >= 30 THEN 25
                WHEN r.num_sources >= 15 THEN 20
                WHEN r.num_sources >= 5 THEN 12
                WHEN r.num_sources >= 2 THEN 6
                ELSE 0
            END

            +
            CASE
                WHEN r.num_articles >= 100 THEN 20
                WHEN r.num_articles >= 50 THEN 15
                WHEN r.num_articles >= 20 THEN 10
                WHEN r.num_articles >= 5 THEN 5
                ELSE 0
            END

            +
            CASE
                WHEN r.num_mentions >= 200 THEN 15
                WHEN r.num_mentions >= 100 THEN 12
                WHEN r.num_mentions >= 50 THEN 8
                WHEN r.num_mentions >= 10 THEN 4
                ELSE 0
            END

            +
            CASE
                WHEN r.goldstein_scale <= -7 THEN 10
                WHEN r.goldstein_scale <= -4 THEN 7
                WHEN r.goldstein_scale <= -2 THEN 4
                ELSE 0
            END

        ) >= 60

        THEN 'MAJOR'

        ELSE 'REGIONAL'

    END AS significance_level,

    COALESCE(
        c.classification,
        'UNCLASSIFIED'
    ) AS classification,

    COALESCE(
        c.economic_relevance,
        0
    ) AS economic_relevance

FROM raw_events r

LEFT JOIN event_classification_rules c
    ON r.event_root_code = c.event_root_code

WHERE

(
    CASE
        WHEN r.quad_class = 4 THEN 30
        WHEN r.quad_class = 3 THEN 20
        WHEN r.quad_class = 2 THEN 10
        ELSE 5
    END

    +

    CASE
        WHEN r.num_sources >= 30 THEN 25
        WHEN r.num_sources >= 15 THEN 20
        WHEN r.num_sources >= 5 THEN 12
        WHEN r.num_sources >= 2 THEN 6
        ELSE 0
    END

    +

    CASE
        WHEN r.num_articles >= 100 THEN 20
        WHEN r.num_articles >= 50 THEN 15
        WHEN r.num_articles >= 20 THEN 10
        WHEN r.num_articles >= 5 THEN 5
        ELSE 0
    END

    +

    CASE
        WHEN r.num_mentions >= 200 THEN 15
        WHEN r.num_mentions >= 100 THEN 12
        WHEN r.num_mentions >= 50 THEN 8
        WHEN r.num_mentions >= 10 THEN 4
        ELSE 0
    END

    +

    CASE
        WHEN r.goldstein_scale <= -7 THEN 10
        WHEN r.goldstein_scale <= -4 THEN 7
        WHEN r.goldstein_scale <= -2 THEN 4
        ELSE 0
    END

) >= 40;


/* ============================================================
   20. TEST COUNTRY EXPOSURE
   ============================================================ */

INSERT INTO event_countries
(
    major_event_id,
    country_code,
    impact_role,
    exposure_score
)

SELECT
    m.major_event_id,
    r.action_country_code,
    'AFFECTED',
    m.significance_score

FROM major_events m

JOIN raw_events r
    ON m.global_event_id = r.global_event_id

WHERE r.action_country_code IN
(
    SELECT country_code
    FROM countries
);


/* ============================================================
   21. TEST COMMODITY LINKS
   ============================================================ */

INSERT INTO event_commodities
(
    major_event_id,
    commodity_id,
    impact_score,
    impact_type
)

SELECT
    m.major_event_id,
    c.commodity_id,
    m.significance_score,
    'STRATEGIC'

FROM major_events m

JOIN commodities c
    ON c.commodity_name = 'Crude Oil'

WHERE m.classification IN
(
    'COERCION',
    'ASSAULT',
    'FIGHT',
    'MASS_VIOLENCE'
);


/* ============================================================
   22. TEST SECTOR LINKS
   ============================================================ */

INSERT INTO event_sectors
(
    major_event_id,
    sector_id,
    impact_score,
    impact_direction
)

SELECT
    m.major_event_id,
    s.sector_id,
    m.significance_score,
    'NEGATIVE'

FROM major_events m

JOIN economic_sectors s
    ON s.sector_name = 'Energy'

WHERE m.classification IN
(
    'COERCION',
    'ASSAULT',
    'FIGHT',
    'MASS_VIOLENCE'
);


/* ============================================================
   23. IMPACT ASSESSMENT
   ============================================================ */

INSERT INTO impact_assessments
(
    major_event_id,
    impact_score,
    economic_risk,
    assessment_reason
)

SELECT

    m.major_event_id,

    LEAST(
        100,
        (
            m.significance_score * 0.60
            +
            m.economic_relevance * 0.40
        )
    ),

    CASE

        WHEN
        (
            m.significance_score * 0.60
            +
            m.economic_relevance * 0.40
        ) >= 90
        THEN 'CRITICAL'

        WHEN
        (
            m.significance_score * 0.60
            +
            m.economic_relevance * 0.40
        ) >= 75
        THEN 'SEVERE'

        WHEN
        (
            m.significance_score * 0.60
            +
            m.economic_relevance * 0.40
        ) >= 60
        THEN 'HIGH'

        WHEN
        (
            m.significance_score * 0.60
            +
            m.economic_relevance * 0.40
        ) >= 40
        THEN 'MODERATE'

        ELSE 'LOW'

    END,

    CONCAT(
        'Impact based on significance score ',
        m.significance_score,
        ' and economic relevance ',
        m.economic_relevance
    )

FROM major_events m;


/* ============================================================
   24. VIEW — MAJOR EVENTS OVERVIEW
   ============================================================ */

CREATE VIEW vw_major_events AS

SELECT

    m.major_event_id,

    m.global_event_id,

    r.event_date,

    r.date_added,

    r.actor1_name,

    r.actor2_name,

    m.classification,

    m.significance_score,

    m.significance_level,

    m.economic_relevance,

    i.impact_score,

    i.economic_risk

FROM major_events m

JOIN raw_events r
    ON m.global_event_id = r.global_event_id

LEFT JOIN impact_assessments i
    ON m.major_event_id = i.major_event_id;


/* ============================================================
   25. VIEW — COUNTRY EXPOSURE
   ============================================================ */

CREATE VIEW vw_country_exposure AS

SELECT

    c.country_name,

    c.region,

    COUNT(DISTINCT ec.major_event_id)
        AS major_events_count,

    ROUND(
        AVG(ec.exposure_score),
        2
    ) AS average_exposure,

    ROUND(
        MAX(ec.exposure_score),
        2
    ) AS maximum_exposure

FROM event_countries ec

JOIN countries c
    ON ec.country_code = c.country_code

GROUP BY

    c.country_code,
    c.country_name,
    c.region;


/* ============================================================
   26. VIEW — COMMODITY RISK
   ============================================================ */

CREATE VIEW vw_commodity_risk AS

SELECT

    c.commodity_name,

    c.category,

    c.strategic_importance,

    COUNT(DISTINCT ec.major_event_id)
        AS affected_events,

    ROUND(
        AVG(ec.impact_score),
        2
    ) AS average_impact,

    ROUND(
        MAX(ec.impact_score),
        2
    ) AS maximum_impact

FROM event_commodities ec

JOIN commodities c
    ON ec.commodity_id = c.commodity_id

GROUP BY

    c.commodity_id,
    c.commodity_name,
    c.category,
    c.strategic_importance;


/* ============================================================
   27. VIEW — SECTOR RISK
   ============================================================ */

CREATE VIEW vw_sector_risk AS

SELECT

    s.sector_name,

    s.strategic_importance,

    COUNT(DISTINCT es.major_event_id)
        AS affected_events,

    ROUND(
        AVG(es.impact_score),
        2
    ) AS average_impact,

    ROUND(
        MAX(es.impact_score),
        2
    ) AS maximum_impact

FROM event_sectors es

JOIN economic_sectors s
    ON es.sector_id = s.sector_id

GROUP BY

    s.sector_id,
    s.sector_name,
    s.strategic_importance;


/* ============================================================
   28. VIEW — GLOBAL RISK DASHBOARD
   ============================================================ */

CREATE VIEW vw_global_risk AS

SELECT

    COUNT(*) AS total_major_events,

    ROUND(
        AVG(significance_score),
        2
    ) AS average_significance,

    ROUND(
        MAX(significance_score),
        2
    ) AS maximum_significance,

    SUM(
        CASE
            WHEN significance_level = 'GLOBAL'
            THEN 1
            ELSE 0
        END
    ) AS global_events,

    SUM(
        CASE
            WHEN significance_level = 'MAJOR'
            THEN 1
            ELSE 0
        END
    ) AS major_events,

    SUM(
        CASE
            WHEN significance_level = 'REGIONAL'
            THEN 1
            ELSE 0
        END
    ) AS regional_events

FROM major_events;


/* ============================================================
   29. USEFUL ANALYTICAL QUERIES
   ============================================================ */


/* Most important events */

SELECT *

FROM vw_major_events

ORDER BY significance_score DESC;


/* Highest-risk countries */

SELECT *

FROM vw_country_exposure

ORDER BY average_exposure DESC;


/* Most affected commodities */

SELECT *

FROM vw_commodity_risk

ORDER BY average_impact DESC;


/* Most exposed sectors */

SELECT *

FROM vw_sector_risk

ORDER BY average_impact DESC;


/* Global dashboard */

SELECT *

FROM vw_global_risk;


/* ============================================================
   END OF MACROPULSE DATABASE
   ============================================================ */