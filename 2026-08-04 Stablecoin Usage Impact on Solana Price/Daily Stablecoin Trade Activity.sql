-- Isolate Stablecoin Trades/Volumes from Dexs
with dex_trades as (select
                        block_date,
                        sum(amount_usd) as stablecoin_volume,
                        count(*) as stablecoin_trades
                    from dex_solana.trades
                    where (token_bought_mint_address in ('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
                                                     'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
                                                     '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',
                                                     'DEkqHyPN7GMRJ5cArtQFAWefqbZb33Hyf6s5iCwjEonT',
                                                     '2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH',
                                                     'A1KLoBrKBde8Ty9qtNQUtq3C2ortoC3u7twggz7sEto6',
                                                     'HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr',
                                                     'USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA',
                                                     '9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u',
                                                     'AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9'
                        ) or token_sold_mint_address in ('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
                                                     'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
                                                     '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',
                                                     'DEkqHyPN7GMRJ5cArtQFAWefqbZb33Hyf6s5iCwjEonT',
                                                     '2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH',
                                                     'A1KLoBrKBde8Ty9qtNQUtq3C2ortoC3u7twggz7sEto6',
                                                     'HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr',
                                                     'USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA',
                                                     '9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u',
                                                     'AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9'
                        ))
                        and block_date >= date '2024-01-01'
                        and trade_source = 'direct'
                    group by 1
                    order by 1 desc),
                
    -- Isolate Stablecoin Trades/Volumes from Aggregators
agg_trades as (select
                    block_date,
                    sum(amount_usd) as stablecoin_volume,
                    count(*) as stablecoin_trades
                from dex_solana.trades
                where (token_bought_mint_address in ('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
                                                     'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
                                                     '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',
                                                     'DEkqHyPN7GMRJ5cArtQFAWefqbZb33Hyf6s5iCwjEonT',
                                                     '2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH',
                                                     'A1KLoBrKBde8Ty9qtNQUtq3C2ortoC3u7twggz7sEto6',
                                                     'HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr',
                                                     'USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA',
                                                     '9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u',
                                                     'AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9'
                    ) or token_sold_mint_address in ('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
                                                     'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
                                                     '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',
                                                     'DEkqHyPN7GMRJ5cArtQFAWefqbZb33Hyf6s5iCwjEonT',
                                                     '2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH',
                                                     'A1KLoBrKBde8Ty9qtNQUtq3C2ortoC3u7twggz7sEto6',
                                                     'HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr',
                                                     'USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA',
                                                     '9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u',
                                                     'AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9'
                    ))
                    and block_date >= date '2024-01-01'
                    and trade_source != 'direct'
                group by 1
                order by 1 desc)
                
    -- Combined Both for Totals
select
    dex.block_date,
    dex.stablecoin_trades + agg.stablecoin_trades as stablecoin_trades,
    dex.stablecoin_volume + agg.stablecoin_volume as stablecoin_volumes
from dex_trades as dex
inner join agg_trades as agg
    on agg.block_date = dex.block_date
order by 1 desc
