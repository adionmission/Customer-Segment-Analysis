library(tidyverse)
library(janitor)
library(caTools)
library(class)
library(caret)
library(ggpubr)


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
  subset(select=-c(CustomerID)) %>%
  janitor::clean_names()

View(data_clean)
#-------------------------------------------------------------------------------


# renaming col names------------------------------------------------------------ 

colnames(data_clean) = c("gender",
                         "age",
                         "annual_income",
                         "spending_score")

View(data_clean)
#-------------------------------------------------------------------------------


# data type change--------------------------------------------------------------
sapply(data_clean, class)

#data_clean$gender = as.numeric(data_clean$gender)

data_clean$age = as.numeric(data_clean$age)

data_clean$annual_income = as.numeric(data_clean$annual_income)

data_clean$spending_score = as.numeric(data_clean$spending_score)

sapply(data_clean, class)
#-------------------------------------------------------------------------------


# splitting the whole dataset---------------------------------------------------

split = sample.split(data_clean, SplitRatio = 0.8)

train = subset(data_clean, split == TRUE)

test = subset(data_clean, split == FALSE)
#-------------------------------------------------------------------------------


# getting the parameters except the class---------------------------------------

train_scale = scale(train[, 2:4])

test_scale = scale(test[, 2:4])
#-------------------------------------------------------------------------------


# getting the optimal value of K------------------------------------------------

i = 1
k.optm = 1
for(i in 1:15) # range till the square root of total rows
{
  knn.mod = knn(train = train_scale, 
                test = test_scale,
                cl = train$gender,
                k = i)
  k.optm[i] = 100 * sum(test$gender == knn.mod)/NROW(test$gender)
  k = i
  cat(k, "=", k.optm[i], "\n")
}

optm_k_score = data.frame(kvalue = c(1:15), score = c(k.optm))
print(optm_k_score)

optm_k_score %>%
  ggplot(aes(x = kvalue, y = score)) + 
  labs(x = "K Values", y = "Accuracy") + 
  geom_point(aes(color=score, size=score)) + 
  geom_line(color="red") + 
  geom_text(aes(label = score), hjust = 1, vjust = 2) + 
  labs(x = "K Values",
       y = "Score",
       title = "Optimal value of K") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))
#-------------------------------------------------------------------------------


# Fitting KNN Model------------------------------------------------------------- 

classifier_knn = knn(train = train_scale,
                     test = test_scale,
                     cl = train$gender,
                     k = 4)

print(classifier_knn)
#-------------------------------------------------------------------------------


# Confusion Matrix--------------------------------------------------------------

confmatrix = table(classifier_knn, test$gender)

fourfoldplot(confmatrix, 
             color = c("cyan", "pink"),
             conf.level = 0, 
             margin = 1, 
             main = "Confusion Matrix")

confusionMatrix(confmatrix)
#-------------------------------------------------------------------------------


# plotting graph of test data---------------------------------------------------

prediction_plot = data.frame(test$age,
                             test$annual_income,
                             test$spending_score,
                             predicted = classifier_knn)

colnames(prediction_plot) = c("age", 
                              "annual_income", 
                              "spending_score",
                              "prediction")

p1 = prediction_plot %>%
  ggplot(aes(age, 
             annual_income, 
             color = prediction,
             fill = prediction)) + 
  geom_point(size = 3) + 
  labs(x = "Age",
       y = "Annual Income",
       title = "Age vs Annual Icome by gender") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 40),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15))

p2 = prediction_plot %>%
  ggplot(aes(age, 
             spending_score, 
             color = prediction,
             fill = prediction)) + 
  geom_point(size = 3) + 
  labs(x = "Age",
       y = "Spending Score",
       title = "Age vs Spending Score by gender") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 40),
        axis.title.x = element_text(size = 22),
        axis.title.y = element_text(size = 22),
        axis.text.x = element_text(size = 15),
        axis.text.y = element_text(size = 15))

ggarrange(p1, p2, ncol = 2, labels = "AUTO")

prediction_plot %>%
  ggplot(aes(spending_score, 
             annual_income, 
             color = prediction,
             fill = prediction)) + 
  geom_point(size = 5) + 
  labs(x = "Spending Score",
       y = "Annual Income",
       title = "Spending Score vs Annual Income by Gender") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15))

prediction_plot %>%
  ggplot(aes(spending_score, 
             annual_income, 
             color = prediction,
             fill = prediction)) + 
  geom_bar(stat = "identity") + 
  facet_grid(~prediction) + 
  labs(x = "Spending Score",
       y = "Annual Income",
       title = "Spending Score vs Annual Income by Gender") + 
  theme_bw() + 
  theme(plot.title = element_text(size = 60),
        axis.title.x = element_text(size = 30),
        axis.title.y = element_text(size = 30),
        axis.text.x = element_text(size = 18),
        axis.text.y = element_text(size = 18),
        legend.title = element_text(size = 20),
        legend.text = element_text(size = 15),
        strip.text = element_text(size = 23))
#-------------------------------------------------------------------------------
