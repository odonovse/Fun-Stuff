    -- Extract Stablecoin Information
with raw_data as (select
                        block_date,
                        sum(case when action = 'mint' then amount_display
                                 when action = 'burn' then -amount_display
                                 else 0 end) as net_minted
                    from tokens_solana.transfers
                    where token_mint_address in ('EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',  -- USDC
                                                 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',  -- USDT
                                                 '2b1kV6DkPAnxd5ixfnxCpjxmKwqjjaYmCZfHsFu24GXo',  -- PYUSD
                                                 'DEkqHyPN7GMRJ5cArtQFAWefqbZb33Hyf6s5iCwjEonT',  -- USDe
                                                 '2u1tszSeqZ3qBWF3uNGPFc8TzMk2tdiwknnRMWGWjGWH',  -- USDG
                                                 'A1KLoBrKBde8Ty9qtNQUtq3C2ortoC3u7twggz7sEto6',  -- USDY
                                                 'HzwqbKZw8HxMN6bF2yFZNrht3c2iXXzpKcFu7uBEDKtr',  -- EURC
                                                 'USDSwr9ApdHk5bvJKMjzff41FfuX8bSxdKcR81vTwcA',   -- USDS
                                                 '9zNQRsGLjNKwCUU5Gq5LR8beUCPzQMVMqKAi3SSZh54u',  -- FDUSD
                                                 'AUSD1jCcCyPLybk1YnvPWsHQSrZ46dxwoMniN4N2UEB9'   -- AUSD
                    )
                        and action IN ('mint', 'burn')
                        and block_date < current_date
                        and block_date >= DATE '2024-01-01'
                    group by block_date)

  -- Finalise and Cumulate
select
    block_date,
    net_minted,
    sum(net_minted) over (order by block_date) as total_supply
from raw_data
order by block_date desc
