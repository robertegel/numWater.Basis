## ----setup, include=FALSE----------------------------------------------------------------------------
rm(list=ls())
library(deSolve)
version <- "allModelsVersion1.7.1day"

# source external file to define helper functions
# for schedule, temperature and rain curve, parameters
source("./schedules.climate.parameters.R")

microRun <- function(parameters, yini, days, timestep = 1) {
  times <- seq(from = 0, to = 60*60*24*days, by = timestep)
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
          dQ_out <- g * n_taps * pi * r_taps^2 * (2 * g * (h + z))^(-1/2) * dh/timestep()
        } else {
          dQ_out <- - (Q_out + Q_in)/timestep()
        }
      } else if (schedule(simHours) == "breakStart"){
        # (start of school break()
        dQ_out <- n_taps * pi * r_taps^2 * sqrt(2 * g) * (h + z)^(1/2)/timestep()
      } else if (schedule(simHours) == "class" | schedule(simHours) == "freeTime") {
        # no outflow (school class)
        dQ_out <- - Q_out/timestep()
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
      k <- k_20 * Q_10^((T_water - T_20)/10)

      dc <- ((Q_in * c_in + V * c - Q_out *c)/(V + Q_in - Q_out)) - c + (k * c)
      #dc <- (k * c)

      # return everything
      return(list(c(dh, dQ_out, dn_Bottles, dV_out, dc, dT_water)))
    }
    )
  }

  ## -solver---------------------------------------------------------------------------------------------------
  out <- ode(func = model, y = yini, times = times, parms = parameters, method = "euler")

  return(out)
}

macroRun <- function(parameters, yini) {
  times <- seq(from = 1, to = 365, by = 1)
  ## ----model-------------------------------------------------------------------------------------------
  model <- function(t, y, parameters) {
    with(as.list(c(y, parameters)), {
      simDay    <- t %% 365 # [day]
      dayrain   <- rainCurve(simDay)

      dV <- (dayrain*A_roof-Q_out)

      if (V > cap & dV > 0) {
        dV <- 0
      } else if (V < 0 & dV < 0) {
        dV <- 0
      }

      return(list(c(dV)))
    })
  }
  ## -solver---------------------------------------------------------------------------------------------------
  out <- ode(func = model, y = yini, times = times, parms = parameters, method = "euler")
  h   <- out[, "V"]/(parameters["radius"]^2*pi)
  out <- cbind(out, h)
  return(out)
}

## -run models---------------------------------------------------------------------------------------------------
days <- 7
h_0 <- 0.5

microStart <- defineMicroParametersYiniVariation(h_0 = h_0)
system.time(outMicro <- microRun(parameters = microStart$parameters, yini = microStart$yini, days = days, timestep = 60))
outMicro[[nrow(outMicro), "V_out"]]

macroStart <- defineMacroParametersYini(Q_out = outMicro[[nrow(outMicro), "V_out"]]/days)
outMacro <- macroRun(parameters = macroStart$parameters, yini = macroStart$yini)

if (min(outMacro[, "h"]) < h_0) {
  microStart <- defineMicroParametersYiniVariation(h_0 = min(outMacro[, "h"]))
  outMicro <- microRun(parameters = microStart$parameters, yini = microStart$yini, days = days, timestep = 10)
  outMicro[[nrow(outMicro), "V_out"]]
}

## -plots macro---------------------------------------------------------------------------------------------------
{
  #png(file=paste0("./plots/", version, ".h.macro.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(outMacro[, "time"], outMacro[, "h"], type = "l", ylab = "h", xlab = "simulation time (days)")
  #dev.off()
  #png(file=paste0("./plots/", version, ".V.macro.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(outMacro[, "time"], outMacro[, "V"], type = "l", ylab = "V", xlab = "simulation time (days)")
  #dev.off()
}

## -plots micro---------------------------------------------------------------------------------------------------
{
  times <- outMicro[,"time"]
  simDays <- eval(times / 60/60)
  skipper <- seq(1,length(outMicro[,1]), by=30)
  data <- as.data.frame(outMicro[skipper,])
  simDays <- simDays[skipper]
  data$simDays <- simDays
  data$bactAmount <- data[, "c"]*data[, "h"]*pi*microStart$parameters["r_tank"]^2

  #png(file=paste0("./plots/", version, ".h.micro.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "h"], type = "l", ylab = "h", xlab = "simulation time (hours)")
  #dev.off()
  
  #png(file=paste0("./plots/", version, ".Q_out.micro.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "Q_out"], type = "l", ylab = "Q_out", xlab = "simulation time (hours)")
  #dev.off()
  
  #png(file=paste0("./plots/", version, ".n_Bottles.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "n_Bottles"], type = "l", ylab = "n_Bottles", xlab = "simulation time (hours)")
  #dev.off()
  
  #png(file=paste0("./plots/", version, ".c.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "c"], type = "l", ylab = "concentration bacteria", xlab = "simulation time (hours)")
  #dev.off()
}

{
  png(file=paste0("./plots/", version, ".bactAmount.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "c"]*data[, "h"]*pi*microStart$parameters["r_tank"]^2, type = "l", ylab = "total amount bacteria", xlab = "simulation time (hours)")
  dev.off()
  
  png(file=paste0("./plots/", version, ".T_water.png"), width=2000/2, height=1500/2, pointsize = 24)
  plot(simDays, data[, "T_water"], type = "l", ylab = "T_water", xlab = "simulation time (hours)")
  dev.off()
}

{
  png(file=paste0("./plots/", version, ".h.Q_out.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "h", "Q_out", "topright")
  dev.off()
  
  png(file=paste0("./plots/", version, ".h.T_water.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "h", "T_water", "bottomleft")
  dev.off()
  
  png(file=paste0("./plots/", version, ".h.c.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "h", "c", "bottomleft")
  dev.off()
  
  png(file=paste0("./plots/", version, ".h.bactAmount.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "h", "bactAmount", "bottomleft")
  dev.off()
  
  png(file=paste0("./plots/", version, ".T_water.bactAmount.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "T_water", "bactAmount", "bottomleft")
  dev.off()
  
  png(file=paste0("./plots/", version, ".T_water.c.png"), width=2000/2, height=1500/2, pointsize = 24)
  interactionPlot(data, "simDays", "T_water", "c", "bottomleft")
  dev.off()
}
