{{ config(
    materialized='table'
) }}

WITH date_spine AS (

    SELECT
        DATEADD(
            day,
            SEQ4(),
            '2018-01-01'::DATE
        ) AS full_date
    FROM TABLE(
        GENERATOR(
            ROWCOUNT => 4748
        )
    )

)

SELECT
    TO_NUMBER(TO_CHAR(full_date, 'YYYYMMDD')) AS date_key,
    full_date,
    DAY(full_date) AS day,
    DAYNAME(full_date) AS day_name,
    MONTH(full_date) AS month,
    MONTHNAME(full_date) AS month_name,
    QUARTER(full_date) AS quarter,
    YEAR(full_date) AS year,
    WEEKOFYEAR(full_date) AS week_of_year
FROM date_spine
WHERE full_date <= '2030-12-31'::DATE