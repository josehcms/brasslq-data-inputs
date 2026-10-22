################################################################################
### Script: Estimate CT fertility schedules
### Author: josehcms (original script provided by Bruno Masquelier)
### Last update: 2026-10-22
################################################################################

### Housekeeping #--------------------------------------------------------------
source( 'R/00_housekeeping.R' )
################################################################################

### Read data #-----------------------------------------------------------------

a0 = 
  as.data.frame(
    read_excel( 'data/inputs/fertility/coale.trussell.1974_model.fertility_Pop.Index.xlsx',  
                sheet = 1, 
                range = "A1:Q54")
    )
k = 
  as.data.frame(
    read_excel( 'data/inputs/fertility/coale.trussell.1974_model.fertility_Pop.Index.xlsx',  
                sheet = 2, 
                range = "A1:Q54"
                )
    )
m = 
  as.data.frame(
    read_excel( 'data/inputs/fertility/coale.trussell.1974_model.fertility_Pop.Index.xlsx',  
                sheet = 3, 
                range = "A1:Q54"
                )
    )

# adjust to numeric
for(i in 3:17){
  m[,i] = as.numeric(as.character(m[,i]))/1000
}


pagexls = 
  as.data.frame(
    read_excel( 'data/inputs/fertility/coale.trussell.1974_model.fertility_Pop.Index.xlsx', 
                sheet =  4, 
                range = "A1:Q54" 
                )
    )

colxls = 
  as.data.frame(
    read_excel( 'data/inputs/fertility/coale.trussell.1974_model.fertility_Pop.Index.xlsx',  
                sheet =  5, 
                range = "A1:Q54"
                )
    )
################################################################################

### Prepare fertility schedules #-----------------------------------------------
fert_param = 
  data.frame( 
    a0 = unlist(a0[,3:17]), 
    k = unlist(k[,3:17]) , 
    m = unlist(m[,3:17]),  
    page = unlist(pagexls[,3:17]),
    col = unlist(colxls[,3:17])
    )

fert_param = fert_param[order(fert_param$page, fert_param$col),]
fert_param$n_fert = 1:nrow(fert_param)
n_fert = nrow(fert_param)
fert_param = cbind(fert_param, matrix(data = NA, nrow = n_fert, ncol = length(12:49)))
names(fert_param)[7:ncol(fert_param)] = paste0('f', 12:49)
for(i in 1:nrow(fert_param)){
  print(i)
  fert_param[i,7:ncol(fert_param)]= as.vector(CM(a0=fert_param$a0[i], k=fert_param$k[i])$G[10:60 %in% 12:49]*CT(m=fert_param$m[i], M=1))
  fert_param[i,7:ncol(fert_param)] = fert_param[i,7:ncol(fert_param)]/sum(fert_param[i,7:ncol(fert_param)])
}
meanf = apply(fert_param[, 7:ncol(fert_param)]*matrix(data= seq(12.5, 49.5, 1), nrow = n_fert, ncol = length(12:49), byrow= TRUE), 1, sum)
stdevf = sqrt(apply(fert_param[, 7:ncol(fert_param)]*matrix(data= seq(12.5, 49.5, 1)^2, nrow = n_fert, ncol = length(12:49), byrow= TRUE), 1, sum) - meanf^2 -1/12)
fert_param$MEAN = round(meanf)
fert_param$STDEV = trunc(stdevf*10/5)*5/10  
fert_param$SMAM = fert_param$a0 + 11.36*fert_param$k

fert_param$tx_subset = 0
fert_param[fert_param$a0 >= 13 & fert_param$a0 <=15 & fert_param$m <= 1 & fert_param$SMAM >= 18 & 
             fert_param$SMAM <= 21,]$tx_subset = 1

setDT(fert_param)

fert_ct =
  fert_param[ , c( paste0( 'f', 12:49 ), 'tx_subset' ) ] %>%
  .[ , n := 1:.N ] %>%
  data.table::melt(
    id.vars = c( 'n', 'tx_subset' ),
    measure.vars = paste0( 'f', 12:49 ),
    variable.name = 'x',
    value.name = 'fx'
  ) %>%
  .[ , x := as.numeric( paste0( gsub( 'f', '', x ) ) ) ] %>%
  setorder( n, x )
################################################################################

saveRDS( as.data.frame( fert_ct[ , .( id = n, tx_subset, x, fx ) ] ), 
         file = 'data/outputs/01_CT_fertility_schedules.rds' )

