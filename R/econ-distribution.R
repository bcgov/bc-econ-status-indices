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

# install/load packages and dependencies
library(here)
library(data.table)
library(dplyr)
library(readr)
library(ggplot2)
library(lattice)
library(MASS)
library(tabplot)

#-------------------------------------------------------------------------------

# read in the csv
ind_1 <- fread(here("input-data", "1_IND.csv"))
head(ind_1)
dim(ind_1)
summary(ind_1$`total|income|median|total`)
hist(ind_1$`total|income|median|total`, xlab = "total median income", ylab = "frequency", main = "histogram")

# Levels of geography are:
# 3 (URBAN FSA)
# 6 (RURAL POSTAL CODE AREAS)
# 7 (OTHER URBAN AREAS)
# 8 (CITY TOTAL)
# 9 (RURAL COMMUNITIES)
# 10 (OTHER PROVINCIAL TOTAL)
# 11 (PROVINCE/TERRITORY TOTAL)
# 12 (CANADA)
# 21 (CENSUS DIVISION)
# 31 (FEDERAL ELECTORAL DISTRICT)
# 51 (ECONOMIC REGION)
# 41 (CENSUS METROPOLITAN AREA)
# 42 (CENSUS AGGLOMERATION)
# 61 (CENSUS TRACT)
# More Information: https://www12.statcan.gc.ca/census-recensement/2016/ref/98-304/chap12-eng.cfm

#-------------------------------------------------------------------------------
# Set up a two-by-two plot array for total median income
par(mfrow = c(2, 2))

# Plot the raw total median income
plot(ind_1$`total|income|median|total`, col = "blue", xlab = "index", ylab = "total median income", main = "Scatterplot")

# Plot the normalized histogram of the total median income
truehist(ind_1$`total|income|median|total`, xlab = "index", ylab = "total median income", main = "Histogram")

# Plot the density of the total median income
plot(density(ind_1$`total|income|median|total`), xlab = "index", ylab = "total median income", main = "Density plot")

# Construct the normal (quantile-quantile) QQ-plot of the total median income
qqnorm(ind_1$`total|income|median|total`, xlab = "index", ylab = "total median income", main = "QQ-plot")

#-------------------------------------------------------------------------------
# Set up a two-by-two plot array for age of taxfiler distribution
par(mfrow = c(2, 2))
plot(ind_1$`all|persons|average|age`, col = "blue", xlab = "index", ylab = "Taxfiler age distribution", main = "Scatterplot")
truehist(ind_1$`all|persons|average|age`, xlab = "index", ylab = "Taxfiler age distribution", main = "Histogram")
plot(density(ind_1$`all|persons|average|age`), xlab = "index", ylab = "Taxfiler age distribution", main = "Density plot")
qqnorm(ind_1$`all|persons|average|age`, xlab = "index", ylab = "Taxfiler age distribution", main = "QQ-plot")

#-------------------------------------------------------------------------------
# Load the tabplot package: library(tabplot)
# tidy table before tableplot
tableplot(ind_1)

#-------------------------------------------------------------------------------
## Density exploration of data
# density plots for all geographical levels based on total median income
ggplot(ind_1) + geom_density(aes(x = `total|income|median|total`, color = year)) +
  facet_wrap(~ `level|of|geo|`, scales = "free") +
  labs(title = "Density plots for geo levels", xlab = "Total median income")
#-------------------------------------------------------------------------------
## Boxplot exploration of data
# all geo levels boxplot

ggplot(ind_1, aes(x= factor(`level|of|geo|`), y= `taxfilers|#|`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("URBAN FSA", "RURAL PC", "OTHER URBAN", "CITY TTL", "RURAL COMM", "OTHER PROV TTL", "PRO TER TTL", "CANADA", "CD", "FED ELE D", "CMA", "CA", "ECON REGION", "CT")) +
  geom_boxplot( fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# provincial geo levels boxplot
ggplot(ind_1, aes(x= factor(`level|of|geo|`), y= `total|income|median|total`, group = `level|of|geo|`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("URBAN FSA", "RURAL PC", "OTHER URBAN", "CITY TTL", "RURAL COMM", "OTHER PROV TTL", "PRO TER TTL", "CANADA", "CD", "FED ELE D", "CMA", "CA", "ECON REGION", "CT")) +
  geom_boxplot(fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Total Median Income", subtitle = "based on geo level", y = "Median Income of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# all geo level boxplot in years
ggplot(ind_1, aes(x= factor(`level|of|geo|`), y= `taxfilers|#|`, colour = factor(`year`))) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "11", "12", "21", "31", "41", "42", "51", "61"),
                   labels = c("URBAN FSA", "RURAL PC", "OTHER URBAN", "CITY TTL", "RURAL COMM", "OTHER PROV TTL", "PRO TER TTL", "CANADA", "CD", "FED ELE D", "CMA", "CA", "ECON REGION", "CT")) +
  geom_boxplot() +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))



# boxplot removing Canada and provincial level of geo's
ind_1_plot <- ind_1 %>%
  select(`taxfilers|#|`,`level|of|geo|`) %>%
  filter(ind_1$`level|of|geo|` != 11 & ind_1$`level|of|geo|` != 12)

ggplot(ind_1_plot, aes(x= factor(`level|of|geo|`), y= `taxfilers|#|`, group = `level|of|geo|`)) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "21", "31", "41", "42", "51", "61"),
                   labels = c("URBAN FSA", "RURAL PC", "OTHER URBAN", "CITY TTL", "RURAL COMM", "OTHER PROV TTL", "CD", "FED ELE D", "CMA", "CA", "ECON REGION", "CT")) +
  geom_boxplot(fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))


# boxplot removing Canada and provincial level of geo's based on years
ind_1_plot <- ind_1 %>%
  select(`taxfilers|#|`,`level|of|geo|`, `year`) %>%
  filter(ind_1$`level|of|geo|` != 11 & ind_1$`level|of|geo|` != 12)

ggplot(ind_1_plot, aes(x= factor(`level|of|geo|`), y= `taxfilers|#|`, colour = factor(`year`))) +
  scale_x_discrete("Levels of Geo", #breaks= c("3", "6", "7", "8", "9", "10", "21", "31", "41", "42", "51", "61"),
                   labels = c("URBAN FSA", "RURAL PC", "OTHER URBAN", "CITY TTL", "RURAL COMM", "OTHER PROV TTL", "CD", "FED ELE D", "CMA", "CA", "ECON REGION", "CT")) +
  geom_boxplot() + #fill = "white", colour = "#3366FF") +
  scale_y_continuous(breaks = scales::pretty_breaks(n = 10)) +
  labs(title = "Taxfilers Distribution", subtitle = "based on geo level", y = "No. of Taxfilers") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))
