################################################################################
# File:        Pump Token Activity
# Topic:       Tokenomics
# Author:      Sé (@odonovse)
# Created:     2026-08-08
#
# Changelog:
#   2026-08-08 - SOD - Initial version.
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
  data <- read.csv("~/Documents/GitHub/Fun-Stuff/2026-08-08 Pump Token Activity/Pump Token Activity.csv")
  data$block_date <- as.Date(data$block_date, format = "%Y-%m-%d")
  data[names(data) != "block_date"] <- lapply(data[names(data) != "block_date"], as.numeric)
  colnames(data) <- c('date', 'traders', 'buybacks', 'trades', 'buys', 'volumes', 'buy.volumes', 'buyback.volumes')
  
    # Estimate Buyback Penetration
  data$buyback.share <- data$buybacks/data$buys
  data$net.volume <- data$buy.volumes - (data$volumes - data$buy.volumes)
  data$net.volume.excl.buybacks <- data$buy.volumes - (data$volumes - data$buy.volumes) - data$buyback.volumes
  
    # Visualise the BuyBack Share
  fig <- ggplot(data[data$date >= as.Date('2026-05-01'),], aes(x = date, y = buyback.share))
  fig <- fig + geom_line(colour = '#2a9d8f', linewidth = 2, alpha = 0.5)
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#264653', alpha = 1, span = 0.5)
  fig <- fig + labs(x = '', y = 'Buyback Share of Buys (%)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::percent)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig
  
    # Estimate Average Purchase Size
  data$avg.purchase <- data$volumes/data$traders

    # Visualise the BuyBack Share
  fig <- ggplot(data[data$date >= as.Date('2026-05-01'),], aes(x = date))
  fig <- fig + geom_line(colour = '#74c69d', linewidth = 2, alpha = 0.5, aes(y = net.volume))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#40916c', alpha = 1, span = 0.3, aes(y = net.volume))
  fig <- fig + geom_line(colour = '#ffb703', linewidth = 2, alpha = 0.5, aes(y = net.volume.excl.buybacks))
  fig <- fig + geom_smooth(method = 'loess', formula = y ~ x, se = FALSE, linewidth = 1.2, 
                           colour = '#ff6d00', alpha = 1, span = 0.3, aes(y = net.volume.excl.buybacks))
  fig <- fig + labs(x = '', y = '$PUMP Net Volumes ($)')
  fig <- fig + scale_x_date(breaks = scales::breaks_pretty(n = 10), date_labels = "%Y-%m")
  fig <- fig + scale_y_continuous(breaks = scales::breaks_pretty(n = 10), label = scales::comma)
  fig <- fig + theme_minimal()
  fig <- fig + theme(axis.title.x = element_text(size = 15),
                     axis.title.y = element_text(size = 15),
                     axis.text = element_text(size = 12),
                     axis.line    = element_line(colour = 'black', linewidth = 0.5))
  fig <- fig + geom_hline(yintercept = 0, colour = 'black', size = 0.5, linetype = 'dashed')
  fig <- fig + annotate('text', x = as.Date('2026-07-01'), y = 1500000, size = 8, fontface = 2, label = 'Net Volumes', colour = '#40916c')
  fig <- fig + annotate('text', x = as.Date('2026-06-20'), y = -1750000, size = 8, fontface = 2, label = 'Net Volumes (Excl. Burns)', colour = '#ff6d00')
  fig
  
  
  
  