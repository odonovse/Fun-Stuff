################################################################################
# File:        Stablecoin Usage Impact on Solana Price
# Topic:       Tokenomics
# Author:      Sé (@odonovse)
# Created:     2026-08-05
#
# Changelog:
#   2026-08-05  SOD  Initial version.
################################################################################


## 0. Install Necessary Packages ###############################################


    # Packages Needed
  packages <- c(
    "tidyverse", "data.table", "here", "janitor", "lubridate", "readxl", 
    "writexl", "scales", "broom", "ggplot2", "httr2", "car"
  )
  
  for (pkg in packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      message("Installing: ", pkg)
      install.packages(pkg, repos = "https://cloud.r-project.org")
    }
    library(pkg, character.only = TRUE)
  }
  


## 1. Load and Merge the Data ##################################################
  
  
  
    # Load and Clean the Solana Dataset
  data <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-04 Stablecoin Usage Impact on Solana Price/Daily Solana Prices.csv")
  data$timestamp <- as.Date(data$timestamp, format = "%Y-%m-%d %H:%M:%OS", tz = "UTC")
  data$price <- as.numeric(data$price)
  colnames(data) <- c('date', 'price')
  
    # Deal with Duplicates in the data from Dune
  length(data$date)
  length(unique(data$date))
  data <- unique(data) 
  length(data$date)
  
    # Load and Clean the Stablecoin Dataset
  temp <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-04 Stablecoin Usage Impact on Solana Price/Daily Stablecoin Minting.csv")
  temp$block_date <- as.Date(temp$block_date, format = "%Y-%m-%d")
  temp[c("net_minted", "total_supply")] <- lapply(temp[c("net_minted", "total_supply")], as.numeric)
  colnames(temp) <- c('date', 'net.minted', 'total.supply')
  
    # Load and Clean Solana Trades Dataset
  base <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-04 Stablecoin Usage Impact on Solana Price/Daily Solana Trade Volumes.csv")
  base$block_date <- as.Date(base$block_date, format = "%Y-%m-%d")
  base[c("usd_volumes", "solana_net", "solana_volume", "trades")] <- lapply(base[c("usd_volumes", "solana_net", "solana_volume", "trades")], as.numeric)
  colnames(base) <- c('date', 'trades', 'usd.volumes', 'net.solana', 'solana.volumes')
  
    # Load and Clean Wallets Dataset
  addon <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-04 Stablecoin Usage Impact on Solana Price/Daily Active Solana Users.csv")
  addon$date <- as.Date(addon$date, format = "%Y-%m-%d")
  addon$active_wallets <- as.numeric(addon$active_wallets)
  colnames(addon) <- c('date', 'active.wallets')
  
    # Merge the Datasets
  data <- merge(data, temp, by = c('date'), all = FALSE)
  data <- merge(data, base, by = c('date'), all = FALSE)
  data <- merge(data, addon, by = c('date'), all = FALSE)
  
    # Fix Missing Values
  data <- subset(data, !is.na(data$trades))
  

  ## There is an issue with the cumulative sum from Dune, driven alot by an outlier
  ## Observation on 2024-02-15: where net -3299700026 was minted. We need to set
  ## this to Zero and then Recalculate.
  

  
    # Outlier Correction  
  data$net.minted <- ifelse(data$date == '2024-02-15', 0, data$net.minted)
  data$total.supply <- cumsum(data$net.minted)
  data$net.solana <- ifelse(data$net.solana > 1000000000000 | data$net.solana < -1000000000000,
                            0, data$net.solana)
  data$solana.volumes <- ifelse(data$solana.volumes > 1000000000000 | data$net.solana < -1000000000000,
                             0, data$solana.volumes)
  
  
  
  
## 2. Basic Visualisation and Summary Statistics ###############################
  
  
  
  
    # Visualise the Stablecoin Supply Overtime
  fig <- ggplot(data, aes(x = date, y = total.supply/1000000000))
  fig <- fig + geom_line(colour = '#74c69d', linewidth = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#40916c', alpha = 1, span = 0.1)
  fig <- fig + labs(x = '', y = 'Stablecoin Supply (Bn)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig
  
    # Visualise the Solana Price
  fig <- ggplot(data, aes(x = date, y = price))
  fig <- fig + geom_line(colour = '#2a9d8f', linewidth = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#264653', alpha = 1, span = 0.1)
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig
  
    # Visualise Solana Trades
  fig <- ggplot(data, aes(x = date, y = trades))
  fig <- fig + geom_line(colour = '#f4a261', linewidth = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#e76f51', alpha = 1, span = 0.1)
  fig <- fig + labs(x = '', y = 'Solana Token Trades')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig  
  
    # Visualise Solana Trades
  fig <- ggplot(data, aes(x = date, y = active.wallets))
  fig <- fig + geom_line(colour = '#ffb703', linewidth = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#ff6d00', alpha = 1, span = 0.1)
  fig <- fig + labs(x = '', y = 'Active Wallets')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig  
  
  
  
## 3. Assess Basic Relationship Between Stablecoin Supply and Solana Price #####
  

  
    # Estimate the Naive Correlation
  cor(data$price, data$total.supply)
  data$year <- year(data$date)
  data$monthly.date <- format(data$date, "%Y-%m")
  data$day.of.week <- weekdays(data$date)
  data$month <- month(data$date)
  
    # Naive Scatterplot
  fig <- ggplot(data, aes(x = total.supply/1000000, y = price))
  fig <- fig + geom_point(size = 2, alpha = 0.5, colour = '#b185db')
  fig <- fig + geom_smooth(method = 'lm', formula = y ~ poly(x, 1), se = FALSE, linewidth = 1.2, 
                           alpha = 1, span = 0.4, colour = '#6247aa')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Solana Price ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig    
  
    # Split by Year
  fig <- ggplot(data, aes(x = total.supply/1000000, y = price, colour = factor(year)))
  fig <- fig + geom_point(size = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'lm', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           alpha = 1, span = 0.1)
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Solana Price ($)', colour = 'Year:')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5),
                     legend.position = 'bottom')
  fig <- fig + scale_colour_manual(values = c('2024' = '#264653', '2025' = '#e76f51', '2026' = '#e9c46a'))
  fig  
  
    
  
  ## There seems to be a break in the series when there was a large surge in
  ## stablecoin minting at the start of 2025, so lets assume two different
  ## regimes are present
  
  
  
    # Generate Flag and Visualise
  data$regime.change <- ifelse(data$total.supply/1000000000 < 6, 'Less than 6bn Supply', 'Above 6bn Supply')
  fig <- ggplot(data, aes(x = total.supply/1000000, y = price, colour = factor(regime.change)))
  fig <- fig + geom_point(size = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'lm', formula = y ~ poly(x, 1), se = FALSE, linewidth = 1.2, 
                           alpha = 1)
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Solana Price ($)', colour = 'Regime:')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5),
                     legend.position = 'bottom')
  fig <- fig + scale_colour_manual(values = c('Less than 6bn Supply' = '#264653', 'Above 6bn Supply' = '#40916c'))
  fig  
  
  
  
  ## We can also try an Econometric approach, even a rough basic one. Below
  ## we can run a basic OLS regression of Stablecoin token supply against the
  ## Solana price (in USD), with an assumed quadratic relationship.
  
  
  
    # Estimate Squared Supply
  data$total.supply.sq <- data$total.supply^2
  
    # Run Basic OLS Regression with Fixed Effects
  reg <- lm(data, formula = price ~ total.supply + total.supply.sq)
  summary(reg)
  car::vif(reg)
  
    # Estimate the Combined Stablecoin Effect
  data$stablecoin.effect <- coef(reg)[2]*data$total.supply + coef(reg)[3]*data$total.supply.sq
  data$stablecoin.effect.pct <- data$stablecoin.effect/data$price
  
    # Visualise the Relationship
  fig <- ggplot(data, aes(x = total.supply/1000000, y = stablecoin.effect))
  fig <- fig + geom_line(size = 2, alpha = 1, colour = '#2d6a4f')
  fig <- fig + geom_hline(yintercept = 0, size = 0.5, colour = 'black', linetype = 'dashed')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Price Impact on Solana ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig   
  
    # Visualise the Estimated Impact - Absolute
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#b185db', linewidth = 2, alpha = 0.5, aes(y = price))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#6247aa', alpha = 1, span = 0.1, aes(y = price))
  fig <- fig + geom_line(colour = '#40916c', linewidth = 2, alpha = 0.5, aes(y = price - stablecoin.effect))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#2d6a4f', alpha = 1, span = 0.1, aes(y = price - stablecoin.effect))
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + annotate('text', x = as.Date('2025-01-01'), y = 80, colour = '#2d6a4f', 
                        label = 'No Stablecoins', size = 8, fontface = 2)
  fig <- fig + annotate('text', x = as.Date('2024-08-01'), y = 260, colour = '#6247aa', 
                        label = 'Actual Price', size = 8, fontface = 2)
  fig   
  
    # Visualise the Estimated Impact (Pct)
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#52b788', linewidth = 2, alpha = 0.5, aes(y = stablecoin.effect.pct))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#2d6a4f', alpha = 1, span = 0.1, aes(y = stablecoin.effect.pct))
  fig <- fig + labs(x = '', y = 'Solana Price Effect (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, linetype = 'dashed', size = 0.5, colour = 'black')
  fig     
  
  
  
  ## We can then make the estimation a bit more robust by controlling for other
  ## potential effects like net solana purchases, the number of daily active wallets
  ## or day of the week or month of the year effects.
  
 
  
    # Run Basic OLS Regression with Fixed Effects
  reg <- lm(data, formula = price ~ total.supply + total.supply.sq + net.solana + 
              active.wallets + factor(day.of.week) + factor(month))
  summary(reg)  
  car::vif(reg)
  data$stablecoin.effect <- coef(reg)[2]*data$total.supply + coef(reg)[3]*data$total.supply.sq
  data$stablecoin.effect.pct <- data$stablecoin.effect/data$price
  
    # Visualise the Relationship
  fig <- ggplot(data, aes(x = total.supply/1000000, y = stablecoin.effect))
  fig <- fig + geom_line(size = 2, alpha = 1, colour = '#e76f51')
  fig <- fig + geom_hline(yintercept = 0, size = 0.5, colour = 'black', linetype = 'dashed')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Price Impact on Solana ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig   
  
    # Visualise the Estimated Impact - Absolute
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#b185db', linewidth = 2, alpha = 0.5, aes(y = price))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#6247aa', alpha = 1, span = 0.1, aes(y = price))
  fig <- fig + geom_line(colour = '#e9c46a', linewidth = 2, alpha = 0.5, aes(y = price - stablecoin.effect))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#e76f51', alpha = 1, span = 0.1, aes(y = price - stablecoin.effect))
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + annotate('text', x = as.Date('2025-01-01'), y = 80, colour = '#e76f51', 
                        label = 'No Stablecoins', size = 8, fontface = 2)
  fig <- fig + annotate('text', x = as.Date('2024-08-01'), y = 260, colour = '#6247aa', 
                        label = 'Actual Price', size = 8, fontface = 2)
  fig   
  
    # Visualise the Estimated Impact (Pct)
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#e9c46a', linewidth = 2, alpha = 0.5, aes(y = stablecoin.effect.pct))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#e76f51', alpha = 1, span = 0.1, aes(y = stablecoin.effect.pct))
  fig <- fig + labs(x = '', y = 'Solana Price Effect (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, linetype = 'dashed', size = 0.5, colour = 'black')
  fig   
  
  
  
  ## One last addition that we can do is to also incorporate year fixed effects
  ## to try and control for larger macro trends as well

  
  
    # Run Basic OLS Regression with Fixed Effects
  reg <- lm(data, formula = price ~ total.supply + total.supply.sq + net.solana + 
              active.wallets + factor(day.of.week) + factor(month) + factor(year))
  summary(reg)  
  car::vif(reg)
  data$stablecoin.effect <- coef(reg)[2]*data$total.supply + coef(reg)[3]*data$total.supply.sq
  data$stablecoin.effect.pct <- data$stablecoin.effect/data$price
  
    # Visualise the Relationship
  fig <- ggplot(data, aes(x = total.supply/1000000, y = stablecoin.effect))
  fig <- fig + geom_line(size = 2, alpha = 1, colour = '#073b4c')
  fig <- fig + geom_hline(yintercept = 0, size = 0.5, colour = 'black', linetype = 'dashed')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Price Impact on Solana ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig   
  
    # Visualise the Estimated Impact - Absolute
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#b185db', linewidth = 2, alpha = 0.5, aes(y = price))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#6247aa', alpha = 1, span = 0.1, aes(y = price))
  fig <- fig + geom_line(colour = '#118ab2', linewidth = 2, alpha = 0.5, aes(y = price - stablecoin.effect))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#073b4c', alpha = 1, span = 0.1, aes(y = price - stablecoin.effect))
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + annotate('text', x = as.Date('2025-01-01'), y = 20, colour = '#073b4c', 
                        label = 'No Stablecoins', size = 8, fontface = 2)
  fig <- fig + annotate('text', x = as.Date('2024-08-01'), y = 260, colour = '#6247aa', 
                        label = 'Actual Price', size = 8, fontface = 2)
  fig   
  
    # Visualise the Estimated Impact (Pct)
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#118ab2', linewidth = 2, alpha = 0.5, aes(y = stablecoin.effect.pct))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#073b4c', alpha = 1, span = 0.1, aes(y = stablecoin.effect.pct))
  fig <- fig + labs(x = '', y = 'Solana Price Effect (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, linetype = 'dashed', size = 0.5, colour = 'black')
  fig     
  
  
  
  ## Multicolinearity is very high for these regressions, driven alot by the quadratic
  ## terms, but that is expected and acceptable. However, as a check we can remove
  ## the square and re-estimate the model
  
  
  
    # Run Basic OLS Regression with Fixed Effects
  reg <- lm(data, formula = price ~ total.supply + net.solana + 
              active.wallets + factor(day.of.week) + factor(month) + factor(year))
  summary(reg)  
  car::vif(reg)
  data$stablecoin.effect <- coef(reg)[2]*data$total.supply
  data$stablecoin.effect.pct <- data$stablecoin.effect/data$price
  
    # Visualise the Relationship
  fig <- ggplot(data, aes(x = total.supply/1000000, y = stablecoin.effect))
  fig <- fig + geom_line(size = 2, alpha = 1, colour = '#b58463')
  fig <- fig + geom_hline(yintercept = 0, size = 0.5, colour = 'black', linetype = 'dashed')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Price Impact on Solana ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig   
  
    # Visualise the Estimated Impact - Absolute
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#b185db', linewidth = 2, alpha = 0.5, aes(y = price))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#6247aa', alpha = 1, span = 0.1, aes(y = price))
  fig <- fig + geom_line(colour = '#d7bea8', linewidth = 2, alpha = 0.5, aes(y = price - stablecoin.effect))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#b58463', alpha = 1, span = 0.1, aes(y = price - stablecoin.effect))
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + annotate('text', x = as.Date('2025-01-01'), y = 80, colour = '#b58463', 
                        label = 'No Stablecoins', size = 8, fontface = 2)
  fig <- fig + annotate('text', x = as.Date('2024-08-01'), y = 260, colour = '#6247aa', 
                        label = 'Actual Price', size = 8, fontface = 2)
  fig   
  
    # Visualise the Estimated Impact (Pct)
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#d7bea8', linewidth = 2, alpha = 0.5, aes(y = stablecoin.effect.pct))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#b58463', alpha = 1, span = 0.1, aes(y = stablecoin.effect.pct))
  fig <- fig + labs(x = '', y = 'Solana Price Effect (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, linetype = 'dashed', size = 0.5, colour = 'black')
  fig     
  
  
  
  
## 4. Incorporate Stablecoin Trading Activity ##################################
  
  
  
    # Load and Clean Wallets Dataset
  temp <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-04 Stablecoin Usage Impact on Solana Price/Daily Stablecoin Trades.csv")
  temp$block_date <- as.Date(temp$block_date, format = "%Y-%m-%d")
  temp[c("stablecoin_trades", "stablecoin_volumes")] <- lapply(temp[c("stablecoin_trades", "stablecoin_volumes")], as.numeric)
  colnames(temp) <- c('date', "stablecoin.trades", "stablecoin.volumes")
  
    # Merge the Data and Clean
  data <- merge(data, temp, all = FALSE)
  data$stablecoin.volumes <- ifelse(data$stablecoin.volumes > 1000000000, 1000000000, data$stablecoin.volumes)
  
    # Plot the Trades Overtime
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#e39695', linewidth = 2, alpha = 0.5, aes(y = stablecoin.volumes))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#ff595e', alpha = 1, span = 0.1, aes(y = stablecoin.volumes))
  fig <- fig + labs(x = '', y = 'Stablecoin Trades')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig     

    # Run Basic OLS Regression with Fixed Effects
  data$stablecoin.trades.sq <- data$stablecoin.trades^2
  data$stablecoin.volumes.sq <- data$stablecoin.volumes^2
  reg <- lm(data, formula = price ~ stablecoin.trades + stablecoin.trades.sq + trades +  
              active.wallets + factor(day.of.week) + factor(month) + factor(year))
  summary(reg)  
  car::vif(reg)
  data$stablecoin.effect <- coef(reg)[2]*data$stablecoin.trades + coef(reg)[3]*data$stablecoin.trades.sq
  data$stablecoin.effect.pct <- data$stablecoin.effect/data$price
  
  # Visualise the Relationship
  fig <- ggplot(data, aes(x = total.supply/1000000, y = stablecoin.effect))
  fig <- fig + geom_line(size = 2, alpha = 1, colour = '#ff595e')
  fig <- fig + geom_hline(yintercept = 0, size = 0.5, colour = 'black', linetype = 'dashed')
  fig <- fig + labs(x = 'Stablecoin Supply (Millions)', y = 'Price Impact on Solana ($)')
  fig <- fig + scale_x_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig   
  
  # Visualise the Estimated Impact - Absolute
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#b185db', linewidth = 2, alpha = 0.5, aes(y = price))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#6247aa', alpha = 1, span = 0.1, aes(y = price))
  fig <- fig + geom_line(colour = '#e39695', linewidth = 2, alpha = 0.5, aes(y = price - stablecoin.effect))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#ff595e', alpha = 1, span = 0.1, aes(y = price - stablecoin.effect))
  fig <- fig + labs(x = '', y = 'Solana Price ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + annotate('text', x = as.Date('2025-01-01'), y = 80, colour = '#ff595e', 
                        label = 'No Stablecoins', size = 8, fontface = 2)
  fig <- fig + annotate('text', x = as.Date('2024-08-01'), y = 260, colour = '#6247aa', 
                        label = 'Actual Price', size = 8, fontface = 2)
  fig   
  
  # Visualise the Estimated Impact (Pct)
  fig <- ggplot(data, aes(x = date))
  fig <- fig + geom_line(colour = '#e39695', linewidth = 2, alpha = 0.5, aes(y = stablecoin.effect.pct))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#ff595e', alpha = 1, span = 0.1, aes(y = stablecoin.effect.pct))
  fig <- fig + labs(x = '', y = 'Solana Price Effect (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, linetype = 'dashed', size = 0.5, colour = 'black')
  fig    
  