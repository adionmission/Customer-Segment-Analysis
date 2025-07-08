library(tidyverse)
library(janitor)
library(concaveman)


# setting path and reading data-------------------------------------------------

print(getwd())
setwd("D:/Projects/Customer-Segment-Analysis")
print(getwd())

df = read.csv("Dataset/Mall_Customers.csv")

View(df)
#-------------------------------------------------------------------------------


# data pipeline-----------------------------------------------------------------

data_clean = df %>%
  drop_na() %>%
  janitor::clean_names()

View(data_clean)
#-------------------------------------------------------------------------------


# remaining columns-------------------------------------------------------------

colnames(data_clean) = c("id",
                         "gender",
                         "age",
                         "annual_income",
                         "spending_score")

View(data_clean)
#-------------------------------------------------------------------------------


# getting optimal value of K----------------------------------------------------

data = select(data_clean, -gender, -id)

# calculate the weighted sum squares (wss) for a single cluster

wss = (nrow(data) - 1) * sum(apply(data, 2, var))

# now calculate the weighted sum squares for all cluster numbers from 2 to 15

for (i in 2:15) {
  wss[i] = sum(
    kmeans(
      data,
      nstart = 10,
      centers = i
    )$withinss
  )
}

# turn wss data into a data frame for plotting

wss_data = data.frame(centers = 1:15, wss)

# make plot

wss_data %>%
  ggplot(aes(x = centers, y = wss)) + 
  geom_point(aes(color = wss, size = wss)) + 
  geom_line(color = "red") +
  labs(x = "Number of Clusters",
       y = "Within groups sum of squares",
       title = "Weighted Sum Squares (WSS)") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))
#-------------------------------------------------------------------------------


# k-means clustering------------------------------------------------------------

data_clean %>% 
  select(-gender, -id) %>% 
  kmeans(centers = 3, nstart = 10) ->
  KM

data_clustered = data.frame(data_clean, cluster = factor(KM$cluster))
#-------------------------------------------------------------------------------


# getting centroids-------------------------------------------------------------

centroids = KM$centers
print(centroids)

centroids = data.frame(centroids, cluster = factor(1:3))
#-------------------------------------------------------------------------------


# plotting the graph------------------------------------------------------------

data_clustered %>%
  ggplot(aes(x = annual_income, y = spending_score, color = cluster)) + 
  geom_point(aes(shape = gender), size = 3) +
  geom_point(
    data = centroids,
    aes(fill = cluster),
    shape = 21,
    color = "black",
    size =5,
    stroke = 1) + 
  geom_mark_hull(aes(fill = cluster), 
                 expand = 0, 
                 radius = 0, 
                 concavity = 5) + 
  labs(x = "Annual Income",
       y = "Spending Score",
       title = "Customer Segment Behavior") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))
#-------------------------------------------------------------------------------
