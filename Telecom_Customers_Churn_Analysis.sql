CREATE DATABASE telecom_data_analysis;
USE telecom_data_analysis;

SELECT DATABASE();

CREATE TABLE customers (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Gender VARCHAR(10),
    Senior_Citizen INT,
    Partner VARCHAR(5),
    Dependents VARCHAR(5),
    Tenure INT,
    Contract VARCHAR(20),
    Paperless_Billing VARCHAR(5),
    Payment_Method VARCHAR(30),
    Churn VARCHAR(5)
);

CREATE TABLE services (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Phone_Service VARCHAR(10),
    Multiple_Lines VARCHAR(25),
    Internet_Service VARCHAR(20),
    Online_Security VARCHAR(25),

    CONSTRAINT fk_services_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES customers(Customer_ID)
);

CREATE TABLE billing (
    Customer_ID VARCHAR(20) PRIMARY KEY,
    Contract VARCHAR(20),
    Paperless_Billing VARCHAR(10),
    Payment_Method VARCHAR(30),
    Monthly_Charges DECIMAL(10,2),
    Total_Charges DECIMAL(10,2),
    Churn VARCHAR(5),

    CONSTRAINT fk_billing_customer
        FOREIGN KEY (Customer_ID)
        REFERENCES customers(Customer_ID)
);

DESCRIBE telecom_customers_churn;

INSERT INTO customers ( Customer_ID, Gender, Senior_Citizen, Partner, Dependents, Tenure, Contract, Paperless_Billing, Payment_Method, Churn)
SELECT Customer_ID, Gender, Senior_Citizen, Partner, Dependents, Tenure, Contract, PaperlessBilling, PaymentMethod, Churn
FROM telecom_customers_churn;

INSERT INTO services ( Customer_ID, Phone_Service, Multiple_Lines, Internet_Service, Online_Security )
SELECT Customer_ID, Phone_Service, Multiple_Lines, Internet_Service, Online_Security
FROM telecom_customers_churn;

INSERT INTO billing ( Customer_ID, Contract, Paperless_Billing, Payment_Method, Monthly_Charges, Total_Charges, Churn )
SELECT Customer_ID, Contract, PaperlessBilling, PaymentMethod, MonthlyCharges, TotalCharges, Churn
FROM telecom_customers_churn;

select * from customers;
select * from services;
select * from billing;

-- 1. How many total customers are there?

SELECT COUNT(*) AS Total_Customers
FROM customers;

-- 2. How many customers stayed and how many churned?

SELECT Churn, COUNT(*) AS Customer_Count
FROM customers
GROUP BY Churn;

-- 3.What is the average customer tenure?

SELECT AVG(Tenure) AS Average_Tenure
FROM customers;

-- 4.How many customers have stayed for less than 12 months?

SELECT COUNT(*) AS Customers_Less_Than_12_Months
FROM customers
WHERE Tenure < 12;

-- Churn Analysis by Customer Characteristics

-- 5.Which gender has more churn?

SELECT Gender, COUNT(*) AS Churned_Customers
FROM customers
WHERE Churn = 'Yes'
GROUP BY Gender;

-- 6. What is the churn based on tenure groups?

SELECT
     CASE
        WHEN Tenure < 12 THEN 'Less than 1 year'
        WHEN Tenure BETWEEN 12 AND 24 THEN '1-2 years'
        ELSE 'More than 2 years'
    END AS Tenure_Group,
    COUNT(*) AS Total_Customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers
FROM customers
GROUP BY Tenure_Group;

-- 7. How many customers have partners/dependents?

SELECT Partner, Dependents, COUNT(*) AS Customer_Count
FROM customers
GROUP BY Partner, Dependents;

-- Contract Analysis

-- 8. Which contract type has the most customers?

SELECT Contract, COUNT(*) AS Customer_Count
FROM customers
GROUP BY Contract;

-- 9. Which contract type has the most churned customers?

SELECT Contract, COUNT(*) AS Churned_Customers
FROM customers
WHERE Churn = 'Yes'
GROUP BY Contract;

-- 10. Compare total customers and churned customers by contract.

SELECT Contract, COUNT(*) AS Total_Customers, SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS Churned_Customers
FROM customers
GROUP BY Contract;

-- Service Analysis

-- 11. How many customers use each internet service?

SELECT Internet_Service, COUNT(*) AS Customer_Count
FROM services
GROUP BY Internet_Service;

-- 12. How many customers use phone service?

SELECT Phone_Service, COUNT(*) AS Customer_Count
FROM services
GROUP BY Phone_Service;

-- 13. How many customers use multiple lines?

SELECT Multiple_Lines, COUNT(*) AS Customer_Count
FROM services
GROUP BY Multiple_Lines;

-- 14. How many customers have online security?

SELECT Online_Security, COUNT(*) AS Customer_Count
FROM services
GROUP BY Online_Security;

-- Payment & Billing Analysis

-- 15. Which payment method is most popular?

SELECT Payment_Method, COUNT(*) AS Customer_Count
FROM customers
GROUP BY Payment_Method;

-- 16. What is the average monthly charge?

SELECT AVG(Monthly_Charges) AS Average_Monthly_Charges
FROM billing;

-- 17.What is the maximum monthly charge?

SELECT MAX(Monthly_Charges) AS Maximum_Monthly_Charges
FROM billing;

-- 18. What are the top 10 customers by monthly charges?

SELECT Customer_ID, Monthly_Charges
FROM billing
ORDER BY Monthly_Charges DESC
LIMIT 10;

--   Analysis using all tables

-- 19. Show customer ID, contract and monthly charges.

SELECT c.Customer_ID, b.Contract, b.Monthly_Charges
FROM customers c JOIN billing b
ON c.Customer_ID = b.Customer_ID;

-- 20. Show customers with their internet service and churn status.

SELECT c.Customer_ID, s.Internet_Service, c.Churn
FROM customers c JOIN services s 
ON c.Customer_ID = s.Customer_ID;

-- 21. How many customers use each internet service?

SELECT s.Internet_Service, COUNT(*) AS Total_Customers
FROM customers c JOIN services s
ON c.Customer_ID = s.Customer_ID
GROUP BY s.Internet_Service;

-- 22. How many churned customers are there for each contract type?

SELECT b.Contract, COUNT(*) AS Churned_Customers
FROM customers c JOIN billing b
ON c.Customer_ID = b.Customer_ID
WHERE c.Churn = 'Yes'
GROUP BY b.Contract;

-- 23.. Rank customers based on monthly charges

SELECT Customer_ID, Monthly_Charges, RANK() OVER (ORDER BY Monthly_Charges DESC) AS Charge_Rank
FROM billing;

-- 24.Find customers whose monthly charge is above the average

WITH Average_Charge AS ( SELECT AVG(Monthly_Charges) AS Avg_Charge
FROM billing )
SELECT b.Customer_ID, b.Monthly_Charges
FROM billing b
CROSS JOIN Average_Charge a
WHERE b.Monthly_Charges > a.Avg_Charge;

-- 23. Which customers are high-risk based on contract and monthly charges?

SELECT c.Customer_ID, c.Tenure, b.Contract, b.Monthly_Charges, c.Churn
FROM customers c JOIN billing b
ON c.Customer_ID = b.Customer_ID
WHERE b.Contract = 'Month-to-month'
AND b.Monthly_Charges > 70 AND c.Churn = 'Yes';

--  High-Risk Customer Analysis

-- 25. How many high-risk customers are there?

SELECT COUNT(*) AS High_Risk_Customers
FROM customers c JOIN billing b
ON c.Customer_ID = b.Customer_ID
WHERE b.Contract = 'Month-to-month'
AND b.Monthly_Charges > 70
AND c.Churn = 'Yes';
