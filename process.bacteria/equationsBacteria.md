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

# Development of Equations for the Bacterial Growth Model

Exponential bacterial growth - due to bacteria fission:

$$\od{c(t)}{t} = k c \rightarrow \Delta c = k c \Delta t$$


Bacterial growth regarding temperature dependence - inactivation rate k at specific temperature T in reference to 20degree outside and a chosen water source (see [1]):

$$\dfrac{k}{k_{20}} = Q_{10}^{(T - T_{20})/10} \rightarrow k = k_{20} * Q_{10}^{(T - T_{20})/10}$$


Bacterial concentration in water tank (compare [4] - Pollution concentration in liquid tank ):

$$c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t}
\rightarrow \Delta c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t} - c$$
$$\rightarrow \dif c = \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} - c$$


Bacterial concentration in water tank and bacterial growth:

$$\Delta c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t} + k c \Delta t - c$$

$$\rightarrow \dif c = \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} + k c \dif t - c$$


Combination - bacteria concentration in water tank and bacterial growth including inaktivation rate k depending on temperature: 

$$\Delta c = \dfrac{Q_{in} c_{in} \Delta t + V c - Q_{out} c \Delta t}{Q_{in} \Delta t + V - Q_{out} \Delta t} + k c \Delta t - c$$

$$\rightarrow \dif c = \left[ \left( \dfrac{Q_{in} c_{in} \dif t + V c - Q_{out} c \dif t}{Q_{in} \dif t + V - Q_{out} \dif t} \right) + \left( k_{20} Q_{10}^{(T - T_{20})/10} c \right) \dif t  \right] - c$$
