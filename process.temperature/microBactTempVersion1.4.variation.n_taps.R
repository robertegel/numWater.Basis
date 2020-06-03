## ----setup, include=FALSE----------------------------------------------------------------------------
rm(list=ls())

{times <- seq(from = 0, to = 60*60*24*1, by = 1) 
  
  ## ----parameters--------------------------------------------------------------------------------------
  basicParameters <- c(
    # I/O micro
    r_tank <- 2, # [m]
    h_0 <- 1.0,
    # temperature
    h_air <- 2, # [m]
    h_tank <- 5,  # [m] 
    T_water_0 <- 22, # [°C]
    # bacteria
    c_0 <- 354) # [n/m^3]
  
  names(basicParameters) <-c("r_tank", "h_0", "h_air", "h_tank", "T_water_0", "c_0")
  
  parameters <- c(basicParameters,
                  # I/O micro
                  g = 9.81, # [m/s^2]    
                  #n_taps = 4,
                  r_taps = 1/1000 * 5, # [m]
                  z = 18.0, # [m]
                  Q_in = 1/1000 * 23/60, # [m^3/s] (23 l/min)
                  V_Bottle = 1/1000 * 0.5, # [m^3]
                              
                  # bacteria growth
                  V_0 = eval(h_0 * r_tank^2 * pi), # [m^3]
                  c_in = 354, # [n/ml] -> [n/m^3]
                  k_20 = 0.504/ (24*60*60), # [day^-1] -> [s^-1]
                  Q_10 = 1.783,
                  
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
  
  variationList <- cbind(n_taps = c(1,2,5,10))
  
  # calculate initial state (eval needed because of lazy execution)
  yini <- c(
            # I/O micro
            h = eval(h_0), # [m]
            Q_out = 0, # [m^3/s]
            n_Bottles = 0,
            V_out = 0,
            
            # bacteria growth
            c = eval(c_0), # [n/m^3]
            
            # temperature
            T_water = eval(T_water_0) # [°C]
            )
  
  # remove unused tmp variables
  rm(r_tank, h_0, h_air, h_tank, T_water_0, c_0, basicParameters) 
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
    k <- k_20 * Q_10^((T_water - 20)/10)

    dc <- ((Q_in * c_in + V * c - Q_out *c)/(V + Q_in - Q_out)) - c + (k * c)
    #dc <- (k * c)
    
    # return everything
    return(list(c(dh, dQ_out, dn_Bottles, dV_out, dc, dT_water)))
  }
  )}
## -solver---------------------------------------------------------------------------------------------------
library(deSolve)

outList <- list()

for (i in 1:nrow(variationList)) {
  time <- system.time(outList[[i]] <- ode(func = model, y = yini, times = times, 
                                        parms = c(variationList[i,], parameters), method = "euler"))
  print(time)
  rm(time)
}

## -plots---------------------------------------------------------------------------------------------------

outData <- data.frame()

for (i in 1:4) {
  simDays <- eval(times / 60/60/24)
  skipper <- seq(1,length(outList[[i]][,1]), by=30)
  simDays <- simDays[skipper]
  tmp <- as.data.frame(outList[[i]][skipper,])
  tmp$n_taps <- variationList[i]
  tmp$simDays <- simDays
  outData <- rbind(outData, tmp)
}

outData$n_taps <- as.factor(outData$n_taps)

{
  library(ggplot2)
  library(cowplot)
    
  version <- "microBactTempVersion1.4.variation.n_taps"
  
  plotgird <- plot_grid(
    ggplot(outData, aes(simDays, h, group=n_taps)) +
      geom_line(size = 0.5, aes(colour = n_taps)),
    ggplot(outData, aes(simDays, n_Bottles, group=n_taps)) +
      geom_line(size = 0.5, aes(colour = n_taps)),
    ggplot(outData, aes(simDays, T_water, group=n_taps)) +
      geom_line(size = 0.5, aes(colour = n_taps)),
    ggplot(outData, aes(simDays, c, group=n_taps)) +
      geom_line(size = 0.5, aes(colour = n_taps))
    )
  title <- ggdraw() + 
    draw_label(paste0(version, ".plot1"))
  titled_plotgrid <- plot_grid(title, plotgird,  ncol = 1,  rel_heights = c(0.05, 1))
  ggsave2(paste0("../plots/",version,".plot1.png"), plot = titled_plotgrid, width = 12, height = 8, units = "in")
}
