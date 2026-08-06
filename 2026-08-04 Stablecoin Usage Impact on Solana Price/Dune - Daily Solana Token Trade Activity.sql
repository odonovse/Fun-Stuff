-- Isolate the Dex trades
with dex_trades as (select
                        block_date,
                        count(*) as trades,
                        sum(amount_usd) as usd_volumes,
                        sum(case when token_bought_symbol = 'SOL' then token_bought_amount
                                 when token_sold_symbol = 'SOL' then -token_sold_amount else 0 end) as solana_net,
                        sum(case when token_bought_symbol = 'SOL' then token_bought_amount
                                 when token_sold_symbol = 'SOL' then token_sold_amount else 0 end) as solana_volume
                    from dex_solana.trades
                    where block_date > date '2024-01-01'
                        and (token_bought_symbol = 'SOL' or token_sold_symbol = 'SOL')
                    group by 1
                    order by 1 desc),

  -- Isolate the Aggregator Trades
agg_trades as (select
                    block_date,
                    count(*) as trades,
                    sum(amount_usd) as usd_volumes,
                    sum(case when token_bought_symbol = 'SOL' then token_bought_amount
                             when token_sold_symbol = 'SOL' then -token_sold_amount else 0 end) as solana_net,
                    sum(case when token_bought_symbol = 'SOL' then token_bought_amount
                             when token_sold_symbol = 'SOL' then token_sold_amount else 0 end) as solana_volume
                from dex_aggregator.trades
                where (token_bought_symbol = 'SOL' or token_sold_symbol = 'SOL')
                   and block_date > date '2024-01-01'
                group by 1
                order by 1 desc)

-- Combined Both
select
    agg.block_date,
    dex.trades + agg.trades as trades,
    dex.usd_volumes + agg.usd_volumes as usd_volumes,
    dex.solana_net + agg.solana_net as solana_net,
    dex.solana_volume + agg.solana_volume as solana_volume
from agg_trades as agg
inner join dex_trades as dex
    on dex.block_date = agg.block_date
order by 1 desc
