library(duckdb)
con <- dbConnect(duckdb())
dbSendQuery(con, "INSTALL spatial;")
dbSendQuery(con, "LOAD spatial;")
#https://gis.stackexchange.com/questions/145007/creating-geometry-from-lat-lon-in-table-using-postgis