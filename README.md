# COVID-ARIMA-Forecasting

The purpose of this project is to learn ARIMA models and then apply that knowledge to forecast Covid cases and deaths.
Utilizing ARIMA and Forecast Combination I was able to predict the next 30 days of COVID cases and deaths in Colorado.

I utilized time-series data that came from all of the US states since Jan 1st 2020 on the Covid cases. You can augment the data file with the latest information from the website at CDC Covid Tracker by States: https://data.cdc.gov/Case-Surveillance/United-States-COVID-19-Cases-and-Deaths-by-State-o/9mfq-cb36 

My focus was based on the Colorado COVID cases. I was interested to see how their state was doing particularly because this state seemed to be doing much better than the rest of the United States.

Background Knowledge:
* Colorado's testing rate per 100,000 people was 3,324, compared to the U.S. rate of 3,085.
* The rate of COVID-19 deaths per 100,000 people in Colorado was 2.3 — the U.S. death rate is 6.8.
* Around 11 percent of Colorado hospitals were reporting supply shortages, compared to 21 percent of U.S. hospitals at large.
* Around 6 percent of Colorado hospitals were reporting staff shortages, compared to 17 percent of hospitals in the rest of the country.

# Tools:
* Software: R
* Skills: ARIMA, Forecast Combination

**Colorado Cases**
The red line represents the COVID cases collected from Jan 22, 2020 to Feb 10, 2021
The blue line represents the prediction forecast of cases for the next 30 days

![image](https://user-images.githubusercontent.com/74162007/117516795-eccb7a00-af4e-11eb-9eed-6fa1e8494bba.png)

**Colorado Deaths**
The red line represents the COVID deaths collected from Jan 22, 2020 to Feb 10, 2021
The blue line represents the prediction forecast of deaths for the next 30 days

![image](https://user-images.githubusercontent.com/74162007/117516808-040a6780-af4f-11eb-9d6c-8b9fa748230d.png)
