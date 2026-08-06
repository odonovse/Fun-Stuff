select
    timestamp,
    price
from prices.day
where blockchain = 'solana'
    and symbol = 'SOL'
    and timestamp >= date '2024-01-01'
