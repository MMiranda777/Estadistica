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
Se utilizaron las siguientes paqueterías: `tseries`,`coda`,`forecast`,`lmtest`,`astsa`,`rjags` y `bayesforecast`.
A continuación se presenta un resumen de las funciónes más relevantes que se ocuparon y sus objetivos:

|      Función     |       Descripción                                                    |
|:----------------:|:--------------------------------------------------------------------:|
|    `bptest()`    |• Para las series de tiempo necesitamos que tengan varianza cte <br> • heterocedasticidad: la varianza de los errores no es constante <br> =====Test de Breusch-Pagan <br> H0=los datos son homoscedásticos. (los errores tienen varianza constante) <br> H1=los datos son heterocedásticos.|
|    `BoxCox()`    |Transformación de BoxCox para volver homoscedástica(de varianza constante) la serie de tiempo.|
|   `adf.test()`   |• Para hacer ARMAS o ARIMA es necesaria la estacionariedad en la serie <br> =====Test de Dickey-Fuller <br> H0=no estacionaria <br> H1=estacionaria.|
|  `auto.arima()`  |Ajusta el mejor modelo ARIMA basado en los valores de AIC,  AICc o BIC.|
|  `jags.model()`  |Se utiliza para crear una representación gráfica de un modelo Bayesiano y un conjunto de datos. La distribución inicial se programa en lenguaje BUGS.|
| `coda.samples()` |Esta es una función contenedora para `jags.samples` que establece un monitor de seguimiento para todos los nodos solicitados, actualiza el modelo y convierte la salida en un solo objeto `mcmc.list`.|
|    `Sarima()`   |Constructor del modelo SARIMA para estimación bayesiana en Stan <sup>1</sup>.|
|   `varstan()`   |Constructor del objeto varstan para estimación bayesiana en Stan.|
|   `forecast()`  |Es una función genérica para pronosticar a partir de series de tiempo o modelos de series de tiempo. La función invoca métodos particulares que dependen de la clase del primer argumento (objeto).|
> **<sup>1</sup>** Stan is a C++ library for Bayesian inference using the No-U-Turn sampler (a variant of Hamiltonian Monte Carlo) or frequentist inference via optimization.

El código completo puede consultarse en el archivo [`Serie de Tiempo_Bay.R`](https://github.com/MMiranda777/Estadistica/blob/main/Bayesiana/Serie%20de%20Tiempo_Bay.r).

## - Resultados:
Al ser una serie de tiempo, son más relevantes los datos más recientes. Para los datos a partir del 2018 tenemos que la media es de 990,359 entonces esperaríamos que nuestras predicciones ronden este valor. El modelo Clásico y Bayesiano se compararán en función de los criterios de bondad de ajuste, y se determina cuál ofrece un mejor modelo.

**Modelo Clásico**

Después de hacer los análisis correspondientes, esta fue la predicción que se obtuvo para el modelo clásico:

**Modelo Bayesiano**

Se trataron de ajustar distintos modelos con la paquetería `bayesforecast`, la mayoría no pasaba la prueba de la varianza constante por lo que se decidió tomar los que tuvieran mayor _p-value_ para esta prueba y que no tuvieran correlación en los parámetros. Se obtuvieron los siguientes modelos: ARIMA(2,0,3), ARIMA(3,0,3), ARIMA(4,0,2), ARIMA(1,0,2) y ARIMA(2,0,1). A continuzación se muestra una comparación de los 5 modelos.



Comparando estos modelos se llegó a la conclusión de que el mejor ajuste era el ARIMA(1,0,2), que de hecho fue el sugerido por el comando `auto.sarima`.

Se concluyó no hubo un unico mejor modelo para el ajuste de la serie de tiempo. Se intento trabajar con
el mismo modelo obtenido en el enfoque clasico para la parte bayesiana pero para estos metodos no resultaba
ser la mejor opcion. Pudimos ver la importancia de tener distintas formas de abordar los modelados y lo
difcil que puede ser llegar a un buen ajuste, sobre todo en la forma bayesiana porque requiere mas trabajo
computacional que tal vez no fue mucho con nuestros datos pero al tener bases con millones de datos se
puede complicar el estar probando distintos modelos.






















:blue_book: [Regresar a Portafolio Estadística](https://github.com/MMiranda777/Estadistica)
