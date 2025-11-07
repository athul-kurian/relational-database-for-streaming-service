<p align="center">
  <img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/banner.png" alt="" style="width:100%; height:auto;"/>
</p>

# 🎬 Relational Database for Streaming Service

> This is a comprehensive project that models and implements a **relational database system** for a movie streaming platform using **Oracle RDBMS**

---

## 🧩 Overview

Streaming services collect and process large volumes of user and content data. This project aims to design and implement a model database that can manage content, user data, subscriptions, payments, devices, and viewing activity.

---

## 🚀 Project Phases

### **Phase 1: Business Goals and Specifications**

- Defined the [problem statement](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/Database_Specifications.pdf) and business context.
- Identified key **data requirements**:  
  - Movies  
  - Accounts and profiles  
  - Device data 
  - Subscriptions and payment data
  - Watch session data
- Specified **database constraints** (e.g., many profiles per account, only one account per device, etc.).
- Outlined **business goals**, such as tracking popular movies by demographic, analyzing subscription behavior, and identifying device usage patterns.

---

### **Phase 2: ER Diagram**

- Identified the entities, attributes, and relationships within the data.
- Designed an [**Entity-Relationship (ER) Diagram**](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/ER%20Diagram.pdf) representing all data entities and their relationships.  
- Defined **cardinalities** using the (min, max) notation according to business rules.
  
---

### **Phase 3: Relational Schema**

- Converted the ER diagram into a [Relational Schema](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/Relational%20Schema.pdf).
- Identified all candidate keys and selected primary keys in all tables.
- Identified all **Functional Dependencies** within the schema.
- Normalized all tables to **Boyce-Codd Normal Form (BCNF)** to eliminate redundancy.  

---

### **Phase 4: SQL**

- Wrote an SQL [DDL script](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/SQL%20Scripts/projectDBcreate.sql) to create the database schema using **Oracle RDBMS**.
- Created [Database Triggers](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/SQL%20Scripts/projectDBcreate.sql#L151) to enforce referential integrity constraints and other business-specific constraints.
- Populated tables with [simulated data](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/SQL%20Scripts/projectDBinsert.sql).
- Executed complex [SQL queries](https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/SQL%20Scripts/projectDBqueries.sql) for business analytics.

---

## </  > Example Queries

1. Which device type (TV, PC, Mobile, or Console) did the most traffic (highest total watch session duration) come from?
><img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/query1.png"/>
Ouput:
```
TYPE						                                   TOTAL_WATCH_TIME_MINUTES
--------------------------------------------------             ------------------------
Console								                                           2,666.00
```

2. Identify the actor or actress whose movies have the highest total watch time among adult male users.
><img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/query2.png"/>
Output:
```
NAME			                        Total_Watch_Time_Minutes
------------------------------          ------------------------
Tom Hanks					                              316.00
```

3. Find the user profiles who have watched at least one movie in every genre available in the system.
><img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/query3.png"/>
Output:
```
PROFILE_ID                           NAME
---------- ------------------------------
P81	                        Mike Wazowski
P82	                        Ella Sinclair
```

4. Show the total watch time per genre, and include subtotals for each genre and a grand total at the end.
><img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/query4.png"/>
Output:
```
GENRE		           TOTAL_WATCH_TIME_MINUTES
---------------        ------------------------
Action				                     719.00
Adventure			                     645.00
Comedy				                   1,060.00
Drama				                     328.00
Fantasy 			                     695.00
Horror				                     404.00
Mystery 			                     614.00
Romance 			                     516.00
Sci-Fi				                     464.00
Thriller			                     215.00
TOTAL				                   5,660.00
```

5. For all adult female users, show the total watch time grouped by IP subnet starting with 192.168.0, and include a grand total of watch time for that region.
><img src="https://github.com/athul-kurian/relational-database-for-streaming-service/blob/main/assets/query5.png"/>
Output:
```
IP_REGION					                                    TOTAL_WATCH_TIME_MINUTES
----------------------------------------------------            ------------------------
192.168.0.103							                                           94.00
192.168.0.138							                                           86.00
192.168.0.158							                                           65.00
192.168.0.163							                                           64.00
192.168.0.19							                                           39.00
192.168.0.211							                                          105.00
192.168.0.212							                                          105.00
192.168.0.213							                                           90.00
192.168.0.214							                                           90.00
192.168.0.215							                                           80.00
192.168.0.216							                                           90.00
192.168.0.217							                                          105.00
192.168.0.218							                                           90.00
192.168.0.219							                                          105.00
192.168.0.220							                                          110.00
192.168.0.33							                                          150.00
192.168.0.41							                                           80.00
192.168.0.94							                                          118.00
TOTAL								                                            1,666.00
```