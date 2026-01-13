/*
===============================================================================
Project: Walmart Black Friday Sales Analysis (Pareto Principle & Customer Segmentation)
Author: [Your Name]
Tool Used: SQL (MySQL/PostgreSQL Compatible)
Description: 
    This script contains the analytical queries used to segment customers, 
    validate the 80/20 rule, and identify the "Whale" customer persona.
===============================================================================
*/

-- =============================================================================
-- 1. DATA EXPLORATION & BASELINE METRICS
-- =============================================================================

-- Checking total customers, transactions, and revenue
SELECT 
    COUNT(DISTINCT User_ID) AS Total_Customers,
    COUNT(*) AS Total_Transactions,
    SUM(Purchase) AS Total_Revenue,
    ROUND(AVG(Purchase), 2) AS Avg_Transaction_Value
FROM Black_Friday_Sales;


-- =============================================================================
-- 2. CUSTOMER SEGMENTATION (THE PARETO PRINCIPLE)
-- Objective: Segment users into 'Whales' (Top 20%), 'Potential', and 'Low Spenders'
-- =============================================================================

WITH User_Revenue AS (
    SELECT 
        User_ID,
        SUM(Purchase) AS Total_Spend
    FROM Black_Friday_Sales
    GROUP BY User_ID
),
Ranked_Users AS (
    SELECT 
        User_ID,
        Total_Spend,
        -- Dividing customers into 10 buckets (Deciles) based on spending
        NTILE(10) OVER (ORDER BY Total_Spend DESC) AS Spending_Decile
    FROM User_Revenue
)
SELECT 
    User_ID,
    Total_Spend,
    CASE 
        WHEN Spending_Decile <= 2 THEN 'Whale (Top 20%)'        -- Decile 1 & 2
        WHEN Spending_Decile <= 5 THEN 'Mid-Tier (Next 30%)'    -- Decile 3, 4, 5
        ELSE 'Low Spender (Bottom 50%)'                         -- Decile 6-10
    END AS Customer_Segment
FROM Ranked_Users;


-- =============================================================================
-- 3. WHALE PERSONA ANALYSIS (WHO ARE THE HIGH SPENDERS?)
-- Objective: Identify the demographic profile of the Top 20% customers
-- =============================================================================

WITH Whale_Customers AS (
    SELECT 
        User_ID,
        SUM(Purchase) AS Total_Spend
    FROM Black_Friday_Sales
    GROUP BY User_ID
    ORDER BY Total_Spend DESC
    LIMIT 1178 -- Representing approx top 20% of users
)
SELECT 
    s.Gender,
    s.Age,
    s.City_Category,
    CASE WHEN s.Marital_Status = 1 THEN 'Married' ELSE 'Single' END AS Marital_Status,
    COUNT(DISTINCT s.User_ID) AS Whale_Count,
    SUM(s.Purchase) AS Revenue_Contribution
FROM Black_Friday_Sales s
JOIN Whale_Customers w ON s.User_ID = w.User_ID
GROUP BY 1, 2, 3, 4
ORDER BY Revenue_Contribution DESC
LIMIT 5;

/* INSIGHT FOUND: 
The top profile is Single Men, Age 26-35, living in City B.
*/


-- =============================================================================
-- 4. DEEP DIVE: MARITAL STATUS & SPENDING BEHAVIOR
-- Objective: Compare spending habits of Single vs Married customers
-- =============================================================================

SELECT 
    CASE WHEN Marital_Status = 1 THEN 'Married' ELSE 'Single' END AS Status,
    Gender,
    COUNT(DISTINCT User_ID) AS Customer_Count,
    ROUND(AVG(Purchase), 2) AS Avg_Transaction_Value,
    SUM(Purchase) AS Total_Revenue
FROM Black_Friday_Sales
GROUP BY 1, 2
ORDER BY Avg_Transaction_Value DESC;

/* INSIGHT FOUND: 
Single Men have a higher Avg Transaction Value ($9,454) compared to Married Men ($9,414).
This indicates higher discretionary income for personal electronics/lifestyle products.
*/


-- =============================================================================
-- 5. CITY PERFORMANCE ANALYSIS
-- Objective: Identify which city tier has the highest concentration of high-value users
-- =============================================================================

SELECT 
    City_Category,
    COUNT(DISTINCT User_ID) AS Total_Shoppers,
    SUM(Purchase) AS Total_Revenue,
    ROUND(SUM(Purchase) * 100.0 / (SELECT SUM(Purchase) FROM Black_Friday_Sales), 2) AS Revenue_Share_Pct
FROM Black_Friday_Sales
GROUP BY City_Category
ORDER BY Total_Revenue DESC;

/* INSIGHT FOUND: 
City B drives the highest volume and revenue, outperforming the premium City A.
Strategy Recommendation: Focus logistics and marketing budget on City B.
*/