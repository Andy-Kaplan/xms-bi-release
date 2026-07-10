-- 12_group_mapping.sql
-- Marge Brut live dashboard: MICROSERVICE_NAME group mapping for both product dimensions.
--
-- MICROSERVICE_NAME is the platform's manual-only MDM layer (see CLAUDE.md "Key Conventions" --
-- no staging pipeline ever writes it). This script is its sole writer for the Marge Brut cost
-- ratio (Consumption / Turnover), which needs turnover (Mews products, datavault.SAT_PRODUCT)
-- and stock/purchases (Growyze invitems, datavault.SAT_INVITEM) aggregated under the SAME 6
-- group strings so the Task 6 F_MARGEBRUT_MONTH build can join them on one GROUP_NAME:
--     Food, Breakfast, Wines, Bottled Beer, Soft Drinks, Spirit
--
-- Neither SAT carries a named "category" column (PRODUCT_NAME/INVITEM_NAME + ATTR_1..5, ATTR_1..5
-- are populated for Growyze invitems as UOM/pack-size/cost fields, not a category) -- for
-- SAT_PRODUCT, ATTR_1..5 are almost entirely NULL or hold portion-size labels ("125 ml", "Bottle").
-- So both CASE blocks key off keyword matches against the product/item NAME. Every keyword list
-- was calibrated against a live sample (Mews DEV proxy org 19, Growyze UAT Padel Social org) and
-- shape-tested read-only via MCP before being written here -- see report for the two distributions.
--
-- Re-runnable: re-running always re-derives the same grouping from the same NAME values (only
-- CURRENT_FLAG = 1 rows are touched), so this is safe to execute more than once.
--
-- Unqualified two-part names only -- must run against any client database (see CLAUDE.md
-- "Script Authoring Rules").

-- =====================================================================================
-- Block 1: Mews products (turnover side) -- datavault.SAT_PRODUCT
-- =====================================================================================
-- Keyword guards, calibrated against real data (Mews DEV proxy org 19):
--   - 'gin' bare would match "Original"/"Orginal" (typo seen in "Coke Orginal", "Guinness
--     Original") and "Ginger" -- excluded explicitly so real Gin brands (Hendrick's, Monkey47,
--     Bombay, Beefeater, Tanqueray) still match on their own name.
--   - 'cola' bare would match "chocolate" -- excluded so hot-chocolate/food items don't get
--     pulled into Soft Drinks.
--   - ' ale' requires a leading space so it only matches "<word> Ale"/"Pale Ale", not "sale",
--     "Female" etc.
--   - 'beer'/' ale' both need a 'ginger' exclusion -- this catalogue carries plain "Ginger Ale"
--     and "Ginger Beer" (non-alcoholic mixers), which would otherwise land in Bottled Beer; an
--     explicit 'ginger beer'/'ginger ale'/'kombucha' -> Soft Drinks match routes them correctly.
--   - 'rum' excludes 'crumble'/'drumstick' and 'corona' excludes 'coronation' -- defensive
--     guards against menu items not present in this proxy's catalogue but plausible on the real
--     org's menu (Apple Crumble, Drumsticks, Coronation Chicken).
UPDATE s
SET MICROSERVICE_NAME =
    CASE
        -- Breakfast: coffee/tea service + morning pastries
        WHEN s.PRODUCT_NAME LIKE '%breakfast%' OR s.PRODUCT_NAME LIKE '%coffee%'
          OR s.PRODUCT_NAME LIKE '%cappuccino%' OR s.PRODUCT_NAME LIKE '%latte%'
          OR s.PRODUCT_NAME LIKE '%espresso%' OR s.PRODUCT_NAME LIKE '%tea%'
          OR s.PRODUCT_NAME LIKE '%croissant%' OR s.PRODUCT_NAME LIKE '%pastry%'
          OR s.PRODUCT_NAME LIKE '%danish%' OR s.PRODUCT_NAME LIKE '%pancake%'
          OR s.PRODUCT_NAME LIKE '%waffle%' OR s.PRODUCT_NAME LIKE '%porridge%'
          OR s.PRODUCT_NAME LIKE '%granola%'
            THEN N'Breakfast'
        -- Wines: grape/style names + sparkling
        WHEN s.PRODUCT_NAME LIKE '%wine%' OR s.PRODUCT_NAME LIKE '%zinfandel%'
          OR s.PRODUCT_NAME LIKE '%merlot%' OR s.PRODUCT_NAME LIKE '%chardonnay%'
          OR s.PRODUCT_NAME LIKE '%cabernet%' OR s.PRODUCT_NAME LIKE '%sauvignon%'
          OR s.PRODUCT_NAME LIKE '%pinot%' OR s.PRODUCT_NAME LIKE '%prosecco%'
          OR s.PRODUCT_NAME LIKE '%malbec%' OR s.PRODUCT_NAME LIKE '%riesling%'
          OR s.PRODUCT_NAME LIKE '%champagne%' OR s.PRODUCT_NAME LIKE '%tempranillo%'
          OR s.PRODUCT_NAME LIKE '%picpou%'
            THEN N'Wines'
        -- Bottled Beer: beer/lager/ale/cider styles + common bottled brands
        WHEN (s.PRODUCT_NAME LIKE '%beer%' AND s.PRODUCT_NAME NOT LIKE '%ginger%')
          OR s.PRODUCT_NAME LIKE '%lager%'
          OR (s.PRODUCT_NAME LIKE '% ale%' AND s.PRODUCT_NAME NOT LIKE '%ginger%')
          OR s.PRODUCT_NAME LIKE '%cider%'
          OR s.PRODUCT_NAME LIKE '%rekorderlig%' OR s.PRODUCT_NAME LIKE '%stella%'
          OR s.PRODUCT_NAME LIKE '%guinness%'
          OR (s.PRODUCT_NAME LIKE '%corona%' AND s.PRODUCT_NAME NOT LIKE '%coronation%')
          OR s.PRODUCT_NAME LIKE '%peroni%' OR s.PRODUCT_NAME LIKE '%modelo%'
          OR s.PRODUCT_NAME LIKE '%mahou%' OR s.PRODUCT_NAME LIKE '%camden%'
          OR s.PRODUCT_NAME LIKE '%budweiser%'
            THEN N'Bottled Beer'
        -- Spirit: base spirits + liqueurs + named brands (name-only signal, no category column)
        WHEN s.PRODUCT_NAME LIKE '%vodka%'
          OR (s.PRODUCT_NAME LIKE '%gin%' AND s.PRODUCT_NAME NOT LIKE '%ginger%'
              AND s.PRODUCT_NAME NOT LIKE '%original%' AND s.PRODUCT_NAME NOT LIKE '%orginal%')
          OR (s.PRODUCT_NAME LIKE '%rum%' AND s.PRODUCT_NAME NOT LIKE '%crumble%' AND s.PRODUCT_NAME NOT LIKE '%drumstick%')
          OR s.PRODUCT_NAME LIKE '%whisk%'
          OR s.PRODUCT_NAME LIKE '%tequila%' OR s.PRODUCT_NAME LIKE '%mezcal%'
          OR s.PRODUCT_NAME LIKE '%brandy%' OR s.PRODUCT_NAME LIKE '%cognac%'
          OR s.PRODUCT_NAME LIKE '%liqueur%' OR s.PRODUCT_NAME LIKE '%bourbon%'
          OR s.PRODUCT_NAME LIKE '%baileys%' OR s.PRODUCT_NAME LIKE '%cointreau%'
          OR s.PRODUCT_NAME LIKE '%disaronno%' OR s.PRODUCT_NAME LIKE '%jack daniels%'
          OR s.PRODUCT_NAME LIKE '%jameson%' OR s.PRODUCT_NAME LIKE '%jim beam%'
          OR s.PRODUCT_NAME LIKE '%remy martin%' OR s.PRODUCT_NAME LIKE '%monkey47%'
          OR s.PRODUCT_NAME LIKE '%bombay%' OR s.PRODUCT_NAME LIKE '%beefeater%'
          OR s.PRODUCT_NAME LIKE '%smirnoff%' OR s.PRODUCT_NAME LIKE '%bacardi%'
          OR s.PRODUCT_NAME LIKE '%olmeca%' OR s.PRODUCT_NAME LIKE '%malfy%'
          OR s.PRODUCT_NAME LIKE '%tanqueray%' OR s.PRODUCT_NAME LIKE '%aperol%'
          OR s.PRODUCT_NAME LIKE '%sambuca%' OR s.PRODUCT_NAME LIKE '%hendrick%'
            THEN N'Spirit'
        -- Soft Drinks: sodas/juices/water/mixers ('cola' excludes 'chocolat' -- see header)
        WHEN s.PRODUCT_NAME LIKE '%coke%'
          OR (s.PRODUCT_NAME LIKE '%cola%' AND s.PRODUCT_NAME NOT LIKE '%chocolat%')
          OR s.PRODUCT_NAME LIKE '%fanta%' OR s.PRODUCT_NAME LIKE '%sprite%'
          OR s.PRODUCT_NAME LIKE '%juice%' OR s.PRODUCT_NAME LIKE '%water%'
          OR s.PRODUCT_NAME LIKE '%redbull%' OR s.PRODUCT_NAME LIKE '%red bull%'
          OR s.PRODUCT_NAME LIKE '%tonic%' OR s.PRODUCT_NAME LIKE '%soda%'
          OR s.PRODUCT_NAME LIKE '%lemonade%' OR s.PRODUCT_NAME LIKE '%j2o%'
          OR s.PRODUCT_NAME LIKE '%schweppes%' OR s.PRODUCT_NAME LIKE '%kombucha%'
          OR s.PRODUCT_NAME LIKE '%ginger beer%' OR s.PRODUCT_NAME LIKE '%ginger ale%'
            THEN N'Soft Drinks'
        -- Catch-all: food dishes, modifiers, allergen tags, portion/price sub-lines, anything
        -- with no beverage/breakfast signal in its name.
        ELSE N'Food'
    END
FROM [datavault].[SAT_PRODUCT] s
WHERE s.CURRENT_FLAG = 1;

-- Override exceptions for SAT_PRODUCT (product IDs the keyword CASE mis-groups).
-- None were needed against the sampled Mews DEV proxy catalogue -- every product's name carried
-- an unambiguous keyword signal or correctly fell to the Food catch-all. Structure kept ready
-- for the real org's catalogue:
-- UPDATE s SET MICROSERVICE_NAME = ov.grp
-- FROM [datavault].[SAT_PRODUCT] s
-- JOIN (VALUES
--     (N'<productId>', N'Breakfast')   -- example: a coffee-menu item mis-grouped as Food
-- ) AS ov(pid, grp) ON ov.pid = s.PRODUCT_ID
-- WHERE s.CURRENT_FLAG = 1;

-- =====================================================================================
-- Block 2: Growyze inventory items (stock/purchases side) -- datavault.SAT_INVITEM
-- =====================================================================================
-- Same approach against INVITEM_NAME. The Growyze UAT proxy (Padel Social) also sells retail
-- clothing and padel equipment alongside F&B stock -- those have no beverage/breakfast keyword
-- and correctly fall to the Food catch-all (there is no "Retail" group among the 6).
-- Extra guards found in this catalogue:
--   - 'beer'/' ale' both need a 'ginger' exclusion (FENTIMANS GINGER BEER, LONDON ESSENCE
--     GINGER ALE are non-alcoholic mixers), with an explicit 'ginger beer'/'ginger ale' ->
--     Soft Drinks match so they land somewhere sensible instead of Food.
--   - 'gin' needs the same ginger/original/orginal exclusion as Block 1 (JARR KOMBUCHA
--     ORIGINAL would otherwise false-match on "ORIGINAL").
--   - 'cola' needs the same chocolate exclusion (Cadbury's Drinking Chocolate, KIND Bar,
--     Fulfil Protein Bar, Mallow & Marsh, etc. all contain "chocolate").
--   - 'water' excludes 'watermelon' -- this catalogue carries "Fresh Watermelon" and "Monin
--     Watermelon" (a fruit ingredient and a cocktail syrup, not standalone soft drinks), which
--     would otherwise false-match on "water". "Rubicon Watermelon Juice" still correctly lands
--     in Soft Drinks via its own 'juice' match.
--   - 'rum' excludes 'crumble'/'drumstick' and 'corona' excludes 'coronation' -- same defensive
--     guards as Block 1 (not present in this proxy's catalogue but plausible on the real menu).
UPDATE i
SET MICROSERVICE_NAME =
    CASE
        WHEN i.INVITEM_NAME LIKE '%oats%' OR i.INVITEM_NAME LIKE '%croissant%'
          OR i.INVITEM_NAME LIKE '%danish%' OR i.INVITEM_NAME LIKE '%pastry%'
          OR i.INVITEM_NAME LIKE '%porridge%' OR i.INVITEM_NAME LIKE '%granola%'
          OR i.INVITEM_NAME LIKE '%muesli%' OR i.INVITEM_NAME LIKE '%breakfast%'
            THEN N'Breakfast'
        WHEN i.INVITEM_NAME LIKE '%wine%' OR i.INVITEM_NAME LIKE '%tempranillo%'
          OR i.INVITEM_NAME LIKE '%picpou%' OR i.INVITEM_NAME LIKE '%chardonnay%'
          OR i.INVITEM_NAME LIKE '%merlot%' OR i.INVITEM_NAME LIKE '%sauvignon%'
          OR i.INVITEM_NAME LIKE '%pinot%' OR i.INVITEM_NAME LIKE '%prosecco%'
          OR i.INVITEM_NAME LIKE '%malbec%' OR i.INVITEM_NAME LIKE '%riesling%'
          OR i.INVITEM_NAME LIKE '%champagne%'
            THEN N'Wines'
        WHEN (i.INVITEM_NAME LIKE '%beer%' AND i.INVITEM_NAME NOT LIKE '%ginger%')
          OR i.INVITEM_NAME LIKE '%lager%'
          OR (i.INVITEM_NAME LIKE '% ale%' AND i.INVITEM_NAME NOT LIKE '%ginger%')
          OR i.INVITEM_NAME LIKE '%cider%' OR i.INVITEM_NAME LIKE '%stella%'
          OR i.INVITEM_NAME LIKE '%guinness%' OR i.INVITEM_NAME LIKE '%modelo%'
          OR i.INVITEM_NAME LIKE '%mahou%' OR i.INVITEM_NAME LIKE '%camden%'
          OR (i.INVITEM_NAME LIKE '%corona%' AND i.INVITEM_NAME NOT LIKE '%coronation%')
          OR i.INVITEM_NAME LIKE '%peroni%'
          OR i.INVITEM_NAME LIKE '%budweiser%'
            THEN N'Bottled Beer'
        WHEN i.INVITEM_NAME LIKE '%vodka%'
          OR (i.INVITEM_NAME LIKE '%gin%' AND i.INVITEM_NAME NOT LIKE '%ginger%'
              AND i.INVITEM_NAME NOT LIKE '%original%' AND i.INVITEM_NAME NOT LIKE '%orginal%')
          OR (i.INVITEM_NAME LIKE '%rum%' AND i.INVITEM_NAME NOT LIKE '%crumble%' AND i.INVITEM_NAME NOT LIKE '%drumstick%')
          OR i.INVITEM_NAME LIKE '%whisk%'
          OR i.INVITEM_NAME LIKE '%tequila%' OR i.INVITEM_NAME LIKE '%mezcal%'
          OR i.INVITEM_NAME LIKE '%brandy%' OR i.INVITEM_NAME LIKE '%cognac%'
          OR i.INVITEM_NAME LIKE '%liqueur%' OR i.INVITEM_NAME LIKE '%bourbon%'
          OR i.INVITEM_NAME LIKE '%baileys%' OR i.INVITEM_NAME LIKE '%tanqueray%'
          OR i.INVITEM_NAME LIKE '%malfy%' OR i.INVITEM_NAME LIKE '%sambuca%'
            THEN N'Spirit'
        WHEN i.INVITEM_NAME LIKE '%juice%'
          OR (i.INVITEM_NAME LIKE '%water%' AND i.INVITEM_NAME NOT LIKE '%watermelon%')
          OR i.INVITEM_NAME LIKE '%rubicon%' OR i.INVITEM_NAME LIKE '%vitamin well%'
          OR i.INVITEM_NAME LIKE '%coke%'
          OR (i.INVITEM_NAME LIKE '%cola%' AND i.INVITEM_NAME NOT LIKE '%chocolat%')
          OR i.INVITEM_NAME LIKE '%fanta%' OR i.INVITEM_NAME LIKE '%sprite%'
          OR i.INVITEM_NAME LIKE '%tonic%' OR i.INVITEM_NAME LIKE '%soda%'
          OR i.INVITEM_NAME LIKE '%kombucha%' OR i.INVITEM_NAME LIKE '%ginger beer%'
          OR i.INVITEM_NAME LIKE '%ginger ale%'
            THEN N'Soft Drinks'
        -- Catch-all: retail clothing/equipment, food/snack stock, kitchen ingredients, and
        -- anything else with no beverage/breakfast signal in its name.
        ELSE N'Food'
    END
FROM [datavault].[SAT_INVITEM] i
WHERE i.CURRENT_FLAG = 1;

-- Override exceptions for SAT_INVITEM (invitem IDs the keyword CASE mis-groups).
-- One real case found against the sampled Growyze UAT proxy catalogue: "The Lost Explorer
-- Blanco" is a mezcal/tequila but its name carries none of the Spirit keywords above.
UPDATE i
SET MICROSERVICE_NAME = ov.grp
FROM [datavault].[SAT_INVITEM] i
JOIN (VALUES
    (N'68d64de560ddb80f58e8f267', N'Spirit')   -- "The Lost Explorer Blanco" -- mezcal, name has no spirit keyword
) AS ov(iid, grp) ON ov.iid = i.INVITEM_ID
WHERE i.CURRENT_FLAG = 1;
