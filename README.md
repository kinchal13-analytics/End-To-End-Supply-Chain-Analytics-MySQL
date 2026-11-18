# End-to-End Supply Chain & Logistics Analytics (MySQL)


https://github.com/user-attachments/assets/34726ac4-edb4-48ff-ac0c-79bac2d73d84


## 📌 Project Overview
This project analyzes the **DataCo Smart Supply Chain Dataset (180,000+ records)** to identify operational bottlenecks, late delivery risks, fraud patterns, and top revenue-generating product categories using **MySQL**.

## 🛠️ Workflow & Methodology
1. **Data Cleaning & Standardization:** Resolved 90,000+ missing values in `Order Zipcode` and `Customer Lname`, fixed corrupted UTF-8 city names, and validated pricing/quantity integrity.
2. **Database Normalization (3NF):** Transformed a flat denormalized table into **6 relational tables** (`departments`, `categories`, `products`, `customers`, `orders`, `order_items`) linked via Primary and Foreign Keys.
3. **Business KPI Analysis:** Leveraged **Multi-table JOINs, CTEs, Window Functions (`DENSE_RANK`), and Conditional Aggregation** to extract actionable insights.

## 📊 Key Business Insights
* **Logistics Bottleneck:** **First Class** shipping has a **96.56% late delivery(7,277/7,536) orders **second class** has 78.17% late,while **standard class** best at only 38.38% late,indicating severe SLA breaches despite being the highest-cost shipping tier.

https://github.com/user-attachments/assets/7e932168-b491-4549-876a-5a2a5994d90f

* **Top Revenue Drivers:** **Water sports** ($3,113,844 revenue,$325,146 profit) , **Cleats**(&2,634,462) and **Camping & Hiking**($2,641,623 revenue) generate the highest overall revenue and profit across departments.

https://github.com/user-attachments/assets/ce5b0a3a-1667-4fef-873d-40253da87b5b


* **Fraud Risk:** western europe(139 froud orders) ans central america (114 froud) High concentrations of `SUSPECTED_FRAUD` orders occur in specific regions using `TRANSFER` payment modes.

https://github.com/user-attachments/assets/31d86a09-f52d-44bc-9ba6-79d272f40436

## 💡 Recommendations
* Audit and renegotiate SLAs with First Class and Second Class logistics partners.
* Implement automated verification rules for high-value `TRANSFER` transactions in high-risk regions.
* Maintain higher safety stock levels for top-performing categories (`Fishing` and `Cleats`).
