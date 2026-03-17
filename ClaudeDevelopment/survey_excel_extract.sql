/*
    Survey Data Extract — Excel-Friendly Format
    =============================================
    Joins F_SURVEY_RESPONSE fact table to D_QUESTION dimension
    to produce a flat, human-readable extract suitable for Excel.

    Output columns:
      Respondent        - Anonymous respondent number (1, 2, 3...)
      Response Date     - Date the survey was submitted
      Status            - completed / incomplete
      Community Role    - Church congregation member / Worker / Community Leader
      Age Bracket       - Age range of respondent
      Gender            - Gender of respondent
      Postcode          - Postcode of respondent
      Survey Section    - Top-level section (Challenging issues, Lifestyle provision, etc.)
      Rating Scale      - Sub-scale within section (Poor / No expertise & resources), NULL for general
      Question          - The specific question text
      Answer            - Text answer (free text, selection, or numeric as text)
      Score             - Numeric score where applicable (NULL for free-text/selection questions)

    Demographics are deduplicated via MAX() to handle multiple sub-table rows per respondent.
    Sentinel rows and NULL answers are excluded.

    ~28,600 rows for the NeighboursSurvey organisation.
*/

SELECT
    DENSE_RANK() OVER (ORDER BY f.TOUCHPOINT_HUB_ID) AS [Respondent],
    CONVERT(VARCHAR(10), MAX(f.TOUCHPOINT_DATE), 120)  AS [Response Date],
    MAX(f.TOUCHPOINT_STATUS)                            AS [Status],
    MAX(f.COMMUNITY_INVOLVEMENT)                        AS [Community Role],
    MAX(f.AGE_BRACKET)                                  AS [Age Bracket],
    MAX(f.GENDER)                                       AS [Gender],
    MAX(f.POSTCODE)                                     AS [Postcode],
    q.TOP_QUESTION_NAME                                 AS [Survey Section],
    CASE
        WHEN q.MIDDLE_1_QUESTION_NAME IN ('Not called', 'Not called&nbsp;', 'Unknown')
            THEN NULL
        ELSE q.MIDDLE_1_QUESTION_NAME
    END                                                 AS [Rating Scale],
    -- Strip any HTML tags from question text (one known case with <span>)
    REPLACE(REPLACE(q.BOTTOM_QUESTION_NAME,
        '<span style="color: rgb(0, 32, 96);">', ''),
        '</span>', '')                                  AS [Question],
    MAX(f.ANSWER_TEXT)                                   AS [Answer],
    MAX(f.ANSWER_NUMERIC)                                AS [Score]
FROM [presentation].[F_SURVEY_RESPONSE] f
JOIN [presentation].[D_QUESTION] q
    ON f.QUESTION_HUB_ID = q.BOTTOM_HUB_ID
WHERE q.BOTTOM_HUB_ID      != CONVERT(BINARY(32), -999)
  AND f.TOUCHPOINT_HUB_ID  != CONVERT(BINARY(32), -999)
  AND (f.ANSWER_TEXT IS NOT NULL OR f.ANSWER_NUMERIC IS NOT NULL)
GROUP BY
    f.TOUCHPOINT_HUB_ID,
    f.QUESTION_HUB_ID,
    f.ANSWER_HUB_ID,
    q.TOP_QUESTION_NAME,
    q.MIDDLE_1_QUESTION_NAME,
    REPLACE(REPLACE(q.BOTTOM_QUESTION_NAME,
        '<span style="color: rgb(0, 32, 96);">', ''),
        '</span>', '')
ORDER BY
    [Respondent],
    q.TOP_QUESTION_NAME,
    q.MIDDLE_1_QUESTION_NAME,
    [Question];
