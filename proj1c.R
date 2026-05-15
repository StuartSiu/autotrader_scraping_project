# Web scrapping on AutoTrader search results

# Load necessary libraries
library(tidyverse)
library(rvest)
library(gridExtra)
# Create the table for looping different brands
combine_tbl <- c()

# URL of the search result to scrape
input_url <- "https://www.autotrader.ca/cars/bc/burnaby/?rcp=15&rcs=0&srt=35&yRng=2000%2C&pRng=3000%2C12000&prx=100&prv=British%20Columbia&loc=Burnaby%2C%20BC&body=Convertible%2CCoupe%2CHatchback%2COther%2FDon%27t%20Know%2CSedan&hprc=True&wcp=True&sts=New-Used&inMarket=advancedSearch"

# Create a base with 100 per page, rcs = %d page count, increment of 100 to iterate the next page, "%%20" will avoid error when using sprintf substitution
base_url <- input_url %>% str_replace("rcp=.+&rcs","rcp=100&rcs") %>% str_split_fixed("rcs=[^&]+",2)

# Define columns
desc <- c()
odom <- c()
location <- c()
price <- c()
tbl <- c()

# Iterate through the pagination
# Note that for an unknown reason, the count indicated can be more than the actual number of listings, but the small difference will not affect the the iteration
htmlcode <- read_html(input_url)
nresults <- htmlcode %>% html_node("span.title-count") %>% html_text() %>% str_replace_all("[^\\d]","") %>% as.integer()
iterations <- ceiling(nresults/100)

for (i in 0:(iterations-1)) {
 
  # Construct the URL for the current page
  url <- str_c(base_url[1],base_url[2],sep=str_c("rcs=",i*100))
  
  # Read HTML content from the current page
  htmlcode <- read_html(url)
  
  # The 1st node extracts the "All Listings" to avoid duplicates, the 2nd node is where the displayed text location, then tidy the data and add them to the list
  desc <- htmlcode %>% html_nodes(xpath="//div[@class='col-xs-12 result-item enhanced   organic-qa listing-redesign-dt']/div[2]/div[1]/div/a/div/div[2]/div[2]/div/h2/span/span") %>% html_text() %>% append(desc)
  location <- htmlcode %>% html_nodes(xpath="//div[@class='col-xs-12 result-item enhanced   organic-qa listing-redesign-dt']/div[2]/div[1]/div/a/div/div[2]/div[1]/div[1]/span[1]") %>% html_text() %>% append(location)
  odom <- htmlcode %>% html_nodes(xpath="//div[@class='col-xs-12 result-item enhanced   organic-qa listing-redesign-dt']/div[2]/div[1]/div/a/div/div[2]/div[1]") %>% html_node("span.odometer-proximity") %>% html_text() %>% append(odom)
  price <- htmlcode %>% html_nodes(xpath="//div[@class='col-xs-12 result-item enhanced   organic-qa listing-redesign-dt']/div[2]/div[1]/a/div/div[1]/div/div[1]/div/span[1]") %>% html_text() %>% append(price)
  
}

desc <- desc %>% str_remove_all("\\s\\s") 
location <- location %>% str_remove_all("\\s$") 
odom <- odom %>% str_remove_all("[^\\d]")
price <- price %>% str_remove_all("[^\\d]")

# Combine the data to a table
tbl <- tibble("brand"=str_split_fixed(desc,"\\s",3)[,2],"description"=str_split_fixed(desc,"\\s",3)[,3],"location"=location,"year"=as.integer(str_split_fixed(desc,"\\s",3)[,1]),"odometer"=as.integer(odom),"price"=as.integer(price))

# plot price over mileage and manufacturing year
p1 <- ggplot(filter(tbl,year %in% 2005:2024,odometer<500000),aes(x=odometer,y=log(price))) + geom_point(na.rm=TRUE) + geom_smooth(method="lm",se=FALSE) + ggtitle("Selling price over mileage")
p2 <- ggplot(filter(tbl,year %in% 2005:2024,odometer<500000),aes(x=desc(year),y=log(price))) + geom_point() + geom_smooth(method="lm",se=FALSE) + ggtitle("Selling Price over year built")
grid.arrange(p1,p2,nrow=1)

#Combine with the previous table
combine_tbl <- bind_rows(combine_tbl,tbl)

# Write the table in csv
write.table( combine_tbl, "carprice.csv", sep = ",", row.names = F, col.names = T)
combine_tbl <- read_csv("carprice.csv", col_types=cols(year = col_integer(),odometer = col_integer(),price = col_integer()))
#plot with different brands
comparebrand <- c("MINI","Nissan","Toyota","Hyundai","Honda")
use_tbl <- filter(combine_tbl,odometer<500000,price<100000)
compare_tbl <- filter(use_tbl,brand %in% comparebrand)
p3 <- ggplot(compare_tbl,aes(x=odometer,y=log(price),color=brand)) + geom_smooth(method="lm",se=FALSE) + ggtitle("Selling price over mileage")
p4 <- ggplot(compare_tbl,aes(x=(2024-year),y=log(price),color=brand)) + geom_smooth(method="lm",se=FALSE) + ggtitle("Selling price over age")
grid.arrange(p3,p4,nrow=1)
