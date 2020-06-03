## ----setup, include=FALSE----------------------------------------------------------------------------
rm(list=ls())

{times <- seq(from = 0, to = 60*60*24*3, by = 1) 
  
  ## ----parameters--------------------------------------------------------------------------------------
  parametersIOmicro <- c(
    # I/O micro
    g <- 9.81, # [m/s^2]
    n_taps <- 4,
    r_taps <- 1/1000 * 5, # [m]
    r_tank <- 2, # [m]
    z <- 18.0, # [m]
    Q_in <- 1/1000 * 23/60, # [m^3/s] (23 l/min)
    V_Bottle <- 1/1000 * 0.5, # [m^3]
    h_0 <- 0.0,
    # temperature
    h_air <- 2, # [m]
    h_tank <- 5) # [m] 
  
  names(parametersIOmicro) <-c("g", "n_taps", "r_taps", "r_tank", "z", "Q_in", "V_Bottle", "h_0", "h_air", "h_tank")
  
  parameters <- c(parametersIOmicro,
      # bacteria growth
      V_0 = eval(h_0 * r_tank^2 * pi), # [m^3]
      c_in = 354, # [n/ml] -> [n/m^3]
      k_20 = 0.504/ (24*60*60), # [day^-1] -> [s^-1]
      Q_10 = 1.783,
      T_20 = 20, # [°C]
      
      # temperature
      h_soil = eval(h_tank - h_air), # [m]
      d_wall = 200/1000, # [m]
      rho_wall = 2400, # [kg/m^3] (concrete: 2400, polyethylen: 980)
      rho_water = 1000, # [kg/m^3]
      lambda_wall = 2.5, # [W/(m*K)] (concrete: 2.5, polyethylen: 0.5)
      lambda_water = 0.6, # [W/(m*K)]
      c_p_wall = 1000, # [J/(kg*K)] (concrete: 1000, polyethylen:1800)
      c_p_water = 4190# [J/(kg*K)]
  )
  
  # calculate initial state (eval needed because of lazy execution)
  yini <- c(
            # I/O micro
            h = eval(h_0), # [m]
            Q_out = 0, # [m^3/s]
            n_Bottles = 0,
            V_out = 0,
            
            # bacteria growth
            c = 350, # [n/m^3]
            
            # temperature
            T_water = 22 # [°C]
            )
  
  # remove unused tmp variables
  rm(g, n_taps, r_taps, r_tank, z, Q_in, V_Bottle, h_0, h_air, h_tank) 
}

{## ----schedules/tempCurves--------------------------------------------------------------------------------------
  schedule <- function(simHours) {
    simHours <- simHours %% 24
    simHours <- round(simHours, digits=4)
    if (simHours > 8 & simHours < 9) return("class")
    if (simHours == 9) return("breakStart")
    if (simHours > 9 & simHours <= 9.2) return("break")
    if (simHours > 9.2 & simHours < 10.2) return("class")
    if (simHours == 10.2) return("breakStart")
    if (simHours > 10.2 & simHours <= 10.25) return("break")
    if (simHours > 10.25 & simHours < 11.25) return("class")
    if (simHours == 11.25) return("breakStart")
    if (simHours > 11.25 & simHours <= 11.5) return("break")
    if (simHours > 11.5 & simHours < 12.5) return("class")
    if (simHours == 12.5) return("breakStart")
    if (simHours > 12.5 & simHours <= 13.0) return("break")
    if (simHours > 13.00 & simHours < 14.00) return("class")
    if (simHours == 14) return("breakStart")
    if (simHours > 14.00 & simHours <= 14.2) return("break")
    if (simHours > 14.2 & simHours < 15.2) return("class")
    if (simHours == 15.2) return("breakStart")
    if (simHours > 15.2 & simHours <= 15.25) return("break")
    if (simHours > 15.25 & simHours < 16.25) return("class")
    if (simHours == 16.25) return("breakStart")
    if (simHours > 16.25 & simHours <= 16.5) return("break")
    else return("freeTime")
  }
  
  scheduleNumeric <- function(simHours) {
    simHours <- simHours %% 24
    if (simHours > 8 & simHours < 9) return(0)
    if (simHours == 9) return(1)
    if (simHours > 9 & simHours <= 9+1/6) return(1)
    if (simHours > 9+1/6 & simHours < 10+1/6) return(0)
    if (simHours == 10+1/6) return(1)
    if (simHours > 10+1/6 & simHours <= 10.25) return(1)
    if (simHours > 10.25 & simHours < 11.25) return(0)
    if (simHours == 11.25) return(1)
    if (simHours > 11.25 & simHours <= 11.5) return(1)
    if (simHours > 11.5 & simHours < 12.5) return(0)
    if (simHours == 12.5) return(1)
    if (simHours > 12.5 & simHours <= 13.0) return(1)
    if (simHours > 13.00 & simHours < 14.00) return(0)
    if (simHours == 14) return(1)
    if (simHours > 14.00 & simHours <= 14+1/6) return(1)
    if (simHours > 14+1/6 & simHours < 15+1/6) return(0)
    if (simHours == 15+1/6) return(1)
    if (simHours > 15+1/6 & simHours <= 15.25) return(1)
    if (simHours > 15.25 & simHours < 16.25) return(0)
    if (simHours == 16.25) return(1)
    if (simHours > 16.25 & simHours <= 16.5) return(1)
    else return(0)
  }
  
  timesMin <- seq(8,18,1/60)
  png(file="../plots/schedule.png",
      width=1000, height=1500/2, pointsize = 24)
  plot(timesMin, sapply(timesMin, scheduleNumeric), type="l", 
       ylab = "", xlab="hour of the day",
       main = "Is water drawn from the system? (binary)")
  dev.off()
  
  tempCurve <- function(simHours) {
    simHours <- simHours %% 24
    T = - ((simHours-12)/3)^2 + 28
    return(T)
  }
  
  tempCurveAir <- function(simHours) {
    T <- 5 * sin((simHours-6) * pi/12) + 25
    return(T)
  }
  
  
  tempCurveSoil <- function(simHours) {
    T <- 3 * sin((simHours-8) * pi/12) + 22
    return(T)
  }

  timesMin <- seq(0,24,1/60)
  png(file="../plots/tempCurve.png",
      width=1000, height=1500/2, pointsize = 24)
  plot(timesMin, tempCurveAir(timesMin), type="l", 
       ylab = "", xlab="hour of the day",
       main = "Daily Ambient Temperature Curve", ylim = c(17,30), col="red")
  lines(timesMin, tempCurveSoil(timesMin), col="blue")
  legend("topright", c("T_air", "T_soil"), lty=c(1,1), lwd=c(2.5,2.5), col=c("red", "blue"))
  dev.off()
}


## ----model-------------------------------------------------------------------------------------------
model <- function(t, y, parameters) {
  with(as.list(c(y, parameters)), { 
    simHours <- t/60/60
    
    #----I/O micro-------------------------------------------------------------------------------------------
    dh <- (Q_in - Q_out)/(pi * r_tank^2)
    
    if (schedule(simHours) == "break") {
      # normal outflow (school break)
      if (h > 0) {
        #dQ_out <- n_taps * 2 * pi * r_taps^2 * sqrt(2 * g) * (h + z)^(1/2) - Q_out
        dQ_out <- g * n_taps * pi * r_taps^2 * (2 * g * (h + z))^(-1/2) * dh
      } else {
        dQ_out <- - Q_out + Q_in
      }
    } else if (schedule(simHours) == "breakStart"){
      # (start of school break()
      dQ_out <- n_taps * pi * r_taps^2 * sqrt(2 * g) * (h + z)^(1/2)
    } else if (schedule(simHours) == "class" | schedule(simHours) == "freeTime") {
      # no outflow (school class)
      dQ_out <- - Q_out
    }
    
    
    dn_Bottles <- Q_out/V_Bottle
    dV_out <- Q_out
    
    V <- max(h * r_tank^2 * pi, 0.0002)
    #V <- h * r_tank^2 * pi
    

    #----temperature-------------------------------------------------------------------------------------------
    T_air <- tempCurveAir(simHours)
    T_soil <- tempCurveSoil(simHours)
    
    R_ia_bottom    <- d_wall /(lambda_wall * pi * r_tank^2)
    R_ia_side_soil <- d_wall /(lambda_wall * 2 * pi * r_tank * h_soil)
    R_ia_side_air  <- d_wall /(lambda_wall * 2 * pi * r_tank * h_air)
    R_ia_top       <- d_wall /(lambda_wall * pi * r_tank^2)
    
    c_i_bottom     <- c_p_water * rho_water * pi * r_tank^2 * h_tank + c_p_wall * rho_wall * d_wall * pi * r_tank^2
    c_i_side_soil  <- c_p_water * rho_water * pi * r_tank^2 * h_tank + c_p_wall * rho_wall * d_wall * 2 * pi * r_tank * h_soil
    c_i_side_air   <- c_p_water * rho_water * pi * r_tank^2 * h_tank + c_p_wall * rho_wall * d_wall * 2 * pi * r_tank * h_air
    c_i_top        <- c_p_water * rho_water * pi * r_tank^2 * h_tank + c_p_wall * rho_wall * d_wall * pi * r_tank^2
    
    dT_water_conduction <- (T_soil-T_water)/(R_ia_bottom * c_i_bottom) +
      (T_soil-T_water)/(R_ia_side_soil * c_i_side_soil) +
      (T_air-T_water)/(R_ia_side_air * c_i_side_air) +
      (T_air-T_water)/(R_ia_top * c_i_top)
    
    dT_water_pollution <- ((Q_in * T_air + V * T_water - Q_out * T_water)/(V + Q_in - Q_out)) - T_water
    
    dT_water <- dT_water_conduction + dT_water_pollution
    ##----bacterial growth-------------------------------------------------------------------------------------------
    k <- k_20 * Q_10^((T_water - T_20)/10)
    
    #dc <- ((Q_in*c_in) - (0.000184396*c)) / (h_0 * r_tank^2 * pi) + (k * c)
    #dc <- ((Q_in*c_in) - (0*c)) / (V) #+ (k * c)
    #dc <- ((Q_in*c_in) - (0*c)) / (V_0 + (Q_in - 0) * t)  + (k * c)
    #dc <- ((Q_in*c_in) - (Q_out*c)) / (V_0 + (Q_in - V_out/t) * t)  + (k * c)
    #dc <- ((Q_in*c_in) - (V_out/t*c)) / (V_0 + ((Q_in - V_out/t) * t)) + (k * c)
    
    dc <- ((Q_in * c_in + V * c - Q_out *c)/(V + Q_in - Q_out)) - c + (k * c)
    #dc <- (k * c)
    
    # return everything
    return(list(c(dh, dQ_out, dn_Bottles, dV_out, dc, dT_water)))
  }
  )}
## -solver---------------------------------------------------------------------------------------------------
library(deSolve)

system.time(out <- ode(func = model, y = yini, times = times, parms = parameters, 
                       method = "euler"))

## -plots---------------------------------------------------------------------------------------------------

{
  version <- "microBactTempVersion1.2"
  
  simDays <- eval(times / 60/60/24)
  skipper <- seq(1,length(out[,1]), by=30)
  data <- as.data.frame(out[skipper,])
  simDays <- simDays[skipper]
  data$simDays <- simDays
  
  # png(file=paste0("../plots/", version, ".plot1.png"), width=2000, height=1500, pointsize = 24)
  par(mfrow = c(2,2))
  plot(simDays, data[, "h"], type = "l", ylab = "h", ylim = c(0, max(out[, "h"])))
  plot(simDays, data[, "Q_out"], type = "l", ylab = "Q_out", ylim = c(0, max(out[, "Q_out"])))
  plot(simDays, data[, "n_Bottles"], type = "l", ylab = "n_Bottles")
  plot(simDays, data[, "c"], type = "l", ylab = "concentration bacteria")
  mtext(paste0(version," plot1, z=", parameters["z"], " n_taps=", parameters["n_taps"]), side = 3, line = -2, outer = TRUE)
  # dev.off()
}

{  
  # png(file=paste0("../plots/", version, ".plot2.png"), width=2000, height=1500, pointsize = 24)
  par(mfrow = c(2,2))
  plot(simDays, data[, "h"], type = "l", ylab = "h", ylim = c(0, max(out[, "h"])))
  plot(simDays, data[, "c"], type = "l", ylab = "concentration bacteria")
  plot(simDays, data[, "c"]*data[, "h"]*pi*parameters["r_tank"]^2, type = "l", ylab = "total amount bacteria")
  plot(simDays, data[, "T_water"], type = "l", ylab = "T_water")
  mtext(paste0(version, " plot2, z=", parameters["z"], " n_taps=", parameters["n_taps"]), side = 3, line = -2, outer = TRUE)
  # dev.off()
}

interactionPlot <- function(x, y1, y2, nameX, nameY1, nameY2, legendPosition){
  plot(x, y1, type="l", ylab="", xlab = nameX)
  par(new = TRUE)
  plot(x, y2, type = "l", axes = FALSE, bty = "n", xlab = "", ylab = "", col = "red")
  axis(side=4, at = pretty(range(y2)), col="red")
  legend(legendPosition, c(nameY1, nameY2), lty=c(1,1), lwd=c(2.5,2.5), col=c("black", "red"))
}

interactionPlot <- function(dataset, nameX, nameY1, nameY2, legendPosition){
  plot(dataset[[nameX]], dataset[[nameY1]], type="l", ylab="", xlab = nameX)
  par(new = TRUE)
  plot(dataset[[nameX]], dataset[[nameY2]], type = "l", axes = FALSE, bty = "n", xlab = "", ylab = "", col = "red")
  axis(side=4, at = pretty(range(dataset[[nameY2]])), col="red")
  legend(legendPosition, c(nameY1, nameY2), lty=c(1,1), lwd=c(2.5,2.5), col=c("black", "red"))
}

{
  # png(file=paste0("../plots/", version, ".plot3.png"), width=2000, height=1500, pointsize = 24)
  par(mfrow = c(2,2))
  interactionPlot(data, "simDays", "h", "Q_out", "topright")
  interactionPlot(data, "simDays", "h", "T_water", "bottomright")
  interactionPlot(data, "simDays", "h", "c", "bottomright")
  interactionPlot(data, "simDays", "T_water", "c", "bottomright")
  mtext(paste0(version, " plot3 (interaction), z=", parameters["z"], " n_taps=", parameters["n_taps"]), side = 3, line = -2, outer = TRUE)
  # dev.off()
}

# plot(simDays, data[, "T_water"], type = "l", ylab = "T_water", xlim = c(0.540,0.542))
# plot(simDays, data[, "h"], type = "l", ylab = "h", xlim = c(0.540,0.542))
# plot(simDays, data[, "Q_out"], type = "l", ylab = "Q_out", xlim = c(0.540,0.542))

#plot(simDays, out[, "c"], type = "l", ylab = "concentration bacteria", ylim=c(440, 470))

#plot(simHours, out[, "V_out"], type = "l", ylab = "V_out")
#plot(simHours, out[, "V_out"]/simHours, type = "l", ylab = "V_out/time")

# {
#   simHours <- eval(times / 60/60)
#   par(mfrow = c(2,2))
#   plot(simHours, out[, "h"], type = "l", ylab = "h", xlim = c(8,17))
#   plot(simHours, out[, "Q_out"], type = "l", ylab = "Q_out", ylim = c(0, max(out[, "Q_out"])), xlim = c(8,17))
#   plot(simHours, out[, "n_Bottles"], type = "l", ylab = "n_Bottles", xlim = c(8,17))
#   plot(out[, "h"], out[, "Q_out"], type = "l", xlab = "h", ylab = "Q_out")
#   mtext("Integration Model v0.6", side = 3, line = -2, outer = TRUE)
# }
