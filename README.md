# 📊 Walmart Black Friday Sales Analysis

## 🚀 Project Objective
To analyze Walmart's Black Friday sales data (550K+ records) and identify high-value customer segments using the **Pareto Principle (80/20 Rule)**. The goal was to provide data-driven recommendations for targeted marketing and customer retention strategies.

## 💡 Key Insights (The "Whale" Strategy)
* **Pareto Principle Validated:** The Top **20%** of customers contribute to **55%** of the total revenue.
* **Whale Segment Identified:** The highest spending demographic is **Single Men (Age 26-35)** living in **City B**.
* **Strategic Recommendation:** Implementing a "VIP Loyalty Program" for these top 1,800 customers could significantly boost retention and LTV.

## 🛠️ Tech Stack & Skills
* **Tool:** Power BI (Data Modeling, DAX Measures, Dynamic Dashboarding)
* **SQL Logic:** Advanced Window Functions (`NTILE`, `RANK`), CTEs, and Aggregations.
* **Analysis:** Customer Segmentation, RFM Analysis, Cohort Analysis.

---

## 💻 Technical Implementation (SQL Logic)
To identify the "Whale" customers, I used SQL Window Functions to segment users based on spending percentiles.

```sql
/* Segmenting customers into deciles based on total spend */
WITH Segmentation AS (
    SELECT 
        User_ID,
        SUM(Purchase) AS Total_Revenue,
        NTILE(10) OVER (ORDER BY SUM(Purchase) DESC) AS Spending_Decile
    FROM Walmart_Data
    GROUP BY User_ID
)
SELECT 
    User_ID,
    CASE 
        WHEN Spending_Decile <= 2 THEN 'Whale (Top 20%)'
        ELSE 'Standard User'
    END AS Customer_Segment
FROM Segmentation;
