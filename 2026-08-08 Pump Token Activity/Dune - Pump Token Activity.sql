  -- DEX Trades on $PUMP
select
    block_date,
    count(distinct trader_id) as traders,
    count(case when trader_id in ('9jHrTCwpDANHLNQz5cem6XLUBM8KiTWKe766Br6KVCXM', '99mRw3EzdJZWEUjgp1nrU4WeHsukUBjbh7gYE7pm4F3c', '3vkpy5YHqnqJTnA5doWTpcgKyZiYsaXYzYM9wm8s3WTi') then tx_id else null end) as buybacks,
    count(*) as trades,
    count(case when token_bought_mint_address = 'pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn' then tx_id else null end) as buys,
    sum(amount_usd) as volumes,
    sum(case when token_bought_mint_address = 'pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn' then amount_usd else 0 end) as buy_volumes,
    sum(case when trader_id in ('9jHrTCwpDANHLNQz5cem6XLUBM8KiTWKe766Br6KVCXM', '3vkpy5YHqnqJTnA5doWTpcgKyZiYsaXYzYM9wm8s3WTi', '99mRw3EzdJZWEUjgp1nrU4WeHsukUBjbh7gYE7pm4F3c') then amount_usd else 0 end) as buyback_volumes
from dex_solana.trades
where (token_bought_mint_address = 'pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn'
      or token_sold_mint_address = 'pumpCmXqMfrsAkQ5r49WcJnRayYRqmXz6ae8H7H9Dfn')
    and block_date >= date '2025-07-14'
group by 1
order by 1 desc
