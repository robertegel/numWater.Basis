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

# Development of Equations for the Inflow/Outflow Micro-Model
## numeric model/difference equations
### building blocks model
#### static model
![](./draftTank.jpg){width=30%}
$$A= \text{Surface of the water in tank}$$
$$B= \text{Height of outflow at water taps}$$
Bernoulli $A \rightarrow B$:

$$h+z+\dfrac{\alpha * v_A^2}{2g} = \dfrac{\alpha * v_B^2}{2g} \rightarrow
 v_B= \sqrt{\dfrac{2g}{\alpha} \left(h + z + \dfrac{\alpha * v_A^2}{2g} \right)}$$

$$Q_{out} = n_{taps} * v_B * \pi r_{taps}^2
 = n_{taps} * \pi r_{taps}^2 \sqrt{\dfrac{2g}{\alpha} \left(h + z + \dfrac{\alpha * v_A^2}{2g} \right)}$$

#### dynamic model
$$Q_{out,t} = n_{taps} * \pi r_{taps}^2 \sqrt{\dfrac{2g}{\alpha} \left(h_t + z + \dfrac{\alpha * v_A^2}{2g} \right)}$$

$$\Delta h_t = \dfrac{Q_{in} - Q_{out,t}}{\pi r_{tank}^2} \Delta t$$
$$\rightarrow h_{t} = h_{t-1} + \dfrac{Q_{in} - Q_{out,t-1}}{\pi r_{tank}^2} \Delta t$$

$$n_{bottles} = \dfrac{1}{V_{bottles}} \int_{0}^t Q_{out} \;\dif t \rightarrow
 \od{n_{bottles}}{t} = \dfrac{Q_{out}}{V_{bottles}}$$

### asymptotic dynamic model
$$\alpha \approx 1, v_A \approx 0$$

$$\rightarrow Q_{out,t} = n_{taps} * \pi r_{taps}^2 \sqrt{2g \left(h_t + z \right)}$$

$$h_{t} = F(Q_{out,t-1}, h_{t-1}) = h_{t-1} + \dfrac{Q_{in} - Q_{out,t-1}}{\pi r_{tank}^2} \Delta t$$

$$Q_{out,t} = G(Q_{out,t-1}, h_{t-1}) = n_{taps} * \pi r_{taps}^2 \sqrt{2g \left(h_{t-1} + z + \dfrac{Q_{in} - Q_{out,t-1}}{\pi r_{tank}^2} \Delta t \right)}$$

## differential equation model
$$\od{h}{t} = \dfrac{Q_{in} - Q_{out}}{\pi r_{tank}^2}$$

$$\od{Q_{out}}{t} = g * n_{taps} * \pi r_{taps}^2
\left(2g (h + z) \right)^{-1/2} \od{h}{t}$$

$$\od{n_{bottles}}{t}= \dfrac{Q_{out}}{V_{bottles}}$$
