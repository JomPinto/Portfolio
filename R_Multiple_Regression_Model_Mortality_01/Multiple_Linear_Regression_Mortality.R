library(tidyverse)
library(conflicted)
library(Stat2Data)
library(car)

# Create the data frame 'mortality'
mortality <- read.table(text = "
Total_Deaths Pop num_Hcenter num_Bhealthstation num_physicians num_dentist num_phNurse num_midwife num_nutrition num_medtech num_BHworker island
52594 13694816 480 32 660 525 1042 1175 105 312 4830 1
8029 1805792 96 749 94 39 673 805 22 75 7071 1
7360 5243726 149 1378 187 117 422 1191 49 128 24542 1
13058 3626877 98 1310 116 66 1108 1083 15 110 11661 1
31546 12099325 282 2021 299 165 544 1458 31 201 16623 1
95984 15937325 0 2576 234 163 633 1285 92 0 18329 1
6071 3138950 16 896 37 14 163 268 9 0 3590 1
5553 6094462 128 1797 118 69 756 813 28 75 9671 1
41136 7877110 137 1992 296 145 1083 1890 19 0 26922 2
25794 7879119 154 1953 253 138 1830 1918 32 0 21855 2
14825 4711363 167 849 182 116 2042 1242 8 0 17461 2
11258 3805545 199 768 113 26 1078 991 17 0 7432 3
21714 5004949 93 1212 40 17 126 353 9 38 3678 3
26009 5237160 70 1100 85 69 960 948 31 111 12031 3
7174 4900137 62 1148 122 56 1279 1273 68 0 8642 3
5676 4234144 220 679 77 2 110 419 6 22 5851 3
7654 2729595 83 813 88 45 1031 772 22 89 13176 3
", header = TRUE)

# Print the data frame 'mortality'
print(mortality);

#Creating another dataframe and separating the variables per island
mortalityrate <- mortality %>%
  mutate(island2 = ifelse(island == 2, 1, 0),
         island3 = ifelse(island == 3, 1, 0))

#Create the mortality rate model
mortalityrate_model <- lm(Total_Deaths ~ Pop + num_Hcenter + num_Bhealthstation + num_physicians +
              num_dentist + num_phNurse + num_midwife + num_nutrition +
              num_medtech + num_BHworker + island2 + island3, data = mortalityrate)

#Create the anova table
mortalityrate_anova <- anova(mortalityrate_model)

print(mortalityrate_anova)

#Forwardselection

#Creating the initial model
initial_forward_model <- lm(Total_Deaths ~ 1, data=mortalityrate)

#Creating the forward model
selected_forward_model <-step(initial_forward_model, 
                              direction = "forward", 
                              scope = formula(~ Pop + num_Hcenter + num_Bhealthstation + num_physicians +
                                                num_dentist + num_phNurse + num_midwife + num_nutrition +
                                                num_medtech + num_BHworker + island2 + island3),
                              slentry = 0.10,
                              alpha = 0.10,
                              slstay = 0.10,
                              cp = TRUE,
                              tol = TRUE,
                              trace = FALSE)

summary(selected_forward_model)
#Summary of the selected_forward_model
summary_forward <- summary(selected_forward_model)

#get p-value
p_value_forward <- summary(selected_forward_model)$coefficients[, "Pr(>|t|)"]

# Get VIF (using the car package)
vif_forward <- vif(selected_forward_model)

## Get Tolerance (1/VIF)
tolerance_forward <- 1/vif_forward


cat("P-values: ", p_value_forward, "\n")
cat("Varaince Inflation",vif_forward, "\n")
cat("Tolerance", tolerance_forward, "\n")

#Backward Selection
#Creating the model
selected_backward_model <-step(mortalityrate_model,
                               direction = "backward",
                               trace = FALSE)

#Summary Selected_backward_model
summary_backward <- summary(selected_backward_model)

summary(selected_backward_model)

# Get p-values
p_values_backward <- summary(selected_backward_model)$coefficients[, "Pr(>|t|)"]

# Get VIF (using the car package)
vif_backward <- vif(selected_backward_model)

# Get Tolerance (1/VIF)
tolerance_backward <- 1/vif_backward

# Print the selected model summary
print("Backward Selection Model:")
cat("P-values: ", p_values_backward, "\n")
cat("VIF: ", vif_backward, "\n")
cat("Tolerance: ", tolerance_backward, "\n")


# Comparing Two Models ----------------------------------------------------

#Get R Squared
adj_rsqd_forward <-summary_forward$adj.r.squared
adj_rsqd_backward <-summary_backward$adj.r.squared


# Get C(p) Forward ----------------------------------------------------------------

# Get the SSE of the selected model
SSE_selected_forward_model <- sum(resid(selected_forward_model)^2)

# Get the MSE of the full model
MSE_full_forward_model <- sum(resid(selected_forward_model)^2) / (length(resid(selected_forward_model)) - length(coefficients(selected_forward_model)))

print(MSE_full_forward_model)

# Get the number of observations
n <- length(resid(selected_forward_model))

# Get the number of predictor variables in the selected model
p_selected_forward_model <- length(coefficients(selected_forward_model)) - 1

print(p_selected_forward_model)

# Calculate the C(p) statistic
Cp_statistic_forward <- (SSE_selected_forward_model / MSE_full_forward_model) - (n - 2 * p_selected_forward_model)

test <- ((SSE_selected_forward_model / MSE_full_forward_model) - (2*(n+1))-p_selected_forward_model)

# Print the C(p) statistic
cat("C(p) statistic Forward: ", Cp_statistic_forward, "\n")

# Get C(p) Backward -------------------------------------------------------

# Get the SSE of the selected model
SSE_selected_backward_model <- sum(resid(selected_backward_model)^2)

print(SSE_selected_backward_model)

# Get the MSE of the full model
MSE_full_backward_model <- sum(resid(selected_backward_model)^2) / (length(resid(selected_backward_model)) - length(coefficients(selected_backward_model)))

print(MSE_full_backward_model)

# Get the number of observations
n <- length(resid(selected_backward_model))

print(n)

# Get the number of predictor variables in the selected model
p_selected_backward_model <- length(coefficients(selected_backward_model)) - 1

print(p_selected_backward_model)

# Calculate the C(p) statistic
Cp_statistic_backward <- (SSE_selected_backward_model / MSE_full_backward_model) - (n - 2 * p_selected_backward_model)
#test <- ((SSE_selected_backward_model / MSE_full_backward_model) - (2*(n+1))-p_selected_backward_model)
# Print the C(p) statistic
cat("C(p) statistic backward: ", Cp_statistic_backward, "\n")






# Get BIC Forward ---------------------------------------------------------

# Get the log-likelihood from the model
log_likelihood_forward <- logLik(selected_forward_model)

# Get the number of parameters in the model
num_parameters_forward <- length(coef(selected_forward_model))

# Get the number of observations in the data
n_bic_forward <- length(resid(selected_forward_model))

print(n_bic_forward)

# Calculate the BIC
bic_forward <- (-2) * log_likelihood_forward + num_parameters_forward * log(n_bic_forward)

# Print the BIC
print("Bayesian Information Criterion (BIC) Foward:")
print(bic_forward)


# Get BIC Backward --------------------------------------------------------

# Get the log-likelihood from the model
log_likelihood_backward <- logLik(selected_backward_model)

# Get the number of parameters in the model
num_parameters_backward <- length(coef(selected_backward_model))

# Get the number of observations in the data
n_bic_backward <- length(resid(selected_backward_model))

print(n_bic_backward)

# Calculate the BIC
bic_backward <- (-2) * log_likelihood_backward + num_parameters_backward * log(n_bic_backward)

# Print the BIC
print("Bayesian Information Criterion (BIC) Foward:")
print(bic_backward)





# GET AIC Forward ---------------------------------------------------------


# Calculate the AIC
aic_forward <- -2 * log_likelihood_forward + 2 * num_parameters_forward

# Print the AIC
print("Akaike Information Criterion (AIC):")
print(aic_forward)


# Get AIC Backward --------------------------------------------------------

# Calculate the AIC
aic_backward <- -2 * log_likelihood_backward + 2 * num_parameters_backward

# Print the AIC
print("Akaike Information Criterion (AIC):")
print(aic_backward)



# Get Press Forward -------------------------------------------------------

# Get the predicted values (fitted values) from the model
predicted_values_forward <- fitted(selected_forward_model)

# Get the observed values (dependent variable) from your data
observed_values_forward <- mortalityrate$Total_Deaths

# Calculate the Prediction Sum of Squares (PRESS)
press_forward <- sum((observed_values_forward - predicted_values_forward)^2)

# Print the PRESS
print("Prediction Sum of Squares (PRESS):")
print(press_forward)



# Get Press Backward ------------------------------------------------------

# Get the predicted values (fitted values) from the model
predicted_values_backward <- fitted(selected_backward_model)

# Get the observed values (dependent variable) from your data
observed_values_backward <- mortalityrate$Total_Deaths

# Calculate the Prediction Sum of Squares (PRESS)
press_backward <- sum((observed_values_backward - predicted_values_backward)^2)

# Print the PRESS
print("Prediction Sum of Squares (PRESS):")
print(press_backward)






# Test for normality ------------------------------------------------------

##Shapiro_Wilk Test ----
residuals_forward <- residuals(selected_forward_model)
# Perform the Shapiro-Wilk test
shapiro_test_result <- shapiro.test(residuals)

# Print the test result
print(shapiro_test_result)

## Load the 'lmtest' package ----
library(lmtest)

# Perform the Durbin-Watson test
dw_test_result <- dwtest(selected_forward_model)

# Print the test result
print("Durbin-Watson Test:")
print(dw_test_result)

## Perform Lavene's test for homoscedasticity
levene_test_result <- leveneTest(residuals(selected_forward_model), mortalityrate$island)

# Print the test result
print("Lavene's Test for Homoscedasticity:")
print(levene_test_result)
