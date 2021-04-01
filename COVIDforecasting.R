
update.packages(ask=FALSE,checkBuilt=TRUE,repos="https://cloud.r-project.org")

install.packages(c("Rcpp", "caret", "forecast", "ggplot2", "quadprog"), dependencies=TRUE,repos="https://cloud.r-project.org")
install.packages("readxl")
library(readxl)
library("forecast")
library("tseries") 		# reqired for adf.test of stationarity

data <- read_excel("Latest_United_States_COVID-19_Cases_and_Deaths_by_State_over_Time.xlsx", "United_States_COVID-19_Cases_an")
CO_data <- subset(data, state == 'CO')
head(CO_data ,5)
dates <- CO_data$submission_date
cases <- CO_data$tot_cases
deaths <- CO_data$tot_death
CO_DATA<- data.frame(dates, cases, deaths)


##### Representing Data as Time Series Object #####

    #Total Cases
yy_cases <- ts(CO_DATA[,2], start = c(2020,1), frequency =365.25) #Start on the Jan 22 2020,Frequency 365.25 account for leap year
plot.ts(yy_cases)



    #Total Deaths
yy_deaths <- ts(CO_DATA[,3], start = c(2020,1), frequency =365.25) #Start on the Jan 22 2020,Frequency 365.25 account for leap year
plot.ts(yy_deaths)



##### General Process for Fitting ARIMA(p,d,q) x (P, D, Q) Models #####

# Typical values of (p,q) are 0, 1, 2. So you will have 3 ps x 3 qs = 9 models

# ARMA models require STATIONARY time series as inputs. Stationary implies mean and variance are approx constant over time

# To assess stationary, use adf.test(). If series is non-stationary, then take first difference. If first-differenced series still not stationary, take higher order difference. Usually d = 2 suffices for most time series. 

# Given p, d, q taking 3 values (0,1,2), you will have a set of 27 models. Apply AICC to select the best one or a set of few good ones. The "good ones" are within +/- 1 point from the Minimum AICC value




## Let's learn the process using sales series

## Step 1. Is the time series stationary? 

# Use Augmented Dickey-Fuller Test to test stationary == > large p-value means nonstationary


# install and load "tseries" package 
adf.test(yy_cases)             # if p-value is large (> 0.10), then nonstationary
adf.test(yy_deaths)             # if p-value is large (> 0.10), then nonstationary

yy_deaths_d1 = diff(yy_deaths, differences = 1)
adf.test(yy_deaths_d1)
yy_deaths_d2 = diff(yy2, differences = 2) #2nd diff makes deaths stationary
adf.test(yy_deaths_d2)

plot.ts(yy_cases)								# looks stationary visually
plot.ts(yy_deaths_d2)           	# looks stationary visually


## Step 2. Decide AR(p) or MA(q) or both ARMA(p,q). Use the stationary series from Step 1. 

# To decide AR(p), plot Pacf. For AR(p) => Pacf becomes zero at some lag p

Pacf(yy_deaths_d2, lag.max = 90)					# Pacf suggests p = 40 lags ==> way too many


# To decide MA, plot Acf. For MA(q) => Acf becomes zero at some lag q ==> way too many

Acf(yy_deaths_d2, lag.max = 90)					# Acf suggests q = 60 lags




## Step 3. Fit ARIMA automatically
m0 = auto.arima(yy_cases)		# fits ARIMA(p,d,q) x (P, D, Q) automatically

summary(m0)						# finds p = 0, d = 2, q = 1, MAPE = 1.21%

n0 = auto.arima(yy_deaths)
summary(n0)         # finds p = 5, d = 2, q = 1, MAPE = 1.96%
# save scores from information criteria
  #cases
aicc0 <- m0$aicc
bic0 <- m0$bic
  #deaths
d_aicc0 <- n0$aicc
d_bic0 <- n0$bic

# prediction
h = 30																# forecast horizon
m0.predict = forecast:::forecast.Arima(m0, h = 30, level = c(95))
plot(m0.predict)													# check forecasts
m0.predict

h = 30																# forecast horizon
n0.predict = forecast:::forecast.Arima(n0, h = 30, level = c(95))
plot(n0.predict)													# check forecasts
n0.predict

## Step 4. Identify "good models"

## Fit ARIMA models +/- 1 in the neighborhood of (p = 0, q = 1) found from auto.arima
## Keep d = 2 fixed and change only if needed

## fit m1 = Arima(1, 2,1)
## fit m2 = Arima(1, 2,2)
## fit m3 = Arima(0, 2,2)
## fit m4 = Arima(1, 2,0)
## fit m4 = Arima(0, 2,0)

## fit n1 = Arima(4, 2,1)
## fit n2 = Arima(5, 2,0)
## fit n3 = Arima(5, 2,2)
## fit n4 = Arima(4, 2,0)
## fit n4 = Arima(4, 2,2)

m1 = Arima(yy_cases, order = c(1,2,1))			
aicc1 <- m1$aicc
bic1 <- m1$bic

m2 = Arima(yy_cases, order = c(1,2,2))			
aicc2 <- m2$aicc
bic2 <- m2$bic

m3 = Arima(yy_cases, order = c(0,2,2))			
bic3 <- m3$bic

m4 = Arima(yy_cases, order = c(1,2,0))		
aicc4 <- m4$aicc
bic4 <- m4$bic

m5 = Arima(yy_cases, order = c(0,2,0))		
aicc5 <- m5$aicc
bic5 <- m5$bic

n1 = Arima(yy_deaths, order = c(4,2,1))			
d_aicc1 <- n1$aicc
d_bic1 <- n1$bic

n2 = Arima(yy_deaths, order = c(5,2,0))			
d_aicc2 <- n2$aicc
d_bic2 <- n2$bic

n3 = Arima(yy_deaths, order = c(5,2,2))	
d_aicc3 <- n2$aicc
d_bic3 <- n3$bic

n4 = Arima(yy_deaths, order = c(4,2,0))		
d_aicc4 <- n4$aicc
d_bic4 <- n4$bic

n5 = Arima(yy_deaths, order = c(4,2,2))		
d_aicc5 <- n5$aicc
d_bic5 <- n5$bic

## compare scores on informatin criteria to find competitive models

c_aicc.out = cbind(aicc0, aicc1, aicc2, aicc3, aicc4, aicc5)
c_aicc.diff = c_aicc.out - min(c_aicc.out)			

c_bic.out = cbind(bic0, bic1, bic2, bic3, bic4, bic5)
c_bic.diff = c_bic.out - min(c_bic.out)			

d_aicc.out = cbind(d_aicc0, d_aicc1, d_aicc2, d_aicc3, d_aicc4, d_aicc5)
d_aicc.diff = d_aicc.out - min(d_aicc.out)			

d_bic.out = cbind(d_bic0, d_bic1, d_bic2, d_bic3, d_bic4, d_bic5)
d_bic.diff = d_bic.out - min(d_bic.out)				

## Now check the plot and summary of m1 & n2

m1.predict = forecast:::forecast.Arima(m1, h = 30, level = c(95))
plot(m1.predict)								# forecast shows that cases likely to reduce 

summary(m1.predict)								# MAPE 1.97%. Not Better than m0

n2.predict = forecast:::forecast.Arima(n2, h = 30, level = c(95))
plot(n2.predict)								# forecast shows that cases likely to reduce 

summary(n2.predict)								# MAPE 1.99%. Not Better than n0

# Step 5.  Consensus Forecast (aka forecasts combination).

ybar0 <- m0.predict$mean						# auto.arima forecast
ybar1 <- m1.predict$mean						# m1 based forecat

ybar0_2 <- n0.predict$mean
ybar1_2 <- n2.predict$mean

ybar.avg = (ybar0 + ybar1)/2					# consensus forecast
ybar.avg2 = (ybar0_2 + ybar1_2)/2					# consensus forecast

# Also need to find prediction intervals for consensus forecasts. First find variances and then average the variances.

  #Cases
low0 <- m0.predict$lower
var0 <- ((ybar0 - low0[1:h])/1.96)^2 			# b/c yhat - (yhat - 1.96 x se) gives 1.96 x se

low1 <- m1.predict$lower
var1 <- ((ybar1 - low1[1:h])/1.96)^2 

var.avg = (var0[1:h] + var1[1:h])/2				# averaged variance

  #Deaths
low0_2 <- n0.predict$lower
var0_2<- ((ybar0_2 - low0_2[1:h])/1.96)^2 			# b/c yhat - (yhat - 1.96 x se) gives 1.96 x se

low1_2 <- n2.predict$lower
var1_2 <- ((ybar1_2 - low1_2[1:h])/1.96)^2 

var.avg2 = (var0_2[1:h] + var1_2[1:h])/2				# averaged variance



# Step 6. Provide Prediction Intervals for Consensus Forecasts
  #Cases
lo68 = ybar.avg - 1 * sqrt(var.avg)				# 1 SD (68% confidence)
hi68 = ybar.avg + 1 * sqrt(var.avg)


lo95 = ybar.avg - 1.96 * sqrt(var.avg)			# 2 SD (68% confidence)
hi95 = ybar.avg + 1.96 * sqrt(var.avg)

final.out = cbind(ybar.avg, lo68, hi68, lo95, hi95)
d1=data.frame(final.out)
write.csv(d1$ybar.avg,"/Users/khristionlambert/Library/Mobile Documents/com~apple~CloudDocs/Grad School/Winter 2021/493_Topics in BAX/Assignment 2/casesprediction.csv", row.names = FALSE)

  #Deaths
lo68_d = ybar.avg2 - 1 * sqrt(var.avg2)				# 1 SD (68% confidence)
hi68_d = ybar.avg2 + 1 * sqrt(var.avg2)


lo95_d = ybar.avg2 - 1.96 * sqrt(var.avg2)			# 2 SD (68% confidence)
hi95_d = ybar.avg2 + 1.96 * sqrt(var.avg2)

final.out_d = cbind(ybar.avg2, lo68_d, hi68_d, lo95_d, hi95_d)
d2=data.frame(final.out_d)

write.csv(d2$ybar.avg2,"/Users/khristionlambert/Library/Mobile Documents/com~apple~CloudDocs/Grad School/Winter 2021/493_Topics in BAX/Assignment 2/deathsprediction.csv", row.names = FALSE)


combined_cases <- cbind(yy_cases, ybar.avg)
ts.plot(combined_cases, gpars= list(col=rainbow(2)), main = "Colorado Cases")

combined_deaths <- cbind(yy_deaths, ybar.avg2)
ts.plot(combined_deaths, gpars= list(col=rainbow(2)), main = "Colorado Deaths")








