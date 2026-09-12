# Investment Portfolio Analytics

A SQL-based investment portfolio analytics project built with PostgreSQL using historical market data, simulated portfolio transactions, and S&P 500 benchmarking.

The project models an investment portfolio database and uses SQL to analyze portfolio performance, asset allocation, sector exposure, concentration risk, security-level gains and losses, and benchmark-relative performance.

## Project Overview

This project was built to demonstrate how SQL can be used to organize and analyze investment portfolio data.

The database combines historical security prices with simulated portfolio transactions to evaluate how a $1,000,000 portfolio performed over time.

The analysis focuses on:

- Portfolio holdings and market value
- Portfolio allocation by security
- Sector exposure
- Portfolio concentration
- Security-level gains and losses
- Return contribution
- Overall portfolio performance
- S&P 500 benchmark comparison
- Historical portfolio performance

## Technologies Used

- PostgreSQL
- SQL
- DBeaver
- GitHub
- Historical Market Data

## Database Design

The PostgreSQL database contains the following tables:

- `portfolios` — portfolio information and starting capital
- `transactions` — simulated buy and sell transactions
- `securities` — security tickers and company information
- `sectors` — sector classifications
- `daily_prices` — historical security price data
- `benchmarks` — benchmark information
- `benchmark_prices` — historical benchmark values
- `dividends` — structure for dividend information
- `stock_splits` — stock split reference data

Primary and foreign keys connect the tables and allow portfolio, security, sector, transaction, and market data to be analyzed together.

## Entity Relationship Diagram

![Investment Portfolio ERD](images/Investment_Portfolio_ERD.png)

## Dataset

The portfolio contains 15 securities representing all 11 GICS sectors.

Historical daily market prices cover the period from January 2024 through September 2026.

The project uses a simulated portfolio beginning with:

**Initial Capital: $1,000,000**

The transaction dataset contains simulated BUY and SELL activity using historical market prices.

The S&P 500 is used as the portfolio benchmark.

## Portfolio Analytics

The SQL analysis includes:

1. Current portfolio holdings
2. Market value by security
3. Portfolio weight by security
4. Sector exposure
5. Portfolio concentration
6. Portfolio return
7. S&P 500 benchmark return
8. Excess return
9. Security-level gain/loss analysis
10. Return contribution by security

The complete SQL analysis can be found in:

`sql/portfolio_analytics.sql`

## Key Findings

### Portfolio Performance

From January 8, 2024 through September 11, 2026, the simulated portfolio generated a cumulative return of:

**70.32%**

Over the same period, the S&P 500 generated:

**60.74%**

This resulted in:

**+9.58 percentage points of outperformance**

### Portfolio Concentration

The five largest positions represented:

**48.85% of invested portfolio assets**

The largest individual position was:

**Walmart (WMT) — 12.91%**

### Sector Exposure

The portfolio's largest sector exposure was:

**Information Technology — 20.73%**

Consumer Staples was the second-largest sector exposure at:

**20.53%**

The portfolio maintained exposure across all 11 GICS sectors.

### Return Contribution

The largest positive contributor was:

**NVIDIA (NVDA) — +12.44 percentage points**

Other major contributors included:

- Walmart (WMT): +11.02 percentage points
- Caterpillar (CAT): +8.84 percentage points
- JPMorgan Chase (JPM): +5.34 percentage points
- Exxon Mobil (XOM): +5.22 percentage points
- Meta Platforms (META): +5.06 percentage points

Prologis (PLD) was the only negative contributor in the final security-level analysis:

**PLD — -0.89 percentage points**

## Visualizations

### Portfolio Allocation by Security

![Portfolio Allocation](images/Portfolio_Allocation_by_Security.png)

This visualization shows the distribution of invested portfolio market value across individual securities.

### Portfolio Sector Exposure

![Portfolio Sector Exposure](images/Portfolio_Sector_Exposure.png)

This visualization shows invested portfolio market value allocated across the 11 GICS sectors represented in the portfolio.

### Portfolio vs. S&P 500

![Portfolio vs S&P 500](images/Portfolio_vs_SP500_Performance.png)

Both the portfolio and S&P 500 are indexed to 100 on January 8, 2024 to provide an equal starting point for the performance comparison.

By September 11, 2026, the simulated portfolio reached an indexed value of **170.32**, compared with **160.74** for the S&P 500.

This represents cumulative returns of **70.32%** and **60.74%**, respectively, resulting in **9.58 percentage points of portfolio outperformance** over the analyzed period.

## Repository Structure

```text
investment-portfolio-analytics/
│
├── data/
│   ├── Simulated_Portfolio_Transactions.csv
│   └── SP500_Benchmark_Prices_Import.csv
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

## How to Run

1. Create the PostgreSQL database.
2. Create the required tables and relationships.
3. Import the historical market and portfolio datasets.
4. Import the S&P 500 benchmark data.
5. Run the queries contained in `sql/portfolio_analytics.sql`.
6. Review the resulting portfolio analytics and visualizations.

## Data Notes

Historical market data is used for security and benchmark analysis, while portfolio transactions are simulated for educational and analytical purposes.

The portfolio does not represent an actual investment account, and the results should not be interpreted as investment advice or actual investment performance.

Stock split information is maintained as reference data. Historical security prices used in the analysis reflect the adjusted historical series provided by the source, so stock splits are not applied again when calculating portfolio holdings.

Portfolio performance in this project is based on price appreciation and transaction activity and does not incorporate dividend income. The S&P 500 price-return index is therefore used for the benchmark comparison rather than a total-return index.

## Purpose

This project demonstrates the application of SQL and relational database design to financial analysis, including portfolio construction, market data management, performance measurement, benchmarking, sector analysis, concentration analysis, and security-level return contribution.
