-- Investment Portfolio Analytics
-- PostgreSQL Database Schema
-- Creates the relational structure used for the portfolio analytics project.

CREATE TABLE IF NOT EXISTS sectors (
    sector_id SERIAL PRIMARY KEY,
    sector_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS benchmarks (
    benchmark_id SERIAL PRIMARY KEY,
    benchmark_name VARCHAR(100) NOT NULL,
    symbol VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS securities (
    security_id SERIAL PRIMARY KEY,
    ticker VARCHAR(10) NOT NULL UNIQUE,
    company_name VARCHAR(150) NOT NULL,
    sector_id INTEGER NOT NULL,
    CONSTRAINT fk_securities_sector
        FOREIGN KEY (sector_id)
        REFERENCES sectors(sector_id)
);

CREATE TABLE IF NOT EXISTS portfolios (
    portfolio_id SERIAL PRIMARY KEY,
    portfolio_name VARCHAR(150) NOT NULL,
    inception_date DATE NOT NULL,
    initial_cash NUMERIC(15,2) NOT NULL CHECK (initial_cash >= 0),
    benchmark_id INTEGER,
    CONSTRAINT fk_portfolios_benchmark
        FOREIGN KEY (benchmark_id)
        REFERENCES benchmarks(benchmark_id)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    portfolio_id INTEGER NOT NULL,
    security_id INTEGER NOT NULL,
    transaction_date DATE NOT NULL,
    transaction_type VARCHAR(4) NOT NULL
        CHECK (transaction_type IN ('BUY', 'SELL')),
    quantity NUMERIC(18,6) NOT NULL CHECK (quantity > 0),
    price_per_share NUMERIC(18,4) NOT NULL CHECK (price_per_share >= 0),
    CONSTRAINT fk_transactions_portfolio
        FOREIGN KEY (portfolio_id)
        REFERENCES portfolios(portfolio_id),
    CONSTRAINT fk_transactions_security
        FOREIGN KEY (security_id)
        REFERENCES securities(security_id)
);

CREATE TABLE IF NOT EXISTS daily_prices (
    price_id SERIAL PRIMARY KEY,
    security_id INTEGER NOT NULL,
    price_date DATE NOT NULL,
    open_price NUMERIC(18,4),
    high_price NUMERIC(18,4),
    low_price NUMERIC(18,4),
    close_price NUMERIC(18,4) NOT NULL,
    volume BIGINT,
    CONSTRAINT fk_daily_prices_security
        FOREIGN KEY (security_id)
        REFERENCES securities(security_id),
    CONSTRAINT uq_daily_prices_security_date
        UNIQUE (security_id, price_date)
);

CREATE TABLE IF NOT EXISTS benchmark_prices (
    benchmark_price_id SERIAL PRIMARY KEY,
    benchmark_id INTEGER NOT NULL,
    price_date DATE NOT NULL,
    close_value NUMERIC(18,4) NOT NULL,
    CONSTRAINT fk_benchmark_prices_benchmark
        FOREIGN KEY (benchmark_id)
        REFERENCES benchmarks(benchmark_id),
    CONSTRAINT uq_benchmark_prices_benchmark_date
        UNIQUE (benchmark_id, price_date)
);

CREATE TABLE IF NOT EXISTS dividends (
    dividend_id SERIAL PRIMARY KEY,
    security_id INTEGER NOT NULL,
    ex_date DATE NOT NULL,
    dividend_per_share NUMERIC(18,6) NOT NULL CHECK (dividend_per_share >= 0),
    CONSTRAINT fk_dividends_security
        FOREIGN KEY (security_id)
        REFERENCES securities(security_id),
    CONSTRAINT uq_dividends_security_date
        UNIQUE (security_id, ex_date)
);

CREATE TABLE IF NOT EXISTS stock_splits (
    split_id SERIAL PRIMARY KEY,
    security_id INTEGER NOT NULL,
    split_date DATE NOT NULL,
    split_ratio NUMERIC(12,6) NOT NULL CHECK (split_ratio > 0),
    CONSTRAINT fk_stock_splits_security
        FOREIGN KEY (security_id)
        REFERENCES securities(security_id),
    CONSTRAINT uq_stock_splits_security_date
        UNIQUE (security_id, split_date)
);

-- Helpful indexes for frequently joined and filtered columns.

CREATE INDEX IF NOT EXISTS idx_transactions_portfolio_id
    ON transactions(portfolio_id);

CREATE INDEX IF NOT EXISTS idx_transactions_security_id
    ON transactions(security_id);

CREATE INDEX IF NOT EXISTS idx_transactions_date
    ON transactions(transaction_date);

CREATE INDEX IF NOT EXISTS idx_daily_prices_security_date
    ON daily_prices(security_id, price_date);

CREATE INDEX IF NOT EXISTS idx_benchmark_prices_benchmark_date
    ON benchmark_prices(benchmark_id, price_date);

CREATE INDEX IF NOT EXISTS idx_securities_sector_id
    ON securities(sector_id);

-- Notes:
-- 1. Portfolio transactions are simulated for educational and analytical purposes.
-- 2. Historical security prices used in the project are source-adjusted for stock splits.
--    The stock_splits table is maintained as reference metadata and split ratios are not
--    applied again in portfolio calculations.
-- 3. Dividend data is not currently included in the portfolio return calculation.
