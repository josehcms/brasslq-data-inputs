################################################################################
### Script: Prepare model life tables mortality schedules
### Author: josehcms 
### Last update: 2025-09-26
################################################################################

### Housekeeping #--------------------------------------------------------------
source( 'R/02_brass_coefficients/00_housekeeping.R' )
################################################################################

### Read data #-----------------------------------------------------------------
mlt = 
  read_excel('data/model_life_tables/MLT_UN2011_130_1y_complete.xlsx') %>%
  as.data.table %>%
  .[ Type %in% c( 'CD North', 'CD West', 'CD South', 'CD East' ) &
       age <= 101 ]
################################################################################

### Prepare mortality data #----------------------------------------------------
mort_mlt = 
  data.table::dcast( 
    mlt,
    Type + E0 + age ~ Sex, value.var = c( 'lx1', 'Lx1', 'mx1', 'ax1' )
  ) %>%
  .[ , lxF := lx1_Female / 100000 ] %>%
  .[ , lxM := lx1_Male / 100000 ] %>%
  .[ , axF := ax1_Female ] %>%
  .[ , axM := ax1_Male ] %>%
  .[ , LxF := Lx1_Female / 100000 ] %>%
  .[ , LxM := Lx1_Male / 100000 ] %>%
  .[ , lxB := lxF * 0.4886 + ( 1 - 0.4886 ) * lxM  ] %>%
  .[ , LxB := LxF * 0.4886 + ( 1 - 0.4886 ) * LxM  ] %>%
  .[ , axB := axF * 0.4886 + ( 1 - 0.4886 ) * axM ] %>%
  .[ , qaB := shift( 1 - lxB / lxB[ age == 0 ], type =  'lead' ), .( Type, E0 ) ] %>%
  .[ , qaF := shift( 1 - lxF / lxF[ age == 0 ], type =  'lead' ), .( Type, E0 ) ] %>%
  .[ age <= 100, .( Type, e0=E0, age, qaB, qaF, LxB, LxF, axB, axF, lxB, lxF ) ] 


################################################################################

### Save
saveRDS( mort_mlt, 
         file = 'data/processed/02_brass_coefficients/02_CD_mortality_model_life_tables.rds' )
