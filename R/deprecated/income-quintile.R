# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


## Source setup and function scripts
if (!exists(".setup_sourced")) source(here::here("R/setup.R"))

#-------------------------------------------------------------------------------

# read in the csv
ind_1 <- fread(here::here("input-data", "1_IND.csv"))
print(glimpse(ind_1))

summary(ind_1$`total|income|median|total`)
hist(ind_1$`total|income|median|total`, xlab = "total median income", ylab = "frequency", main = "histogram")

# calculate quintile range of total median income across all years
ind_1 %>%
  filter(`place|name|geo` == "BRITISH COLUMBIA") %>%
  select(`total|income|median|total`) %>%
  quantile(ind_1$`total|income|median|total`, probs =seq(0,1,0.25), na.rm = TRUE)

#-------------------------------------------------------------------------------
# Set up a two-by-two plot array for total median income
par(mfrow = c(2, 2))

# Plot the normalized histogram of the total median income
truehist(ind_1$`total|income|median|total`, xlab = "index", ylab = "total median income", main = "Histogram")

# Plot the density of the total median income
plot(density(ind_1$`total|income|median|total`), xlab = "index", ylab = "total median income", main = "Density plot")

# Plot the density plot of the total median income across all years from ind_1 data table
ggplot(ind_1, aes(x=`total|income|median|total`)) +
  geom_density(bw = 1.5, fill = 'steelblue', alpha = 0.7) +
  # add a rug plot using geom_rug to see individual datapoints, set alpha to 0.5.
  geom_rug(alpha = 0.5) +
  labs(title = 'Total Median Income Distribution', subtitle = "Gaussian kernel SD = 1.5")


#-------------------------------------------------------------------------------

# Set up a two-by-two plot array for age of taxfiler distribution
par(mfrow = c(2, 2))

# Plot the normalized histogram of age distribution
truehist(ind_1$`all|persons|average|age`, xlab = "index", ylab = "Taxfiler age distribution", main = "Histogram")

# Plot the density of age distribution
plot(density(ind_1$`all|persons|average|age`), xlab = "index", ylab = "Taxfiler age distribution", main = "Density plot")

#-------------------------------------------------------------------------------

## Density exploration of data
# density plots for all geographical levels based on total median income
ggplot(ind_1) + geom_density(aes(x = `total|income|median|total`, color = year)) +
  facet_wrap(~ `level|of|geo`, scales = "free") +
  labs(title = "Density plots for geo levels", xlab = "Total median income")

#-------------------------------------------------------------------------------

## Boxplot exploration of data geographies
# all geo levels boxplot

ggplot(ind_1, aes(x= factor(`level|of|geo`), y= `taxfilers|#`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("FSA", "RURPC", "OUA", "CITY", "RURC", "OPROV", "PROV", "CANADA", "CD", "FED", "CMA", "CA", "ER", "CT")) +
  geom_boxplot( fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# provincial geo levels boxplot
ggplot(ind_1, aes(x= factor(`level|of|geo`), y= `total|income|median|total`, group = `level|of|geo`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("FSA", "RURPC", "OUA", "CITY", "RURC", "OPROV", "PROV", "CANADA", "CD", "FED", "CMA", "CA", "ER", "CT")) +
  geom_boxplot(fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Total Median Income", subtitle = "based on geo level", y = "Median Income of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# all geo level boxplot in years
ggplot(ind_1, aes(x= factor(`level|of|geo`), y= `taxfilers|#`, colour = factor(`year`))) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("FSA", "RURPC", "OUA", "CITY", "RURC", "OPROV", "PROV", "CANADA", "CD", "FED", "CMA", "CA", "ER", "CT")) +
  geom_boxplot() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# boxplot removing Canada and provincial level of geo's
ind_1_plot <- ind_1 %>%
  select(`taxfilers|#`,`level|of|geo`) %>%
  filter(ind_1$`level|of|geo` != 11 & ind_1$`level|of|geo` != 12)

ggplot(ind_1_plot, aes(x= factor(`level|of|geo`), y= `taxfilers|#`, group = `level|of|geo`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "21", "31", "41", "42", "51", "61"),
                   labels = c("FSA", "RURPC", "OUA", "CITY", "RURC", "OPROV", "CD", "FED", "CMA", "CA", "ER", "CT")) +
  geom_boxplot(fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# boxplot removing Canada and provincial level of geo's based on years
ind_1_plot <- ind_1 %>%
  select(`taxfilers|#`,`level|of|geo`, `year`) %>%
  filter(ind_1$`level|of|geo` != 11 & ind_1$`level|of|geo` != 12) %>%
  filter(`year` == 2000)

ggplot(ind_1_plot, aes(x= factor(`level|of|geo`), y= `taxfilers|#`, colour = factor(`year`))) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "21", "31", "41", "42", "51", "61"),
                   labels = c("FSA", "RURPC", "OUA", "CITY", "RURC", "OPROV", "CD", "FED", "CMA", "CA", "ER", "CT")) +
  geom_boxplot() + #fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


#-------------------------------------------------------------------------------

# Load the tabplot package: library(tabplot)
# tidy table before tableplot
tableplot(ind_1_plot)

#-------------------------------------------------------------------------------

# pie chart for number of taxfilers in geo areas of interest (i.e. 6, 9, 21, 61)
# Wrangle data into form we want.
pie_plot <- ind_1_plot %>%
  mutate(`level|of|geo` = ifelse(`level|of|geo` %in% c('6', '9', '21', '61'), `level|of|geo`, 'other')) %>%
  group_by(`level|of|geo` ) %>%
  summarise(`taxfilers|#` = sum(`taxfilers|#`)) %>%
  setnames(c("geos", "taxfilers"))

ggplot(pie_plot, aes(x = 1, y = taxfilers, fill = geos)) +
  # Use a column geometry.
  geom_col() +
  # Change coordinate system to polar and set theta to 'y'.
  coord_polar(theta = "y") +
  # Clean up the background with theme_void and give it a proper title with ggtitle.
  #theme_void() +
  ggtitle('Proportion of taxfilers in BC geos')

#-------------------------------------------------------------------------------

# tidy table before tableplot
tableplot(pie_plot)

#-------------------------------------------------------------------------------

# income index for geo level 61 (census tracts)

# year 2000
ind_1 %>%
  filter(`level|of|geo` == 61) %>%
  filter(`year` == 2000) %>%
  select(`total|income|median|total`) %>%
  quantile(ind_1$`total|income|median|total`, probs =seq(0,1,0.25), na.rm = TRUE)

# year 2015
ind_1 %>%
  filter(`level|of|geo` == 61) %>%
  filter(`year` == 2015) %>%
  select(`total|income|median|total`) %>%
  quantile(ind_1$`total|income|median|total`, probs =seq(0,1,0.25), na.rm = TRUE)

# quintile range for geo level 61 for all years
q_61_all <- ind_1 %>%
  select(`year`, `total|income|median|total`, `level|of|geo`) %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 61) %>%
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# quintile range for geo level 61 for year of 2000

q_61_2000 <- ind_1 %>%
  select(`year`, `total|income|median|total`, `level|of|geo`) %>%
  filter(`year` == 2000) %>%
  filter(`level|of|geo` == 61) %>%
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# compare quintiles for all years and for 2000 to test whether grouping works
q_61_all$UQs %in% q_61_2000$UQs

#-------------------------------------------------------------------------------

# income index for geo level 9 (rural areas)

# year 2000
ind_1 %>%
  filter(`level|of|geo` == 9) %>%
  filter(`year` == 2000) %>%
  select(`total|income|median|total`) %>%
  quantile(ind_1$`total|income|median|total`, probs =seq(0,1,0.25), na.rm = TRUE)


# year 2015
ind_1 %>%
  filter(`level|of|geo` == 9) %>%
  filter(`year` == 2015) %>%
  select(`total|income|median|total`) %>%
  quantile(ind_1$`total|income|median|total`, probs =seq(0,1,0.25), na.rm = TRUE)

# quintile range for geo level 9 for all years
q_9_all <- ind_1 %>%
  select(`year`, `total|income|median|total`, `level|of|geo`) %>%
  group_by(`year`) %>%
  filter(`level|of|geo` == 9) %>%
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# quintile range for geo level 9 for year of 2000

q_9_2000 <- ind_1 %>%
  select(`year`, `total|income|median|total`, `level|of|geo`) %>%
  filter(`year` == 2000) %>%
  filter(`level|of|geo` == 9) %>%
  mutate(UQs =  ntile(`total|income|median|total`, 5)) %>%
  ungroup()

# compare quintiles for all years and for 2000 to test whether grouping works
q_9_all$UQs %in% q_9_2000$UQs

#-------------------------------------------------------------------------------

