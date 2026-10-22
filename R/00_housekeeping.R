### Prepare working environment
rm( list = ls() )
gc( reset = TRUE )
graphics.off()

.packages <- 
  c( 'data.table', 'tidyverse', 'devtools',
     'readxl', 'fmsb', 'conflicted', 'haven' )

.inst <- 
  .packages %in% installed.packages()

if( length( .packages[ !.inst ] ) > 0 ){
  install.packages( .packages[ !.inst ], dependencies = TRUE )
}

lapply( .packages, require, character.only = TRUE )
options( timeout = 1000000 )

if( !require( logquad5q0 ) ) devtools::install_github( repo = "verhulsta/logquad5q0" )
if( !require( wpp2024 ) ) devtools::install_github( repo = "PPgp/wpp2024" )
if( !require( wpp2024extra ) ) devtools::install_github( repo = "PPgp/wpp2024extra" )
