 <a href="https://www.linkedin.com/in/melissamirandap/">
 <img src="https://img.shields.io/badge/Linked-in-blue">

# [Serie de Tiempo Bayesiana   **V.S**   ST Normal](https://github.com/MMiranda777/Estadistica/tree/main/Bayesiana)
<img src="Media/bay1.png" width="50%" style="display: block; margin: auto;" /><img src="Media/bay2.png" width="50%" style="display: block; margin: auto;" />

Este proyecto tiene como objetivo desarrollar una **Serie de Tiempo Bayesiana** y con esto lograr predecir los precios de viviendas en Londres en la región de Westminister. Además de contrastarla con una serie de tiempo normal.

Se utilizó una base de datos que contiene información sobre las viviendas en Londres y la variable de interés es el precio promedio de las viviendas (registrado en libras (GBP)). Los datos son actualizados cada mes desde enero de 1995 hasta enero de 2020 y se consideran 45 regiones de Londres, por lo tanto, cada región cuenta con 301 datos por variable.

> La base puede encontrarse en el siguiente archivo [`montly_housing_london.csv`](https://github.com/MMiranda777/Estadistica/blob/main/Bayesiana/housing_in_london_monthly_variables.csv)

Para efectos de este proyecto, se analizó la serie de tiempo del precio promedio de las viviendas para hacer una predicción. En particular se escogió la región de Westminster con las siguientes características para la variable _average_price_:

|                 |  Mínimo | Mediana |  Media  |   Máximo  |
|:---------------:|:-------:|:-------:|:-------:|:---------:|
| Precio promedio | 131,468 | 502,387 | 543,866 | 1,117,408 |

> _**NOTA**_ : Todas las especificaciones relacionadas al código, las diferencias entre las series de tiempo y los objetivos esperados de cada una vienen explicados a detalle en el documento [`Serie de Tiempo Bayesiana.pdf`](https://github.com/MMiranda777/Estadistica/blob/main/Bayesiana/Serie%20de%20Tiempo%20Bayesiana.pdf)

## - Programación:
A continuación se presenta un resumen de las funciónes más relevantes que se ocuparon y sus objetivos:

|      Función     |                                                                                                                                 Descripción                                                                                                                                 |
|:----------------:|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|    `bptest()`    | • Para las series de tiempo necesitamos que tengan varianza cte <br> • heterocedasticidad: la varianza de los errores no es constante  =====Test de Breusch-Pagan  H0=los datos son homoscedásticos. (los errores tienen varianza constante)  H1=los datos son heterocedásticos |
|    `BoxCox()`    | Transformación de BoxCox para volver homoscedástica(de varianza constante) la serie de tiempo.                                                                                                                                                                              |
|   `adf.test()`   | • Para hacer ARMAS o ARIMA es necesaria la estacionariedad en la serie =====Test de Dickey-Fuller H0=no estacionaria H1=estacionaria                                                                                                                                        |
|  `auto.arima()`  | Ajusta el mejor modelo ARIMA basado en los valores de AIC,  AICc o BIC                                                                                                                                                                                                      |
|  `jags.model()`  | is used to create an object representing a Bayesian graphical model, specified with a BUGS-language description of the prior distribution, and a set of data.                                                                                                               |
| `coda.samples()` | Ajusta el mejor modelo ARIMA basado en los valores de AIC,                                                                                                                                                                                                                  |
|    `Sarima()*`   | Ajusta el mejor modelo ARIMA basado en los valores de AIC,                                                                                                                                                                                                                  |
|   `varstan()*`   | Ajusta el mejor modelo ARIMA basado en los valores de AIC,                                                                                                                                                                                                                  |
|   `forecast()*`  | Ajusta el mejor modelo ARIMA basado en los valores de AIC,                                                                                                                                                                                                                  |


El código completo puede consultarse en el archivo [`Serie de Tiempo_Bay.R`](https://github.com/MMiranda777/Estadistica/blob/main/Bayesiana/Serie%20de%20Tiempo_Bay.r).

## - Resultados:
Al ser una serie de tiempo, son más relevantes los datos más recientes. Para los datos a partir del 2018 tenemos que la media es de 990,359 entonces esperaríamos que nuestras predicciones ronden este valor. El modelo Clásico y Bayesiano se compararán en función de los criterios de bondad de ajuste, y se determina cuál ofrece un mejor modelo.






:blue_book: [Regresar a Portafolio Estadística](https://github.com/MMiranda777/Estadistica)
