# Investment Portfolio Analytics

A PostgreSQL-based investment portfolio analytics project that combines historical market data, simulated portfolio transactions, and S&P 500 benchmarking to analyze portfolio performance, allocation, diversification, and security-level return contribution.

## Project Overview

This project models and analyzes a simulated $1,000,000 investment portfolio containing 15 publicly traded companies across all 11 GICS sectors.

The relational database stores portfolio transactions, historical security prices, benchmark data, sector classifications, dividends, and stock split information. SQL queries are then used to transform the underlying data into portfolio-level investment analytics.

The analysis covers the period from January 2024 through September 2026.

## Technologies

- PostgreSQL
- SQL
- DBeaver
- Relational Database Design
- GitHub
- Historical Market Data

## Database Design

The database consists of interconnected tables:

- `portfolios` — portfolio information and initial capital
- `transactions` — simulated BUY and SELL transactions
- `securities` — security and company information
- `sectors` — GICS sector classifications
- `daily_prices` — historical OHLCV market data
- `benchmarks` — benchmark information
- `benchmark_prices` — historical S&P 500 values
- `dividends` — dividend information
- `stock_splits` — stock split reference data

### Entity Relationship Diagram

<p align="center">
  <img src="images/Investment_Portfolio_ERD.png" width="750">
</p>

## Portfolio Analytics

SQL was used to calculate and analyze:

1. Current security holdings
2. Portfolio cash balance
3. Current market value by security
4. Total portfolio value
5. Portfolio allocation and security weights
6. Sector exposure
7. Top-five holding concentration
8. Portfolio return
9. Portfolio performance versus the S&P 500
10. Security-level gain/loss and return contribution

The complete analysis can be found in:

`sql/portfolio_analytics.sql`

## Key Results

The simulated portfolio grew from an initial value of **$1,000,000** to approximately **$1.70 million**, representing a **70.32% portfolio return** over the analysis period.

Over the comparable period, the **S&P 500 returned 61.44%**, resulting in approximately **8.88 percentage points of excess return** for the portfolio.

Additional findings include:

- Walmart represented the largest current position at approximately **12.91%** of invested assets.
- The five largest positions represented approximately **48.85%** of invested assets.
- Information Technology was the largest sector exposure at approximately **20.73%**.
- Consumer Staples represented approximately **20.53%** of invested assets.
- NVIDIA generated the largest security-level gain in the simulated portfolio.

## Portfolio Allocation

<p align="center">
  <img src="images/Portfolio_Allocation_by_Security.png" width="800">
</p>

The portfolio contains 15 securities across all 11 GICS sectors, allowing the analysis to examine both individual security concentration and broader sector diversification.

## Sector Exposure

<p align="center">
  <img src="images/Portfolio_Sector_Exposure.png" width="800">
</p>

Sector-level aggregation was performed by joining portfolio positions with security and sector reference tables.

## Portfolio vs. S&P 500

<p align="center">
  <img src="images/Portfolio_vs_SP500_Performance.png" width="800">
</p>

Portfolio and benchmark performance were normalized to an index value of 100 to make their relative performance over time directly comparable.

## Data

The project combines:

- Historical daily market price data
- S&P 500 benchmark data
- Simulated portfolio transactions
- GICS sector classifications
- Corporate-action reference information

The portfolio transactions are simulated for analytical and educational purposes and do not represent actual investment activity.

## Repository Structure

```text
investment-portfolio-analytics/
│
├── data/
│   ├── SP500_Benchmark_Prices_Import.csv
│   └── Simulated_Portfolio_Transactions.csv
│
├── images/
│   ├── Investment_Portfolio_ERD.png
│   ├── Portfolio_Allocation_by_Security.png
│   ├── Portfolio_Sector_Exposure.png
│   └── Portfolio_vs_SP500_Performance.png
│
├── sql/
│   └── portfolio_analytics.sql
│
└── README.md
```

## Skills Demonstrated

This project demonstrates practical experience with:

- Relational database design
- Primary and foreign key relationships
- SQL joins and aggregations
- Common Table Expressions (CTEs)
- Financial data analysis
- Portfolio performance measurement
- Benchmark comparison
- Sector and concentration analysis
- Data validation and transformation
- Investment analytics

## Disclaimer

This project was created for educational and portfolio purposes. Portfolio transactions are simulated, and the results should not be interpreted as investment advice or actual investment performance.
