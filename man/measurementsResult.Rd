\name{measurementsResult}
\alias{measurementsResult}


\title{
General cost function by plume-wise summary of values at locations 
}
\description{
It evaluates values at \code{locations} plume-wise and summarises the result by calls to \code{simulationsApply}. 
}
\usage{
measurementsResult(simulations, locations, kinds, 
  fun_p = NA, fun_Rp = NA, fun_pl = NA, fun_Rpl = NA)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{simulations}{\code{Simulations} object}
  \item{locations}{indices of locations, i.e. rows of \code{simulations@values} to be taken into account; if nothing indicated, all rows are used (invalid)}
  \item{kinds}{index or name of the layer of \code{simulations@values} to be used}
  \item{fun_p}{\code{function} for plume-wise summary; forwarded to \code{\link{simulationsApply}} -- see there for details}
  \item{fun_Rp}{\code{function} to summarise the result of \code{fun_p}; forwarded to \code{\link{simulationsApply}} -- see there for details}
  \item{fun_pl}{\code{function} for value-wise summary; forwarded to \code{\link{simulationsApply}} -- see there for details}
  \item{fun_Rpl}{\code{function} to summarise the result of \code{fun_pl}; forwarded to \code{\link{simulationsApply}} -- see there for details}
}
\details{
It is a general cost function, after specifying some parameters via \code{\link{replaceDefault}} with \code{type = "costFun"} it can be used as \code{costFun} in \code{\link{optimiseSD}}. Examples are cost functions related to plume detection as given in \code{\link{measurementsResultFunctions}}.
}
\value{
  \code{"cost"}: result of \code{fun_Rp} (must be a single value in order to qualify as \code{costFun} in \code{optimiseSD})
  \code{"costPlumes"}: result of \code{fun_p}, a matrix where each row represents a plume.
}

\author{ kristina.helle@uni-muenster.de  }

\examples{
# get data
data(radioactivePlumes_area)
  
# sample locations (potential sensor locations)
sampleLocations1 = sample.int(nLocations(radioactivePlumes_area), 1000)

# compute input data
## extra values: detection (a plume is detected at a location if exceeds the threshold)
threshold = 1e-7
radioactivePlumes_area@values$undetected = calc(
  radioactivePlumes_area@values$maxdose,
  fun = function(x){x < threshold})
## extra plumes's values (needed to callibrate cost functions): 
### total dose
radioactivePlumes_area@plumes$totalDose = 
  summaryPlumes(radioactivePlumes_area, fun = sum, kinds = "finaldose")[[2]]
  

# modify 'measurementResult' to cost function 'singleDetection' 
singleDetection = replaceDefault(measurementsResult, newDefaults = list(
  kinds = "undetected",
  fun_p = function(x, nout = 1){
    y = min(x)
    if (length(x) == 0){
      y = 1
    }
    return(y)
    },
  fun_Rp = function(x, weight = 1, nout = 1){
    mean(x * weight$totalDose)/mean(weight$totalDose)
  }),
  type = "costFun")[[1]]  

# compute cost for sensors at 'sampleLocations1'
  singleDetection1 = singleDetection(
    simulations = radioactivePlumes_area,
    locations = sampleLocations1) 

}