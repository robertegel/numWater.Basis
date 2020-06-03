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
 - \usepackage{setspace} # für setstretch
---
\pagenumbering{gobble} <!-- keine Seitenzahlen -->

# Development of Equations for the Temperature Model

![Draft of the citern, with relevant measures and temperature flow arrows](../pictures/tank_draftcopy.jpg){width=60%}

# thermal conduction
$$\od{T_{water}}{t} = \dfrac{T_{amb} - T_{water}}{R_{ia} * c_i}$$

$$R_{ia} = \dfrac{d}{\lambda*A} = \left[
\dfrac{\text m}{\frac{\text W}{\text m \text K}\text m^2} = \dfrac{\text K}{\text W} = \dfrac{\text K \text s^3}{\text m^2 \text{kg}}
\right]$$

$$c_i = c_p * \rho V = \left[
\dfrac{\text J}{\text{kg} * \text K} * \dfrac{\text{kg}}{\text m ^3} * \text m ^3 =
\dfrac{\text J}{\text K} =
\dfrac{\text m^2 \text{kg}}{\text K \text s^2}
\right]$$

$$c_i * R_{ia} = \left[
\dfrac{\text K \text s^3}{\text m^2 \text{kg}} * \dfrac{\text m^2 \text{kg}}{\text K \text s^2} =
\text s
\right]$$

$$c_i = c_p * \rho V = c_{p,water} \rho_{water} V_{water} + c_{p,wall} \rho_{wall} V_{wall}$$

$$\od{T_{water}}{t} =
\dfrac{T_{soil} - T_{water}}{R_{ia,bottom} * c_{i,bottom}} +
\dfrac{T_{soil} - T_{water}}{R_{ia,side,soil} * c_{i,side,soil}} $$

$$
+ \dfrac{T_{air} - T_{water}}{R_{ia,side,air} * c_{i,side,air}} +
\dfrac{T_{air} - T_{water}}{R_{ia,top} * c_{i,top}}
$$

# applying pollution equation for temperature (since inflow water has ambient temperature as well)
$$\text{Pollution Concentration in water tank: } c = \dfrac{Q_{in}*c_{in} + V*c - Q_{out}*c}{Q_{in} + V - Q_{out}}$$
$$\rightarrow \od{c}{t} = \dfrac{Q_{in}*c_{in} + V*c - Q_{out}*c}{Q_{in} + V - Q_{out}} - c$$

$$\text{Pollution Concentration in water tank: } c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t}$$
$$\rightarrow \Delta c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t} - c$$
$$\rightarrow \dif c = \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} - c$$

$$\rightarrow \dif T_{water} = \dfrac{Q_{in} T_{in} \dif t + V T_{water} - Q_{out} T_{water} \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} - T_{water}$$

# combination
$$\od{T_{water}}{t} =
\dfrac{T_{soil} - T_{water}}{R_{ia,bottom} * c_{i,bottom}} +
\dfrac{T_{soil} - T_{water}}{R_{ia,side,soil} * c_{i,side,soil}} $$
$$+
\dfrac{T_{air} - T_{water}}{R_{ia,side,air} * c_{i,side,air}} +
\dfrac{T_{air} - T_{water}}{R_{ia,top} * c_{i,top}} +
\dfrac{Q_{in} T_{in} \dif t + V T_{water} - Q_{out} T_{water} \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} * \od{}{t} - \dfrac{T_{water}}{\dif t}
$$
