# Workshop Scenario

In this workshop you will work in teams to develop a strategy to migrate a SQL Server 2008R2 environment to AWS. There are no correct answers, but we inlclude three likely solutions. The requirements are as follows. 

## Overview

- You are a contractor for an online ticket broker that sells tickets to sporting events, concerts, etc.
- The company stores data in a SQL Server 2008 R2.
- SQL Server 2008 R2 is end-of-life and the company is currently paying for extended support.
- The company wants to upgrade to SQL Server 2017. 
- They see this upgrade as an opportunity to migrate to AWS.


## Architecture

- On Prem, SQL Server is running Enterprise Edition.
- HA is achieved using a failover cluster with shared storage on a Fibre Channel attached SAN.
- SQL Server is running on physical servers with dual socket, two core (i.e. 8 vCPU) and 16GB RAM in each server.
- The application uses SQL Mail to send order confirmations to customers.
- The database schema is available here.


## Humans

- The CIO is excited about moving to AWS, and is open to your recommendations. 
- The CFO, not surprisingly, wants to minimize cost.
- The CISO is open to AWS, but wants to ensure you can achieve end-to-end encryption.
- The DBA team has some experience with MySQL but are most comfortable in SQL Server.
- The DEV team is comfortable in multiple languages and operating systems.
