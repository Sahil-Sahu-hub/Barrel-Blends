## Project Title
Barrels & Blends

## Brief One Line Summary
Data-driven analytics and dashboarding solution for beverage consumption, blending, and distribution optimization.

## Overview
Barrels & Blends is a data analytics initiative designed to optimize beverage blending ratios, distribution efficiency, and customer consumption behavior analysis. The primary objective is to provide stakeholders with actionable intelligence on production planning, demand forecasting, and profitability levers.

This repository serves as the central hub for the project’s codebase, datasets, dashboards, and supporting documentation. It targets data analysts, product managers, operations teams, and strategic decision-makers seeking evidence-based improvements in beverage supply chains.

The final deliverable is an interactive business intelligence dashboard supplemented by predictive analytics models that surface key performance indicators (KPIs), forecast demand across distribution channels, and recommend optimized blending ratios aligned with market dynamics.

## Problem Statement
The beverage sector experiences recurring challenges around overproduction, suboptimal blending ratios, and demand misalignment across distribution channels. These inefficiencies translate into inventory holding costs, margin erosion, and dissatisfied customers. The success criteria for this project include measurable uplift in demand forecast accuracy Percentage, reduced inventory wastage percentage, and an improvement in blend profitability percentage against established KPIs.

## Dataset
- **Source:** `[DATA_SOURCE_URL]` (replace with actual provider)
- **Fields (schema):**
  - `date` (YYYY-MM-DD)
  - `region` (string)
  - `outlet_type` (string; e.g., retail, bar, wholesale)
  - `product_id` (string)
  - `blend_ratio` (float; % composition of blend)
  - `units_sold` (integer)
  - `revenue` (float, in local currency)
  - `cost` (float, in local currency)
  - `customer_feedback_score` (float; 1–5 scale)
- **Sample Size:** `[N_ROWS]` rows, `[N_MB] MB` file size
- **Update Frequency:** Weekly batch loads
- **Privacy/Licensing:** Licensed for internal analytics use only. Do not redistribute externally.

**Sample CSV Snippet:**
```csv
date,region,outlet_type,product_id,blend_ratio,units_sold,revenue,cost,customer_feedback_score
2025-08-01,North,retail,P123,0.65,120,2400.50,1500.00,4.3
2025-08-01,South,bar,P456,0.45,75,1850.00,900.00,3.8
