-- Extract Daily Price Information
select
    timestamp as date,
    price as sol_price_usd
from prices.day
where blockchain = 'solana'
    and symbol = 'SOL'
    and timestamp >= date '2024-01-01'
