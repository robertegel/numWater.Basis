---
output:
  pdf_document:
    number_sections: false # true oder false, ob Überschriften nummeriert werden
    fig_height: 7
    fig_width: 7
papersize: a4
geometry:
- margin=0.5in
header-includes:
 - \usepackage{commath} # für int ... dx (schönes d durch \dif), dx/dt (\od{x}{t})
 - \usepackage{float}
 - \floatplacement{figure}{H}
 - \usepackage{wrapfig}
 - \usepackage{pdfpages}
 - \usepackage{graphicx}
 - \usepackage{subcaption}
 - \usepackage{mathtools}
 - \usepackage{grffile}
---
|                                                                                  |
|---------------------------------------------------------------------------------:|
| \sc{Civil and Building Systems} ![TUlogo](TU_Logo_kurz_RGB_schwarz.png){width=8%}|
| \sc{Multi-Physics Approaches for Modeling Civil Systems}                         |

\begin{flushright}
Markus Schröder\\
Elisa Zscherper\\
Isabelle Fitkau\\
Robert Egel
\end{flushright}

\section*{\centering{Selected System}}

The concerning system is a water supply from rainwater fetched from the school's rooftops for the 2500 pupils and teachers of a primary and secondary school. The project shall be carried out in cooperation with "Engineers without Borders Germany", the parameter analysis is meant to improve its possible outcomes. Situated in a remote region in Nyamasheke in the West Province of Rwanda, the projects goal is to enable a consistent supply of water in the best quality possible. Therefore temperature and bacteria development is monitored as well as the year round availability of water in the built cisterns. Since it is a day school the necessity of water is correlating with the school's course schedule.

![The projected school: Groupe scolaire Saint Dominique Savio de Karambi](./pictures/photo_2019-12-15_15-38-57.jpg)

\section*{\centering{Processes}}

\begin{wrapfigure}{l}{0.5\textwidth}
  \vspace{-20pt}
  \begin{center}
    \includegraphics[width=0.48\textwidth]{./pictures/Dependencies_02.pdf}
  \end{center}
  \caption{Relations and transferred between processes}
  \vspace{-15pt}
\end{wrapfigure}

To monitor the stored water in the tank, the macroscopic inflow/outflow (I/O) model calculates the water level through the instationary flow model approach. Hereby the inflow is given by the collected rain water over the respective timesteps, based on monthly rain data [6] the outflow by the consumption of the system's users. It interacts with the microscopic inflow/outflow model by providing the inflow, which then returns its outflow for the following macroscopic calculation.

In the microscopic inflow/outflow (I/O) model the daily water use is calculated based on the number of bottles filled in the designated break intervals. Depending on the pressure in the water tank given by the water level, the outflow is calculated using Bernoulli's formula. The outflow is directly influencing the bacteria growth and temperature development as well as the overall daily outflow is used in the macroscopic model.

The water temperature firstly depends on the inflow temperature. The inflow which is given by the macro model and its temperature is assumed to be the ambient temperature. Secondly the water in the tank is influenced by the heat transfer through the walls of the water tank. The heat flow depends on the ambient temperature of soil and air given by a temperature curve based on the temperature average over the day [6].

To consider the health implications through the water quality the bacterial contamination is simulated. Therefore two different processes were combined: Firstly, the contamination through inflowing water is assumed to be analogous to a pollution process. Secondly the bacteria is assumed to be growing over time in dependence of the temperature in the tank.

\section*{\centering{High Performance Criteria}}

To evaluate the results of our process model we defined three high performance criteria. Firstly the cumulated number of filled bottles per day has to suffice to consistently provide one bottles of water to every person over the year. This leads, under consideration of the roundabout 2500 people depending on the water system, to a total amount of 2500 bottles per day.

Secondly the provision of healthy water is measured as the concentration of bacteria in the stored water.

Thirdly, the temperature shall be kept in a certain range to assure the water's potability.
Since cold water is more pleasant to drink, the stored water should be held a considerably low temperature. Everything below a temperature of 17 degree Celsius, would be considered enjoyable, although of course this criterion is not considered to have the highest priority since it's mostly about comfort.

| \sc objective                                                   | \sc {key indicator}                    | \sc {Unit (SI)}  | \sc{extent}    |
|:----------------------------------------------------------|:---------------------------------|:----------|:-----------|
| provide enough water for each individual within school time | $0.5 l$ Bottles filled on a school day | 1          | > 2500 |
| provide healthy water                                       | bacteria concentration $c$                   | $num/m^3$    | < $25 \cdot 10^{-4}$       |
| provide a pleasant drinking temperature                     | temperature                      | $^\circ C$ | max. 17°C     |

\section*{\centering{Differential Equations}}

### Input Parameters

| \sc{Shared Parameters} |                                            |          | \sc{Unit (SI)} |
|:-----------------------|:-------------------------------------------|:---------|:---------------|
| $Q_{in}$               | inflow rate                                | variable | $m^3/s$        |
| $Q_{out}$              | outflow rate                               | variable | $m^3/s$        |
| $h_{0}$                | initial water level inside tank            | variable | $m$            |
| $h_{tank}$             | absolute tank height                       | variable | $m$            |
| $r_{tank}$             | tank radius                                | variable | $m$            |
| $c_{0}$                | initial bacteria concentration inside tank | variable | $num/m^3$      |
| $T_{water}$            | water temperature inside tank              | variable | ${^{\circ}C}$  |
| $n_{taps}$             | amount of bottles able to fill             | variable | $num$          |

| \sc{Additional Parameters} |                                               | \sc{Value }                             | \sc{Unit (SI)}          |
|:---------------------------|:----------------------------------------------|:----------------------|:-----------------|
|                            |                                               |                                   |                         |
| **\sc{Macro }**              |                                               |                                   |                         |
| $A_{roof}$                 | roof area used for water collection           | variable                          | $m^2$                   |
|                            |                                               |                                   |                         |
| **\sc{Micro }**              |                                               |                                   |                         |
| $g$                        | acceleration of gravity                       | fixed                             | $m/s^2$                 |
| $n_{taps}$                 | number of water taps                          | variable                          | $1$                     |
| $r_{taps}$                 | radius of water tap outflow                   | fixed $(0.001 m)$                 | $m$                     |
| $V_{Bottle}$               | assumed bottle volume                         | fixed $(0.5 l)$                   | $m^3$                   |
| $z$                        | elevation between taps and bottom of the tank | variable                          | $m$                     |
|                            |                                               |                                   |                         |
| **\sc{Temperature }**        |                                               |                                   |                         |
| $h_{air}$                  | tank height partly above ground level         | variable                          | $m$                     |
| $h_{soil}$                 | tank height partly underground level          | $h_{tank}$-$h_{air}$              | $m$                     |
| $d_{wall}$                 | tank wall thickness                           | variable                          | $m$                     |
| $T_{air}$                  | ambient air temperature                       | fixed                             | ${^{\circ}C}$           |
| $T_{soil}$                 | ambient soil temperature                      | fixed                             | ${^{\circ}C}$           |
| $T_{water_{0}}$            | initial water temperature inside tank         | variable                          | ${^{\circ}C}$           |
| $material$ $properties$    | tank material                                 | variable                          | Polyethylen or Concrete |
| $\rho_{wall}$              | density of wall material                      | concrete: 2400, polyethylen: 980  | $kg/m^3$                |
| $\rho_{water}$             | density of water                              | 1000                              | $kg/m^3$                |
| $\lambda_{wall}$           | thermal conductivity of wall material         | concrete: 2.5, polyethylen: 0.5   | $W/(m*K)$               |
| $\lambda_{water}$          | thermal conductivity of water                 | 0.6                               | $W/(m*K)$               |
| $c_{p_{wall}}$             | specific heat capacity of wall material       | concrete: 1000, polyethylen: 1800 | $J/(kg*K)$              |
| $c_{p_{water}}$            | specific heat capacity of water               | 4190                              | $J/(kg*K)$              |
| $R_{ia}$                   | thermal resistance of wall material           |                                   | $(K*s^3)/(m^2*kg)$      |
| $c_{i}$                    | heat capacity of wall material                |                                   | $J/(kg*K)$              |
|                            |                                               |                                   |                         |
| **\sc{Bacteria Growth}**     |                                               |                                   |                         |
| $V_{0}$                       | initial water volume inside tank                                              | $h_{0} \cdot r_{tank}^2 \cdot{pi}$                               | $m^3$                        |
|   |   |   |   |
| $c_{in}$                       | inflow bacteria concentration                                             | $1.55 \cdot 10^{-4}$                              | $num / m^3$                        |
|   |   |   |   |
| $k$                       | referenced k-value at calculated current water temperature                                              | $k_{20} \cdot Q_{10}^{(T_{water} - T_{20})/10}$                              | $s^{-1}$                        |
|   |   |   |   |
| $Q_{10}$                       | a measure of the rate of change in the inactivation rate as a consequence of increases in temperature by 10${^{\circ}C}$ increments (here: groundwater)                                             | 1.783                               | /                       |
|   |   |   |   |
| $k_{20}$                       | referenced k-value at 20°C (here: groundwater)                                             | $0.50 \cdot 10^{-4}$                              | $s^{-1}$                        |
| $T_{20}$                       | Temperature at 20°C                                              | 20                               | ${^{\circ}C}$                       |

### Macro Inflow/Outflow Model

\begin{wrapfigure}{r}{0.5\textwidth}
  \vspace{-15pt}
  \begin{center}
    \includegraphics[width=0.48\textwidth]{./pictures/allModelsVersion1.7rainplot.png}
  \end{center}
  \vspace{-10pt}
  \caption{Graph of the exemplary daily time schedule} \label{rainplot}
  \vspace{-20pt}
\end{wrapfigure}

To model the availability of water over the year, especially with regard to Rwanda's prolonged dry season between June and August, an inflow/outflow model was used [4], put together from the collected rain as its inflow and the consumption, given as the result of the microscopic inflow/outflow model, as its outflow. In this project, the rainfall is assumed as deterministic, based on the monthly development of the average rainfall in Rwanda [6]. The daily precipitations were approximated by a spline over the monthly averages \ref{rainplot}. To calculate the development of the water availability over a longer time period, the interval has to be chosen significantly larger than in the other partial models. Therefore the interval was chosen as a year, also to consider monthly differences in precipitation, with one day as the respective timestep.

\begin{equation} \label{macroModel}
    \od{V}{t} =
        \left\{\begin{matrix}
            0 & if \; V > 2* h_{tank} \cdot \pi \cdot r_{tank} \wedge dV > 0 \\
            0 & if \; V < 0 \wedge dV < 0 \\
            Q_{in,rain}(t) \cdot A_{roof} - Q_{out} & else
        \end{matrix}\right.
\end{equation}

\newpage

### Micro Inflow/Outflow Model

\begin{equation} \label{microModel}
\od{h}{t} = \dfrac{Q_{in} - Q_{out}}{\pi r_{tank}^2} \hfill
\od{Q_{out}}{t} = g \cdot n_{taps} \cdot \pi r_{taps}^2 \left(2g (h + z) \right)^{-1/2} \od{h}{t}  \hfill
\od{n_{bottles}}{t}= \dfrac{Q_{out}}{V_{bottles}}
\end{equation}

\begin{wrapfigure}{r}{0.5\textwidth}
  \vspace{-10pt}
  \begin{center}
    \includegraphics[width=0.48\textwidth]{./pictures/allModelsVersion1.7scheduleplot.png}
  \end{center}
  \vspace{-10pt}
  \caption{Graph of the exemplary daily time schedule} \label{schedule}
  \vspace{-15pt}
\end{wrapfigure}

Utilizing the Law of \textsc{Bernoulli}, the model for short-term water usage (\ref{microModel}) was derived using the *Building Blocks* and *Asymptotic* modeling techniques. The model is intended to be used with seconds as time scale and meters and derivations of meters as units. The water height $h$ is calculated depending on inflow $Q_{in}$, as well as initial height $h_0$ outflow $Q_{out}$, which are both drawn from the macroscopic inflow/outflow model. The outflow $Q_{out}$ is calculated depending on height and height difference, according to \textsc{Bernoulli}'s law: it grows with higher pressure, which is induced by water height $h$ and elevation difference $z$. The number of bottles $n_{Bottles}$ filled with water drawn from the system is formulated as an integral of the outflow.

Additionally, a time schedule was introduced to approximate the specific behavior of students and pupils, as can be seen in figure \ref{schedule}. Within breaks, a great amount of water is drawn from the system, whereas during class, no one will be filling their bottles. This is solved by using a system of *if/else*-statements, which can be reviewed in the code itself in the `schedule`-function.

The model was developed using the *Asymptotic* modeling technique, since parameters were left out for simplification purposes as can be examined in the appendix. Furthermore, it was assumed that the water flows as quickly as the pressure allows and water taps are kept fully open within breaks.

### Temperature

$$
\od{T_{water}}{t} =
\dfrac{T_{soil} - T_{water}}{R_{ia,bottom} \cdot c_{i,bottom}} +
\dfrac{T_{soil} - T_{water}}{R_{ia,side,soil} \cdot c_{i,side,soil}} $$
\begin{equation}
  + \dfrac{T_{air} - T_{water}}{R_{ia,side,air} \cdot c_{i,side,air}} +
\dfrac{T_{air} - T_{water}}{R_{ia,top} \cdot c_{i,top}} +
\dfrac{Q_{in} T_{in} \dif t + V T_{water} - Q_{out} T_{water} \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} \cdot \od{}{t} - \dfrac{T_{water}}{\dif t} \end{equation}

\begin{wrapfigure}{r}{0.5\textwidth}
  \vspace{-10pt}
  \begin{center}
    \includegraphics[width=0.48\textwidth]{./pictures/allModelsVersion1.7tempplot.png}
  \end{center}
  \vspace{-5pt}
  \caption{Graph of ambient temperature, based on real climate data (average minimum and maximum daily temperature) [6]} \label{tempplot}
  \vspace{-15pt}
\end{wrapfigure}

Most notably, the water temperature in the tank is influenced by the inflow, which is assumed to be tempered to the same level as the ambient air. Additionally, the amount of water in the tank is influenced by the heat transfer through the walls. Here it is determined that the bottom of the tank is always on the ground and the top of the tank is always in the air. This makes it possible to open the tank from the outside, for example for cleaning work. The depth of the tank in the ground is variable. The tank can be complete, partial or not at all in the ground.

Compared to the air temperature, the temperature curve of the ground has a smaller amplitude and is slightly offset in time because the ground takes longer to warm up than the air. Therefore, it is important to consider the areas of heat transport above and below the earth separately.

At this point we implemented a simplification in the model, which assumes that the solar radiation has no direct influence, but only warms the environment.

The influence of the ambient temperature is strongly dependent on the material. There is a choice between concrete and polyethylene, which are the most popular materials for water tanks. When selecting the material, material properties such as density, thermal conductivity coefficient and thermal resistance, as well as the thickness are set as fixed parameters [5].

The interior of the water tank is considered to be homogeneous and a uniform temperature distribution is assumed, differences between air and water are not considered. The outflow temperature, which is the temperature of the drinking water, corresponds to the uniform temperature in the tank.

\newpage

### Bacteria Growth

\begin{wrapfigure}{r}{0.5\textwidth}
  \vspace{-10pt}
  \begin{center}
    \includegraphics[width=0.48\textwidth]{./pictures/regressionanalyses_bacteria.png}
  \end{center}
  \vspace{-5pt}
  \caption{Results from Regression analysis of datasets for different water sources carried out by [1] - page 574, Table1} \label{schedule}
  \vspace{-10pt}
\end{wrapfigure}

Due to bacteria fission, it is assumed that bacteria grow exponential.

\begin{equation} \dfrac {\Delta c}{\Delta t} = k c  \end{equation}

The existing project team in Rwanda carried out a water analyses in August 2019. The analysis focused on the bacteria called Escherichia Coli (E.Coli). The same analysis is providing the value of $c_{in}$. Research made by [2] shows that the growth of E.Coli is strongly depending on the water temperature. To express the dependence of the E.Coli rate on temperature, we utilize the Q10 equation, which is often used to point out the aforementioned effects. [3]

[1] has prepared the Q10 model in such a way that it makes it possible to calculate in terms of finding a solution for k for exponential growth. For this project, the values of groundwater from Figure 5 were chosen. Groundwater is expected to provide the values closest to reality.

\begin{equation} k = k_{20} \cdot Q_{10}^{(T - T_{20})/10} \end{equation}

Additionally the pollution concentration of the water inflow into the tank has been taken into account. The incoming bacteria concentration is considered as well as the inflow water temperature. Utilizing the equation from [4] but changing some details, the equation is the following:

\begin{equation} \dif c = \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} - c \end{equation}

which in the overall examination of the topic results to:

\begin{equation} \dif c = \left[ \left( \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} \right) + \left( k_{20} Q_{10}^{(T_{water} - T_{20})/10} c \right) \dif t  \right] - c \end{equation}

Equation (6) is influenced by all of the other processes. Incoming parameters are $Q_{in}$ (Macro), $Q_{out}$ (Micro) - as well as the volume is partly calculated by $h_{0}$ (Macro) and since k is depending on the water temperature also by $T_{water}$ (Temperature).

Despite the temperature, bacteria grow strongly depending on nutrition. Due to simplicity reason this part is left out during this part of the project phase. It is highly recommended to integrate this type of dependency into the model in further process steps.

### Limits of the Model

In reality, the system is a combination of different cisterns, each fetching water from certain roofs. To simplify the system for our purpose, it is modeled as one cistern with adapted radius and height. The rain data is assumed to be deterministic, following the above mentioned spline [6], not taking into account the arbitrary behavior of rainfall. First flush systems, as planned in the real project plan, or other supplemental systems are not considered due to their minimal influence on the water availability.

The schedule is given for one day without differences between days of the week or even weekends, meaning every day is simulated as a school day. In the break time, the water is flowing without pausing for a bottle exchange. Furthermore, the use profile of the kitchen is not considered in the approach.

The direct effect of solar flux on the cisterns surface is ignored, the only influence considered is the direct heat flow through temperature differences.

Bacteria accumulation on the material is discarded, focusing on the concentration of bacteria in the water itself. Therefore, following the implementation, the tank is bacteria free, once the tank is emptied, contrary to the remaining contamination in reality.

\section*{\centering{Graphical representation of results}}

\begin{figure}
    \centering
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.h.macro.png}
        \caption{Long-term water height drawn from the I/O macroscopic model} \label{heightoveryear}
    \end{subfigure}
    ~ %add desired spacing between images, e. g. ~, \quad, \qquad, \hfill etc.
      %(or a blank line to force the subfigure onto a new line)
      \begin{subfigure}[b]{0.49\textwidth}
          \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.h.Q_out.png}
          \caption{Outflow drawn from the I/O microscopic model plotted against water height} \label{heightconsumption}
      \end{subfigure}
    ~ %add desired spacing between images, e. g. ~, \quad, \qquad, \hfill etc.
    %(or a blank line to force the subfigure onto a new line)
    ~
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.n_Bottles.png}
        \caption{Number of Bottles drawn from the system}
    \end{subfigure}
    ~
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.T_Water.png}
        \caption{Water temperature} \label{watertemperature}
    \end{subfigure}
    ~
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.c.png}
        \caption{Bacteria concentration}
    \end{subfigure}
    ~
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/normal run 1 day/allModelsVersion1.7.1day.T_water.c.png}
        \caption{Bacteria concentration plotted against water temperature}  \label{temperaturebacteria}
    \end{subfigure}
    \caption{Resulting plots of one year (macro scale)/one day (microscopic scale)}
\end{figure}

\section*{\centering{Discussion}}

## Discussion of processes based on parametric analysis

A parameter variation was conducted to understand their influence on the system's behavior. Nine parameters were varied between up to five values (see Table \ref{parametervariation}).
While varying one parameter, all others were assumed to be constant.

| \textsc{Parameter}  |   |   |   |   |   |
|-----------|--------------|-------------|-------------|-------------|-------------|
| $A_{roof}$    | **500**      | 1000        | 2000    | 3000 | 4000 |
|$c_0$|$1.55 \cdot 10^{-5}$|$\mathbf{1.55 \cdot 10^{-4}}$|$1.55 \cdot 10^{-4} \cdot 2$|$1.55 \cdot 10^{-4} \cdot 5$|$1.55 \cdot 10^{-3}$|
| $h_0$         | 0            | 1           | **2.5** | 4    | 5    |
| $h_{tank}$    | 2            | 4           | **5**   | 8    | 10   |
| $material$    | **concrete** | polyethylen |         |      |      |
| $h_{air}$     | 0            | 1           | **2.5** | 3    | 5    |
| $n_{taps}$    | 1            | 3           | **8**   | 10   | 20   |
| $r_{tank}$    | 1            | 2           | **3**   | 4    | 5    |
| $T_{water,0}$ | 10           | 15          | **17**  | 20   | 30   |
| $z$           | 0            | 1           | **2.5** | 4    | 5    |
  :parameter variations (**bold font** marks standard values)\label{parametervariation}

  Due to the vast amount of parameters taken into consideration in modeling the proposed system, just the ones expected to be significant were observed. In Figure \ref{heightconsumption}, it can be seen that the consumption over a day directly corresponds to the outflow of the cistern as wanted.

  In the macroscopic development (\ref{heightoveryear}), it can be seen that the tank is quickly filled in the first months of the year and emptied in the dry period, showing the expected behavior. In Figure \ref{n_tapsVariation} the effect of a increased outflow is shown, leading in the extreme case of 20 taps to an emptying of the tank in no time.

The temperature has to be evaluated contextually in Figure \ref{watertemperature}, since the excavation height is considerably high, increasing the soil temperature's influence, which keeps the temperature on a low level. Additionally, the phase difference to the temperature functions (\ref{tempplot}) follows the conduction of heat through the construction material.
Especially interesting for the temperature development is the variation of $h_{air}$, the height exposed to outside air, of concrete and polyethylen respectively in Figures \ref{h_airConcreteVariation} and \ref{h_airPolyethylenVariation}. The temperature differences depending on both the exposed height and material are clearly to be seen, same as the slight phase difference between the materials.

The only effect shown in the graphical representation above is the effect of temperature on the bacteria development which is barely observable at the fixed values, due to the minor change of the temperature over time (\ref{temperaturebacteria}). Its influence becomes obvious in the variation of the initial temperature in Figure \ref{T_water_0Variation}. One can observe that the higher the temperature the faster the bacteria fission takes place.
An overview of the correctness of the bacterial growth and thus the correctness of the bacterial equation can be found in Figure \ref{relhtoc}. Figure \ref{relhtobactamount} clearly shows what is expected of the bacterial behavior. During the pause, when a large number of people fetch water, the water level drops even if the influence of water remains constant. The amount of bacteria still in the tank has to decrease as well.
However, it is expected that the bacterial concentration will not immediately decrease noticeably during the breaks if the influence of water and only a small amount of tapped water by humans remains constant. Figure \ref{relhtobactconcentration} clearly shows that the bacteria in the tank continue to grow - albeit at a slower rate. As soon as the tank is empty, the picture also shows that the bacteria concentration has also decreased to zero. The concentration rises again with the renewed influence of water and its water enriched with bacteria with the value $c_{in}$. The case shown in Figure \ref{relhtobactconcentration} is a special case, firstly because in the calculated model the tank is never actually modeled empty and secondly because the model does not pay any further attention to the contamination that remains in an emptied (previously filled) tank - both indicated in _Limits of the Model_ above.

## Discussion of criteria for high performance

The criteria to provide enough water was firstly assumed to be simply one bottle per person per day, which is a little low, considering the bottle volume of 0.5 litres. With our implementation of the system and initial values, higher criteria limits couldn't be matched, since both the initial water height and overall cistern volume would have to be higher, which is not modeled in the parameter variation.

The criteria to provide healthy water is defined by the bacteria contamination, assuming the water is generally contaminated. For dangerous bacteria like E-Coli, where the development is derived from, the count should be zero for the water to be considered potable, but that would constitute an uninteresting bacteria development behavior.

The criteria to provide healthy water of a pleasant drinking temperature is generally useful, but its limit with a maximum of 17${^{\circ}C}$ is chosen arbitrarily. Since the dependence of human happiness on drinking water at a specific temperature is not entirely certain, one cannot link this further due to the current project phase.

In the project model, the focus was placed on the micro system. This consists of a close interaction of Inflow/Outflow, temperature and bacterial growth. This micro-cycle is fed with values from the macro, e.g. how much water can be extracted from the roofs.
Since drinking water should be provided by us with as little bacteria as possible, it would be important to know when the bacterial concentration exceeds the limit of $25 * 10^{-4}$. This could be accompanied, for example, by cleaning the tanks.
In the presented graphs, especially of the bacterial growth (7b) it is stated that after a single day a concentration of approx. $2.4 * 10^{-4}$ was reached. According to this, around 9.6% was achieved within 24 hours. An exceeding of the limit would thus be possible within a few days. Now it has to be said that the model was accepted very simplified - see _Development of Equations_ and _Limits of the Model_. For example, no sufficient circulation of the water inside the tank is worked out. In addition, values of groundwater as water source are calculated. However, since water is obtained from rain in the real system, bacteria die much faster than shown by the prevention of food. Thus, the concrete statement that the $k_{20}$/$Q_{10}$ values are of very high importance for the calculation of bacterial growth can be derived.

\section*{\centering{Appendix}}

## References

[1] R.A. Blaustein, Y. Pachepsky, R.L. Hill, D.R. Shelton, G. Whelan, Escherichia coli survival in waters: Temperature dependence, available online at www.sciencedirect.com,  (Last accessed on 16 December 2019), 2012.

[2] M. Faust, A.E. Aotaky, M.T. Hargadon, Effect of Physical Parameters on the In Situ Survival of Escherichia coli MC-6 in an Estuarine Environment, available online at www.researchgate.net, (Last accessed on 16 December 2019), 1975.

[3] B. Reyes, J. Pendergast, S. Yamazaki, Mammalian Peripheral Circadian Oscillators Are Temperature Compensated, available online at www.researchgate.net, (Last accessed on 16 December 2019), 2008.

[4] T. Hartmann, N. Bushra, Modelling With Differential Equations : : R Cheat Sheet, Multiphysics approaches for modelling civil systems, available online at www.isis-tu-berlin.de, (Last accessed on 16 December 2019), 2019.

[5] DIN EN ISO 10456 (2010-05-00); Building materials and products - Hygrothermal properties - Tabulated design values and procedures for determining declared and design thermal values (ISO 10456:2007 + Cor. 1:2009); German version EN ISO 10456:2007 + AC:2009; Publication date: 2010-05-00; https://www.perinorm.com

[6] Climate-Data.Org, Nyamasheke Climate: Average Temperature, Weather by Month, Nyamasheke Weather Averages, available online at www.en.climate-data.org/africa/rwanda/iburengerazuba/nyamasheke-56082/,(Last accessed on 16 December 2019), 2019.

[7] Prof.  Dr-Ing.  R. Hinkelmann, Strömungsmechanik für Bauingenieure - Vorlesungsskript, TU Berlin, Fachgebiet Wasserwirtschaft und Hydrosystemmodellierung, (Last accessed on 16 December 2019), 2015.

## Parameter variation analysis plots

![Variation of $A_{roof}$ \label{A_roofVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.A_roof.png){width = 95%}

![Variation of $c_0$ \label{c_0Variation}](plots/variation 3 days/allModelsVersion1.7.variation3days.c_0.png){width = 95%}

![Variation of $h_0$ \label{h_0Variation}](plots/variation 3 days/allModelsVersion1.7.variation3days.h_0.png)

![Variation of $h_{tank}$ \label{h_tankVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.h_tank.png)

![Variation of material \label{materialVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.material.png)

![Variation of $h_{air}$ (concrete material) \label{h_airConcreteVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.h_air.concrete.png)

![Variation of $h_{air}$ (polyethylen material) \label{h_airPolyethylenVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.h_air.polyethylen.png)

![Variation of $n_{taps}$ \label{n_tapsVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.n_taps.png)

![Variation of $r_{tank}$ \label{r_tankVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.r_tank.png)

![Variation of $T_{water_{0}}$ \label{T_water_0Variation}](plots/variation 3 days/allModelsVersion1.7.variation3days.T_water_0.png)

![Variation of $z$ \label{zVariation}](plots/variation 3 days/allModelsVersion1.7.variation3days.z.png)

\begin{figure}
    \centering
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/allModelsVersion1.7.1days.special.h.c.png}
        \caption{Relation of water height inside tank and bacteria concentration}  \label{relhtobactconcentration}
    \end{subfigure}
    ~
    \begin{subfigure}[b]{0.49\textwidth}
        \includegraphics[width=\textwidth]{plots/allModelsVersion1.7.1days.special.h.bactAmount.png}
        \caption{Relation of water height inside tank and the total amount of bacteria} \label{relhtobactamount}
    \end{subfigure}
    \caption{Relation of Bacterial growth to water height} \label{relhtoc}
\end{figure}

\includepdf[pages=-,pagecommand={},width=\textwidth]{./process.bacteria/equationsBacteria.pdf}
\includepdf[pages=-,pagecommand={},width=\textwidth]{./process.temperature/equationsTemperature.pdf}
\includepdf[pages=-,pagecommand={},width=\textwidth]{./process.IOmicro/equationsIOmicro.pdf}
