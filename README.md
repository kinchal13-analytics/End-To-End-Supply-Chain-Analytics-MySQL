# End-to-End Supply Chain & Logistics Analytics (MySQL)

## 📌 Project Overview
This project analyzes the **DataCo Smart Supply Chain Dataset (180,000+ records)** to identify operational bottlenecks, late delivery risks, fraud patterns, and top revenue-generating product categories using **MySQL**.

## 🛠️ Workflow & Methodology
1. **Data Cleaning & Standardization:** Resolved 90,000+ missing values in `Order Zipcode` and `Customer Lname`, fixed corrupted UTF-8 city names, and validated pricing/quantity integrity.
2. **Database Normalization (3NF):** Transformed a flat denormalized table into **6 relational tables** (`departments`, `categories`, `products`, `customers`, `orders`, `order_items`) linked via Primary and Foreign Keys.
3. **Business KPI Analysis:** Leveraged **Multi-table JOINs, CTEs, Window Functions (`DENSE_RANK`), and Conditional Aggregation** to extract actionable insights.

## 📊 Key Business Insights
* **Logistics Bottleneck:** **First Class** shipping has a **95%+ late delivery rate**, indicating severe SLA breaches despite being the highest-cost shipping tier.

https://github.com/user-attachments/assets/7e932168-b491-4549-876a-5a2a5994d90f

* **Top Revenue Drivers:** **Fishing**, **Cleats**, and **Camping & Hiking** generate the highest overall revenue and profit across departments.
* **Fraud Risk:** High concentrations of `SUSPECTED_FRAUD` orders occur in specific regions using `TRANSFER` payment modes.

## 💡 Recommendations
* Audit and renegotiate SLAs with First Class and Second Class logistics partners.
* Implement automated verification rules for high-value `TRANSFER` transactions in high-risk regions.
* Maintain higher safety stock levels for top-performing categories (`Fishing` and `Cleats`).
