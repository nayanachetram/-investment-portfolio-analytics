/* =========================================================
   Investment Portfolio Analytics
   PostgreSQL
   Portfolio: Alpha Growth Portfolio
   ========================================================= */


/* =========================================================
   01. CURRENT HOLDINGS
   Calculates current shares held for each security
   ========================================================= */

SELECT
    s.ticker,
    s.company_name,
    SUM(
        CASE
            WHEN t.transaction_type = 'BUY' THEN t.quantity
            WHEN t.transaction_type = 'SELL' THEN -t.quantity
        END
    ) AS shares_held
FROM transactions t
JOIN securities s
    ON t.security_id = s.security_id
WHERE t.portfolio_id = 1
GROUP BY s.security_id, s.ticker, s.company_name
HAVING SUM(
    CASE
        WHEN t.transaction_type = 'BUY' THEN t.quantity
        WHEN t.transaction_type = 'SELL' THEN -t.quantity
    END
) > 0
ORDER BY s.ticker;


/* =========================================================
   02. CURRENT CASH BALANCE
   Starting cash - purchases + sale proceeds
   ========================================================= */

SELECT
    ROUND(
        p.initial_cash
        - SUM(
            CASE
                WHEN t.transaction_type = 'BUY'
                    THEN t.quantity * t.price_per_share
                WHEN t.transaction_type = 'SELL'
                    THEN -(t.quantity * t.price_per_share)
            END
        ),
        2
    ) AS current_cash
FROM portfolios p
JOIN transactions t
    ON p.portfolio_id = t.portfolio_id
WHERE p.portfolio_id = 1
GROUP BY p.initial_cash;


/* =========================================================
   03. CURRENT POSITION MARKET VALUES
   Shares held x latest available closing price
   ========================================================= */

WITH holdings AS (
    SELECT
        security_id,
        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                WHEN transaction_type = 'SELL' THEN -quantity
            END
        ) AS shares_held
    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        price_date,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
)

SELECT
    s.ticker,
    h.shares_held,
    lp.price_date,
    lp.close_price AS latest_price,
    ROUND(h.shares_held * lp.close_price, 2) AS market_value
FROM holdings h
JOIN securities s
    ON h.security_id = s.security_id
JOIN latest_prices lp
    ON h.security_id = lp.security_id
ORDER BY market_value DESC;


/* =========================================================
   04. TOTAL PORTFOLIO VALUE
   Total stock market value + cash
   ========================================================= */

WITH holdings AS (
    SELECT
        security_id,
        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                WHEN transaction_type = 'SELL' THEN -quantity
            END
        ) AS shares_held
    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
),

stock_value AS (
    SELECT
        SUM(h.shares_held * lp.close_price) AS total_stock_value
    FROM holdings h
    JOIN latest_prices lp
        ON h.security_id = lp.security_id
),

cash AS (
    SELECT
        p.initial_cash
        - SUM(
            CASE
                WHEN t.transaction_type = 'BUY'
                    THEN t.quantity * t.price_per_share
                WHEN t.transaction_type = 'SELL'
                    THEN -(t.quantity * t.price_per_share)
            END
        ) AS cash_balance
    FROM portfolios p
    JOIN transactions t
        ON p.portfolio_id = t.portfolio_id
    WHERE p.portfolio_id = 1
    GROUP BY p.initial_cash
)

SELECT
    ROUND(s.total_stock_value, 2) AS stock_value,
    ROUND(c.cash_balance, 2) AS cash_balance,
    ROUND(s.total_stock_value + c.cash_balance, 2)
        AS total_portfolio_value
FROM stock_value s
CROSS JOIN cash c;


/* =========================================================
   05. PORTFOLIO WEIGHTS
   Each position as % of invested stock value
   Cash is excluded from this allocation calculation
   ========================================================= */

WITH holdings AS (
    SELECT
        security_id,
        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                WHEN transaction_type = 'SELL' THEN -quantity
            END
        ) AS shares_held
    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
),

position_values AS (
    SELECT
        h.security_id,
        h.shares_held * lp.close_price AS market_value
    FROM holdings h
    JOIN latest_prices lp
        ON h.security_id = lp.security_id
)

SELECT
    s.ticker,
    ROUND(pv.market_value, 2) AS market_value,
    ROUND(
        pv.market_value
        / SUM(pv.market_value) OVER () * 100,
        2
    ) AS portfolio_weight_pct
FROM position_values pv
JOIN securities s
    ON pv.security_id = s.security_id
ORDER BY portfolio_weight_pct DESC;


/* =========================================================
   06. SECTOR EXPOSURE
   Market value and stock allocation by GICS sector
   ========================================================= */

WITH holdings AS (
    SELECT
        security_id,
        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                WHEN transaction_type = 'SELL' THEN -quantity
            END
        ) AS shares_held
    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
),

position_values AS (
    SELECT
        h.security_id,
        h.shares_held * lp.close_price AS market_value
    FROM holdings h
    JOIN latest_prices lp
        ON h.security_id = lp.security_id
)

SELECT
    sec.sector_name,
    ROUND(SUM(pv.market_value), 2) AS sector_market_value,
    ROUND(
        SUM(pv.market_value)
        / SUM(SUM(pv.market_value)) OVER () * 100,
        2
    ) AS sector_weight_pct
FROM position_values pv
JOIN securities s
    ON pv.security_id = s.security_id
JOIN sectors sec
    ON s.sector_id = sec.sector_id
GROUP BY sec.sector_name
ORDER BY sector_weight_pct DESC;


/* =========================================================
   07. TOP-5 CONCENTRATION
   Percentage of stock portfolio held in largest 5 positions
   ========================================================= */

WITH holdings AS (
    SELECT
        security_id,
        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                WHEN transaction_type = 'SELL' THEN -quantity
            END
        ) AS shares_held
    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
),

position_values AS (
    SELECT
        h.security_id,
        h.shares_held * lp.close_price AS market_value
    FROM holdings h
    JOIN latest_prices lp
        ON h.security_id = lp.security_id
),

ranked AS (
    SELECT
        security_id,
        market_value,
        ROW_NUMBER() OVER (
            ORDER BY market_value DESC
        ) AS position_rank
    FROM position_values
)

SELECT
    ROUND(
        SUM(
            CASE
                WHEN position_rank <= 5 THEN market_value
                ELSE 0
            END
        )
        / SUM(market_value) * 100,
        2
    ) AS top_5_concentration_pct
FROM ranked;


/* =========================================================
   08. PORTFOLIO VS. S&P 500
   Price-return comparison over the analyzed period
   ========================================================= */

WITH portfolio_value AS (
    SELECT
        1000000.00::NUMERIC AS starting_value,
        1703201.03::NUMERIC AS ending_value
),

benchmark_values AS (
    SELECT
        (
            SELECT close_value
            FROM benchmark_prices
            WHERE benchmark_id = 1
            ORDER BY price_date ASC
            LIMIT 1
        ) AS starting_value,

        (
            SELECT close_value
            FROM benchmark_prices
            WHERE benchmark_id = 1
            ORDER BY price_date DESC
            LIMIT 1
        ) AS ending_value
)

SELECT
    ROUND(
        ((p.ending_value / p.starting_value) - 1) * 100,
        2
    ) AS portfolio_return_pct,

    ROUND(
        ((b.ending_value / b.starting_value) - 1) * 100,
        2
    ) AS sp500_return_pct,

    ROUND(
        (
            ((p.ending_value / p.starting_value) - 1)
            -
            ((b.ending_value / b.starting_value) - 1)
        ) * 100,
        2
    ) AS excess_return_pct
FROM portfolio_value p
CROSS JOIN benchmark_values b;


/* =========================================================
   09. NET GAIN / LOSS BY SECURITY
   Current value compared with net cash invested
   This is not strict lot-based unrealized P&L
   ========================================================= */

WITH trade_summary AS (
    SELECT
        security_id,

        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                ELSE -quantity
            END
        ) AS shares_held,

        SUM(
            CASE
                WHEN transaction_type = 'BUY'
                    THEN quantity * price_per_share
                ELSE -(quantity * price_per_share)
            END
        ) AS net_invested

    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
)

SELECT
    s.ticker,
    ROUND(ts.net_invested, 2) AS net_invested,
    ROUND(
        ts.shares_held * lp.close_price,
        2
    ) AS current_value,
    ROUND(
        (ts.shares_held * lp.close_price)
        - ts.net_invested,
        2
    ) AS net_gain_loss
FROM trade_summary ts
JOIN securities s
    ON ts.security_id = s.security_id
JOIN latest_prices lp
    ON ts.security_id = lp.security_id
ORDER BY net_gain_loss DESC;


/* =========================================================
   10. RETURN CONTRIBUTION
   Net gain/loss expressed as percentage points relative
   to the portfolio's original $1,000,000 capital
   ========================================================= */

WITH trade_summary AS (
    SELECT
        security_id,

        SUM(
            CASE
                WHEN transaction_type = 'BUY' THEN quantity
                ELSE -quantity
            END
        ) AS shares_held,

        SUM(
            CASE
                WHEN transaction_type = 'BUY'
                    THEN quantity * price_per_share
                ELSE -(quantity * price_per_share)
            END
        ) AS net_invested

    FROM transactions
    WHERE portfolio_id = 1
    GROUP BY security_id
),

latest_prices AS (
    SELECT DISTINCT ON (security_id)
        security_id,
        close_price
    FROM daily_prices
    ORDER BY security_id, price_date DESC
)

SELECT
    s.ticker,

    ROUND(
        (ts.shares_held * lp.close_price)
        - ts.net_invested,
        2
    ) AS net_gain_loss,

    ROUND(
        (
            (
                (ts.shares_held * lp.close_price)
                - ts.net_invested
            )
            / 1000000.00
        ) * 100,
        2
    ) AS return_contribution_pct

FROM trade_summary ts
JOIN securities s
    ON ts.security_id = s.security_id
JOIN latest_prices lp
    ON ts.security_id = lp.security_id
ORDER BY return_contribution_pct DESC;


/* =========================================================
   SUPPLEMENTARY VISUALIZATION QUERY

   PORTFOLIO VS. S&P 500 OVER TIME
   Reconstructs daily portfolio value and normalizes both
   the portfolio and benchmark to a starting value of 100.
   ========================================================= */

WITH dates AS (
    SELECT DISTINCT price_date
    FROM daily_prices
    WHERE price_date >= '2024-01-08'
),

daily_holdings AS (
    SELECT
        d.price_date,
        s.security_id,
        COALESCE(
            SUM(
                CASE
                    WHEN t.transaction_type = 'BUY' THEN t.quantity
                    WHEN t.transaction_type = 'SELL' THEN -t.quantity
                END
            ),
            0
        ) AS shares_held
    FROM dates d
    CROSS JOIN securities s
    LEFT JOIN transactions t
        ON t.security_id = s.security_id
        AND t.portfolio_id = 1
        AND t.transaction_date <= d.price_date
    GROUP BY d.price_date, s.security_id
),

daily_stock_value AS (
    SELECT
        dh.price_date,
        SUM(dh.shares_held * dp.close_price) AS stock_value
    FROM daily_holdings dh
    JOIN daily_prices dp
        ON dh.security_id = dp.security_id
        AND dh.price_date = dp.price_date
    GROUP BY dh.price_date
),

daily_cash AS (
    SELECT
        d.price_date,
        1000000.00 -
        COALESCE(
            SUM(
                CASE
                    WHEN t.transaction_type = 'BUY'
                        THEN t.quantity * t.price_per_share
                    WHEN t.transaction_type = 'SELL'
                        THEN -(t.quantity * t.price_per_share)
                END
            ),
            0
        ) AS cash_balance
    FROM dates d
    LEFT JOIN transactions t
        ON t.portfolio_id = 1
        AND t.transaction_date <= d.price_date
    GROUP BY d.price_date
),

portfolio_values AS (
    SELECT
        dsv.price_date,
        dsv.stock_value + dc.cash_balance AS portfolio_value
    FROM daily_stock_value dsv
    JOIN daily_cash dc
        ON dsv.price_date = dc.price_date
),

combined AS (
    SELECT
        pv.price_date,
        pv.portfolio_value,
        bp.close_value AS sp500_value
    FROM portfolio_values pv
    JOIN benchmark_prices bp
        ON pv.price_date = bp.price_date
        AND bp.benchmark_id = 1
),

normalized AS (
    SELECT
        price_date,
        portfolio_value,
        sp500_value,

        FIRST_VALUE(portfolio_value) OVER (
            ORDER BY price_date
        ) AS starting_portfolio_value,

        FIRST_VALUE(sp500_value) OVER (
            ORDER BY price_date
        ) AS starting_sp500_value

    FROM combined
)

SELECT
    price_date,

    ROUND(
        portfolio_value / starting_portfolio_value * 100,
        2
    ) AS portfolio_index,

    ROUND(
        sp500_value / starting_sp500_value * 100,
        2
    ) AS sp500_index

FROM normalized
ORDER BY price_date;
