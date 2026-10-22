################################################################################
### Script: Estimate WPP fertility schedules
### Author: josehcms 
### Last update: 2026-10-22
################################################################################

### Housekeeping #--------------------------------------------------------------
source( 'R/00_housekeeping.R' )
################################################################################

### Prepare WPP 2024 data #-----------------------------------------------------
require(wpp2024)

data("percentASFR1dt")

fert_dt =
  percentASFR1dt[ country_code < 900 & year < 2024 & age %in% 10:49, 
                  .( x = age, fx = pasfr / sum( pasfr ) ), .( country_code, name, year ) ] %>%
  setorder( country_code, year, x )

fert_dt[ , id := 1:.N, x ]

fert_dt = 
  fert_dt[ , .( country = name, country_code, year, id, tx_subset = 1, x, fx ) ] %>% 
  setorder( id, x )

saveRDS( as.data.frame( fert_dt ), 
         file = 'data/outputs/01_WPP2024_fertility_schedules.rds' )
################################################################################