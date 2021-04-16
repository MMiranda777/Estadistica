###################################################
########### Serie de tiempo bayesiana #############
###################################################

#######Librerias ##############
library(tseries)
library(coda)
library(forecast)
library(lmtest)
library(astsa)
library(rjags)

#Tener versión R>=4.0.0
#install.packages("bayesforecast")
library(bayesforecast)

####### Cargamos la Base #############
load("~/FAC/0_9no/Bayesiana/Proyecto/Base_london.RData")
casas=housing_in_london_monthly_variables #base completa

setwd("C:/Users/Rodri/Downloads/archive (1)")

casas <- read.csv("housing_in_london_monthly_variables.csv")

###westminster
westminster <- subset(casas, area == "westminster") #filtramos la base a "Westminister"
plot(westminster$average_price, type = "l")

##Serie de tiempo
#hacemos la columna de precios una serie de tiempo
ts_wm <- ts(data = westminster$average_price, frequency = 12, start = c(1995,1))
#Para las series de tiempo necesitamos que tengan varianza cte
# heterocedasticidad: la varianza de los errores no es constante 
##=====Test de Breusch-Pagan
# H0=los datos son homoscedásticos. (los errores tienen varianza constante)
# H1=los datos son heterocedásticos

t1 = seq(1995+1/12, 2020+1/12, by = 1 / 12)#Secuencia auxiliar para aplicar el test de Breusch-Pagan
bptest(ts_wm~t1) ## pval<0.05 por lo que los datos no son homoscedásticos

####### Pruebas de estacionariedad ###############

#transformación de BoxCox para volver homoscedástica(de varianza constante) la serie de tiempo
#El comando BoxCox aplica una transformaci?n a los datos acorde a un parametro lambda que nosotros le
#damos, para encontrar un valor de lambda que gen?re una transformaci?n adecuada a los datos, usamos el 
#comando BoxCox.lambda: Entonces 1)Encontramos lambda con BoxCox.lambda y 2) transformamos los datos
#con BoxCox usando el par?metro lambda

bc_wm_lam<-BoxCox.lambda(ts_wm, method = "guerrero")#Method Guerrero es simplemente la forma en que va a 
#proceder a calcular lambda, podemos usar tambi?n el metodo loglike cambiando"guerrero" por "loglik" esto
#cambiar? el valor de lambda y consecuentemente la transformaci?n.Nos funcion? bien "guerrero"
bc_wm<-BoxCox(ts_wm,lambda= bc_wm_lam)#Estos son los datos transformados, vemos que son homoscedasticos:


bptest(bc_wm~t1) ## pval=0.2557  =>  aceptamos H0

####Para hacer armas o arima es necesaria la estacionariedad en la serie
    #=====Test de Dickey-Fuller
    #H0=no estacionaria
    #H1=estacionaria
adf.test(bc_wm) #  pval=0.98  =>  NO PASA (aceptamos H0)
plot(decompose(bc_wm))


#Aplicamos una diferenciación para ver si así pasan la prueba
diff_wm<-diff(bc_wm)
adf.test(diff_wm) # pval=0.01  =>  Ya pasa♡ (rechazamos H0)

#Aplicamos el test de Kwiatkowski-Phillips-Schmidt-Shin (KPSS) 
    #KPSS para estacionariedad (se aplican ambos test para mayor certeza ya 
    #que puede pasar un test y el otro no)
    #H0=Stationarity
    #H1=Unit Root
kpss.test(diff_wm) #pvalue=0.09  =>  aceptamos H0


###Gráfica####
#Usamos los ACF y PACF muestrales para darnos una idea del numero de 
#retrasos que podriamos proponer para el ajuste con un ARIMA o SARIMA
#Te?ricamente un AR(p) Tendra los primeros p lags del PACF por fuera de las bandas
#de confianza y despu?s los lags tenderan r?pidamente a cero, an?logamente un MA(q)
#Tendra los primeros p lags del PACF por fuera de las bandas de confianza y despu?s
#los lags tenderan r?pidamente a cero, de ahi se concluye que un ARMA(p,q) cumplir? 
#ambas condiciones. SI en ACF o en PACF vemos comportamientos ciclicos, podr?a indicar
#estacionariedad y por tanto que necesitamos un SARIMA.

tsdisplay(diff_wm, main = "Diferenciación de la serie Westminister")

modelo1<-auto.arima(diff_wm)
modelo1
#de aquí es importante rescatar el BIC y AIC

# Series: diff_wm 
# ARIMA(2,0,3) with non-zero mean 
# 
# Coefficients:
#           ar1     ar2     ma1     ma2      ma3    mean
#       -0.0276  0.1388  0.3912  0.3060  -0.6314  0.0090
# s.e.   0.1448  0.0962  0.1346  0.1165   0.1076  0.0016
# 
# sigma^2 estimated as 0.0005224:  log likelihood=708.03
# AIC=-1402.07   AICc=-1401.68   BIC=-1376.14


###Gráfica de la predicción#####
#el segundo parámetro hace como un zoom
#el 30 es que solo plotee el último 30% de los datos
plot(forecast(modelo1,5))
plot(forecast(modelo1,5),50)

confint(modelo1)

#Diagnostic Plots for Time-Series Fits
tsdiag(modelo1)
#poner que los residuales distribuyen normal
#que los ACF...
#Y que la prueba LjungBox Test (ruido blanco)
#H0=ruido blanco
#H1=no hay RB

#como todos quedan por arriba de 0.05 aceptamos H0


######### JAGS  #############

#Una vez que estimamos una serie de tiempo "Clasica"
#Toca hacer la estimaci?n de un modelo de series de tiempo con enfoque bayesiano
#Para esto necesitamos definir los datos con los que vamos a trabajar
#los cuales son los datos de la serie a tratar y el tamaño de muestra de la misma
n=length(diff_wm)
data <- list(	y = as.integer(diff_wm),n = n)

#Una vez teniendo estos datos hagamos
#la estimaci?n del mismo modelo que la estimacion pasada
#para poder hacer una comparacion
#### ARIMA(2,0,3) ##################
#cargamos los datos

data2=data

set.seed(7)

#Definamos los valores iniciales de los parametros, como es un modelo ARIMA(2,0,3)
#tenemos que definir dos parametros para la parte autoregresiva y 3 para los 
#Promedios moviles, aparte definimos tau que sera la prediccion, o sea la varianza sobre 1
#Y tambien una variable de prediccion para la parte de los promedios moviles que se 
#toma como variables latentes 
inits2 <- function() {
  list(alpha=rnorm(1),
       rho1=rnorm(1),
       rho2=rnorm(1), 
       theta1=rnorm(1),
       theta2=rnorm(1),
       theta3=rnorm(1),
       tau=rgamma(1,1,1),
       #tau_z=rgamma(1,1,1))
       tau_z=runif(1,0,0.001))
}
params2 <- c("alpha", "rho1","rho2","theta1","theta2","theta3", "tau")

#Ahora definamos el modelo a tratar, para esto tenemos que definir la ecuacion a trabajar
#La cual nos da que tenemos que hacer dos variables autoregresivas y 3 variables latentes
#para los promedios moviles una vez definida esta operacion podemos definir a una variable 
#Auxiliar que sera una "Z" la cual es las que estimaran los promedios moviles

modelo2="model  {
  for (i in 4:n)  
  {   
    y[i]~dnorm(f[i],1/sigma2)
    f[i] <- alpha + rho1*y[i-1]+ rho2*y[i-2] +theta1*Z[i-1] + theta2*Z[i-2] +theta3*Z[i-3]
  }
  
  for(i in 1:n){
Z[i] ~ dnorm(0,1/sigma2z)
}
  rho1~dnorm(0,1)
  rho2~dnorm(0,1)
  theta1~dnorm(0,0.01)
  theta2~dnorm(0,0.01)
  theta3~dnorm(0,0.01)
  tau_z~dunif(0,0.01)
  tau~dgamma(0.001,0.001)
  sigma2<-1/tau
  sigma2z<-1/tau_z
  alpha~dnorm(0,1)
}"



#Una vez definido el modelo haremos la estimacion con 3 cadenas para tener una aproximacion
#mas acertada 

fit2 <- jags.model(textConnection(modelo2), data2, inits=inits2,
                   n.chains=3)
update(fit2,4000)
sample.arma112 <- coda.samples(fit2, params2, n.iter=10000, thin=1, n.burnin = 5000)

####Gráfica######

#para poder interpretar los resultados graficamos la muestra, lo que se busca es 
#Tener todas las cadenas iteradas convergan, si convergen podemos decir que es un 
#buen modelo ya que los parametros si son significantes 
plot(sample.arma112)
summary(sample.arma112)
#Como observamos las trazas convergen para todos los parametros por lo que son significativos 
#Por lo que podemos seguir analizando el modelo propuesto

#Para este paso haremos la prueba de Gelman para poder asegurar la convergencia de los parametros
#esto se ve cuando en la grafica asociada a cada parametro la grafica tiende a 1 

####Gráfica#####
gelman.plot(sample.arma112)

#gelman se tiene que ir a 1
gelman.diag(sample.arma112,confidence = .95,transform = T ,autoburnin = T,multivariate = T)

#Todos los prametros tienden a 1, por lo que aseguramos que son significativos 


#######Gráficas############

gelman.plot(sample.arma112[, "alpha"], main = "alpha")
gelman.plot(sample.arma112[, "rho1"], main = "rho1")
gelman.plot(sample.arma112[, "rho2"], main = "rho2")
gelman.plot(sample.arma112[, "theta1"], main = "theta1")
gelman.plot(sample.arma112[, "theta2"], main = "theta2")
gelman.plot(sample.arma112[, "theta3"], main = "theta3")


########## BayesForecast #################

#calcular residuales para obtener la predicción
#comparar con el clásico, de varios modelos bayesianos
#quedarnos con los mejores (menores) numeros en los criterios de bondad de ajuste

#Para esto se utilizaran las paqueterias "BayesForecast" y "astsa"

#Como se hace en el metodo clasico, se propondra el modelo antes estimado pero con enfoque bayesiano

#Pero para poder estimar los valores de los criterios de bondad de ajuste una vez estimado el modelo con el comando "Sarima"
#Lo convertiremos en un objeto varstan para poder calcular los valores antes mencionados



##Modelo ARMA(2,0,3)
modelobayes<-Sarima(diff_wm,order=c(2,0,3))
fit1 = varstan(modelobayes,chains = 3)

check_residuals(fit1)
res <- residuals(fit1)

t2 <- seq(1, length(res))
bptest(res~ t2)
Box.test(res, 20)


aic1 <- aic(fit1)
summary(aic1)
#-1397.563

aicc<-AICc(fit1)
summary(aicc)

#-1397.179

bic1<-bic(fit1)
summary(bic1)
#-1331.71




#### Gráfica ####
#el segundo parámetro hace como un zoom
par(mfrow = c(2,1))
plot(forecast(modelo1,5),50, main = "Enfoque Clasico")
plot(forecast(fit1,5),50, main = "Enfoque bayesiano")

#se hizo una prediccion de 5 valores futuros y se puede observar que se comporta bien
#el detalle es ver que los criterios de ajuste son mas grandes que los del modelo clasico y esto puede
#Afectar a la prediccion por haremos lo siguiente


##Observemos la grafica del modelo para ver mas a fondo como se comportan los datos estimados 

plot(fit1)

##Vemos que tenemos problemas con la varianza ya que esta sobre estimada y eso explica que no hay pasado el bptest


##Probemos otros modelos para ver si logramos encontrar una mejor estimacion 



##No es necesario correr todos los modelos##

##ARIMA(1, 0, 2)

modelobayes<-Sarima(diff_wm,order=c(1,0,2))
fit2 = varstan(modelobayes,chains = 3)

check_residuals(fit2)
res2 <- residuals(fit2)

t2 <- seq(1, length(res2))
bptest(res2~ t2)
Box.test(res2, 2)

plot(fit2)
plot(forecast(fit2,5),50)

##ARIMA(3, 0, 4) p-value = 0.0001914, No correlaci?n

modelobayes<-Sarima(diff_wm,order=c(3,0,4))
fit3 = varstan(modelobayes,chains = 3)

check_residuals(fit3)
res3 <- residuals(fit3)

t3 <- seq(1, length(res3))
bptest(res3~ t3)
Box.test(res3, 20)
acf(res3)

plot(fit3)
plot(forecast(fit3,5),50)


##ARIMA(3, 0, 2)  p-value = 0.0002195, No hay correlaci?n

modelobayes<-Sarima(diff_wm,order=c(3,0,2))
fit4 = varstan(modelobayes,chains = 3)

check_residuals(fit4)
res4 <- residuals(fit4)

t4 <- seq(1, length(res4))
bptest(res4~ t4)
Box.test(res4, 20)

plot(fit4)
plot(forecast(fit4,5),50)


##ARIMA(3, 0, 3) p-value = 0.000342, No correlaci?n

modelobayes<-Sarima(diff_wm,order=c(3,0,3))
fit5 = varstan(modelobayes,chains = 3)

check_residuals(fit5)
res5 <- residuals(fit5)

t5 <- seq(1, length(res5))
bptest(res5~ t5)
Box.test(res5, 20)

plot(fit5)

plot(forecast(fit5,5),50)
##par(mfrow = c(2,1))

##ARIMA(3, 0, 1) Correlacionado, p-value = 0.004168

modelobayes<-Sarima(diff_wm,order=c(3,0,1))
fit9 = varstan(modelobayes,chains = 3)

check_residuals(fit9)
res9 <- residuals(fit9)

t9 <- seq(1, length(res9))
bptest(res9~ t9)
Box.test(res9, 5)

plot(fit9)
plot(forecast(fit9,5),50)

##ARIMA(4, 0, 2) p-value = 0.0004988, No correlaci?n

modelobayes<-Sarima(diff_wm,order=c(4,0,2))
fit10 = varstan(modelobayes,chains = 3)

check_residuals(fit10)
res10 <- residuals(fit10)

t10 <- seq(1, length(res10))
bptest(res10~ t10)
Box.test(res10, 20)

plot(fit10)
plot(forecast(fit10,5),50)

##ARIMA(2, 0, 1) p-value = 0.0004988, No correlaci?n

modelobayes<-Sarima(diff_wm,order=c(2,0,1))
fit21 = varstan(modelobayes,chains = 3)

check_residuals(fit21)
res21 <- residuals(fit21)

t21 <- seq(1, length(res21))
bptest(res21~ t21)
Box.test(res21, 20)

plot(fit21)
plot(forecast(fit21,5),50)

  ##Pruebas con datos sin diferenciar

##Arima(2,1,3)

modelobayes<-Sarima(bc_wm,order=c(2,1,3))
fit6 = varstan(modelobayes,chains = 3)

check_residuals(fit6)
res6 <- residuals(fit6)

t6 <- seq(1, length(res6))
bptest(res6~ t6)
Box.test(res6, 20)

plot(fit6)

##Arima(3,1,3)

modelobayes<-Sarima(bc_wm,order=c(3,1,3))
fit7 = varstan(modelobayes,chains = 3)

check_residuals(fit7)
res7 <- residuals(fit7)

t7 <- seq(1, length(res7))
bptest(res7~ t7)
Box.test(res7, 20)

plot(fit7)

##Arima(2,1,1)

modelobayes<-Sarima(bc_wm,order=c(2,1,1))
fit8 = varstan(modelobayes,chains = 3)


check_residuals(fit8)
res8 <- residuals(fit8)

t8 <- seq(1, length(res8))
bptest(res8~ t8)
Box.test(res8, 3)

plot(fit8)





##Una vez que se hicieron demasiadas pruebas se decidio hacer el auto.sarima para ver que modelo nos recomendaba 

Auto<- auto.sarima(diff_wm)
summary(Auto)
Auto

Auto2<- auto.sarima(bc_wm)
summary(Auto2)
Auto2

check_residuals(Auto2)
res8 <- residuals(Auto2)

##La recomendaci?n tanto para los diferenciados como para los datos normales, fue un ARIMA(1, 0, 2)


##Despues de varias pruebas de modelos se llego a la conclusion de que la mayoria de modelos no 
##No pasan la prueba de varianza (bptest) por lo que se tomaran para hacer la comparacion de estos modelos 
##Aquellos que tengan el p-value mayor y no tengan correlaci?n en los parametros 
par(mfrow = c(3,2))
#ARIMA(2,0,3)
plot(forecast(fit1,5),50, main = "ARIMA (2,0,3)")

#ARIMA(3,0,3)
plot(forecast(fit5,5),50,main = "ARIMA (3,0,3)")
#ARIMA(4,0,2)
plot(forecast(fit10,5),50,main = "ARIMA (4,0,2)")
#ARIMA(1,0,2)
plot(forecast(fit2,5),50,main = "ARIMA (1,0,2)")
#ARIMA(2,0,1)
plot(forecast(fit21,5),50,main = "ARIMA (2,0,1)")







