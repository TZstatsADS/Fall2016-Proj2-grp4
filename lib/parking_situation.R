dta = 'Desktop/prj2/pre_instance.geojson'
res1 <- readOGR(dsn = dta, layer = "OGRGeoJSON")

# Add color columns
rule_simp2cha = lapply(res1$rule_simplified, as.character, stringsAsFactors=FALSE)
result1 = lapply(rule_simp2cha, function(x) {ifelse(grepl('From',x),0,1)})
add_rule2cha = lapply(res1$addtl_info_parking_rule, as.character, stringsAsFactors=FALSE)
result2 = lapply(add_rule2cha, function(x) {ifelse(grepl('Metered',x),2,0)})
####################################################
##  0 for free, 1 for No parking, 2 for Mettered  ##
####################################################
street_level = c()
for (i in 1:376) {
  result = result1[[i]] + result2[[i]]
  street_level = append(street_level, result)
}

pal = palette(c('#00FF00','#FF0000','#808080'))
res1$addtl_info_next_period_parking_rule = as.list(street_level)

pal <- colorBin(
  palette = c('#00FF00','#FF0000','#808080'), street_level, 3
)

leaflet() %>% 
  addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  setView(lng = -73.937081, lat = 40.800065, zoom = 17) %>% 
  addPolylines(data = res1 ,opacity = 1 ,color = ~pal(as.numeric(addtl_info_next_period_parking_rule))) %>%
  addMarkers()

