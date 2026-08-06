  -- Estimate Active (signers) Wallets
select
  date_trunc('day', block_time) as date,
  count(distinct signer) AS active_wallets
from solana.transactions
where block_time >= date '2024-01-01'
group by 1
order by 1 desc
