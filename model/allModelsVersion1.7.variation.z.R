## ----setup, include=FALSE----------------------------------------------------------------------------
rm(list=ls())
library(ggplot2)
library(deSolve)

version <- "allModelsVersion1.7.variation3days.z"

# source external file to define helper functions
# for schedule, temperature and rain curve, parameters
source("./schedules.climate.parameters.R")

microRun <- function(parameters, yini, days) {
  times <- seq(from = 0, to = 60*60*24*days, by = 1)
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
  h       <- out[, "V"]/(parameters["radius"]^2*pi)
  out     <- cbind(out, h)
  return(out)
}

variationsz <- c(0,1,2.5,4,5)

microOutData <- data.frame()
macroOutData <- data.frame()

for (z in variationsz) {
  microStart <- defineMicroParametersYiniVariation(z = z)
  print(paste0("z = ", z))

  time <- system.time(outMicro <- microRun(parameters = microStart$parameters, yini = microStart$yini, days = 1))
  print(time)
  rm(time)

  macroStart <- defineMacroParametersYini(Q_out = outMicro[[nrow(outMicro), "V_out"]])
  outMacro <- macroRun(parameters = macroStart$parameters, yini = macroStart$yini)

  if (min(outMacro[, "h"]) < microStart$parameters["h_0"]) {
    microStart <- defineMicroParametersYiniVariation(h_0 = min(outMacro[, "h"]), z = 0)
    print("running micro model a second time")
    time <- system.time(outMicro <- microRun(parameters = microStart$parameters, yini = microStart$yini, days = 1))
    print(time)
    rm(time)
  }

  simDays <- eval(outMicro[,"time"] / 60/60/24)
  skipper <- seq(1,length(outMicro[,1]), by=30)
  simDays <- simDays[skipper]
  tmp <- as.data.frame(outMicro[skipper,])
  tmp$z <- as.factor(c(z))
  tmp$simDays <- simDays
  microOutData <- rbind(microOutData, tmp)

  tmp <- as.data.frame(outMacro)
  tmp$z <- as.factor(c(z))
  macroOutData <- rbind(macroOutData, tmp)
}

## -plots---------------------------------------------------------------------------------------------------
{
  library(ggplot2)
  library(cowplot)

  plotgird <- plot_grid(
    ggplot(microOutData, aes(simDays, n_Bottles,  group=z)) +
      geom_line(size = 0.5, aes(colour = z)) +
      xlab("simulation time in days"),
    ggplot(macroOutData, aes(time, V, group=z)) +
      geom_line(size = 0.5, aes(colour = z)) +
      xlab("simulation time in days"),
    ggplot(microOutData, aes(simDays, T_water, group=z)) +
      geom_line(size = 0.5, aes(colour = z)) +
      xlab("simulation time in days"),
    ggplot(microOutData, aes(simDays, c, group=z)) +
      geom_line(size = 0.5, aes(colour = z)) +
      xlab("simulation time in days")
    )
  title <- ggdraw() +
    draw_label(paste0(version,""))
  titled_plotgrid <- plot_grid(title, plotgird,  ncol = 1,  rel_heights = c(0.05, 1))
  ggsave2(paste0("./plots/",version,".png"), plot = titled_plotgrid, width = 12, height = 8, units = "in")
}
