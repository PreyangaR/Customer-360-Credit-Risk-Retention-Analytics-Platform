{{ config(
    materialized='table'
) }}

SELECT
    branch_id AS branch_key,
    branch_id,
    branch_name
FROM {{ ref('stg_branches') }}