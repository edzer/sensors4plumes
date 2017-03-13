\name{optimiseSD_ssa}
\alias{optimiseSD_ssa}
\title{
Spatial Simulated Annealing optimisation algorithm
}
\description{
Runs Spatial Simulated Annealing (SSA) optimisation for a given Simulations object and cost function. The aim is a cost value. The algorithm moves the initial sensors to reach the aim. 
In each iteration SSA moves one or more sensors randomly within their neighbourhood; the size of shifts decreases during the run. If a movement decreases cost, it is accepted. Else it may be accepted, too: the decision is random, with higher probability for acceptance in the beginning of the run and if the move increases cost only little. Acceptance of worse results helps to escape from local optima
}
\usage{
optimiseSD_ssa(simulations, costFun,
  locationsAll, locationsFix, locationsInitial,
  aimCost = NULL, aimNumber = NULL,            
  maxShiftNumber = length(locationsInitial), startMoveProb = 0.5, 
  maxShiftFactor = 0.2, minShiftFactor = 0.01,
  maxIterations = 5000, maxStableIterations = 500, 
  maxIterationsJumpBack = maxStableIterations - 1, 
  acceptanceMethod = "vanGroenigen", 
  start_acc_vG = 0.5, end_acc_vG = 0.0001, cooling_vG = 0.999, startAcceptance_vG = 0.5, 
  start_acc_iI = 0.2,
  plot = FALSE, nameSave = NULL, verbatim = FALSE)
}

\arguments{
  \item{simulations}{ \code{\link{Simulations} object}}
  \item{costFun}{cost function, must have parameters \code{simulations} and \code{locations} (may be prepared by \code{replaceDefault} with \code{type = "costFun.optimiseSD"}); it must return cost as a single value or a list where this is the first entry}
  \item{locationsAll}{indices of the \code{locations} that are considered possible sensor locations}
  \item{locationsFix}{indices of \code{locations} with fix sensors -- to be considered when computing cost}
  \item{locationsInitial}{indices of \code{locations} where sensors are initially}
  \item{aimCost}{limit value of the \code{costFun}: the result has to fall below}
  \item{aimNumber}{if no \code{locationsInitial} given, it starts from this number of random locations}
  \item{maxShiftNumber}{how many of the sensors can maximally be shifted in each iteration}
  \item{startMoveProb}{initial probability to move sensors -in any case at least one sensor is moved}
  \item{maxShiftFactor}{initial maximal size of shifts (as fraction of extent)}
  \item{minShiftFactor}{final maximal size of shifts (as fraction of extent)}
  \item{maxIterations}{maximal number of iterations (iteration means tried sensor changes, not all are accepted)}
  \item{maxStableIterations}{it stops after this number of iterations in a row without improvement}
  \item{maxIterationsJumpBack}{if for this number of iterations the best result is not improved, the sampling design jumpes back to the last best design; by default this does not occur}
  \item{acceptanceMethod}{formula to compute probability to accept worse result: for \code{"vanGroenigen"} acceptance decreases relative to worsening, for \code{"intamapInteractive"} it does not; for both probability of acceptance decreases during the run}
  \item{start_acc_vG}{acceptance worse results in first iteration (for \code{acceptanceMethod = "vanGroenigen"})}
  \item{end_acc_vG}{acceptance of worse results in maxIterations-th iteration (for \code{acceptanceMethod = "vanGroenigen"})}
  \item{cooling_vG}{cooling parameter (for \code{acceptanceMethod = "vanGroenigen"}), see details}
  \item{startAcceptance_vG}{second cooling parameter (for \code{acceptanceMethod = "vanGroenigen"}), see details}
  \item{start_acc_iI}{calibration factor of acceptance for \code{acceptanceMethod = "intamapInteractive"} (equals \code{start_p} in \code{\link[intamapInteractive]{ssaOptim}}), see details}
  \item{plot}{if iteration is plotted (currently disabled)}
  \item{nameSave}{\code{character} path and name (without suffix!) where to save intermediate results (sampling design of each iteration)}
  \item{verbatim}{print intermediate results and keep sampling desings and cost of all iterations}
}

\details{
In general the function is used within the wrapper \code{\link{optimiseSD}}. The following parameters are specific to \code{optimiseSD_ssa}: maxShiftNumber, startMoveProb, maxShiftFactor, minShiftFactor, maxIterations, maxStableIterations, maxIterationsJumpBack, acceptanceMethod, start_acc_vG, end_acc_vG, cooling_vG, startAcceptance_vG, start_acc_iI. They may be changed beforehand via \code{\link{replaceDefault}} with \code{type = "optimisationFun.optimiseSD"}; all other parameters are forwarded from \code{optimiseSD}.

In one iteration more than one sensor may be moved: first \code{maxShiftNumber} sensors are selected; for each of them, probability to move it is \eqn{startMoveProb * (1 - k / maxIterations)} where \eqn{k} indicates the iteration; only the first is moved in any case. The decision if the movement is accepted refers to the common movement of all finally selected sensors. Moving many sensors allows for big changes, it can be useful if initial sensors are suposed to be far from the optimum.

\code{maxShiftFactor} and \code{minShiftFactor} are given as fractions of the extent. If the underlying spatial object of the \code{simulations} is gridded, a shift size below cellsize would not allow any shifts. Therefore in this case it is set to at least cell size (independently in both coordinates).

Acceptance of worse results for \code{acceptanceMethod = "vanGroenigen"} is \eqn{exp((costOld - costCurrent) / (startAcceptance * cooling ^ k)}. This means it is higher for small cost difference and decreases with iteration \code{k}.
You may set the parameters \code{cooling_vG} and \code{startAcceptance_vG} directly - to achieve this, set either \code{start_acc_vG} or \code{end_acc_vG} to \code{NULL}. However,  \code{start_acc_vG} and \code{end_acc_vG} provide a more intuitive way to define acceptance: the algorithm computes the median cost difference when moving one sensor randomly or within the close neighbourhood (to next point) and adjusts cooling and startAcceptance to achieve the indicated acceptance rates.
For \code{acceptanceMethod = "intamapInteractive"} acceptance of worse results is \eqn{start_acc_iI * exp(-10 * k / maxIterations)}. It is the same no matter how much worse the new design is, it just decreases with iteration \code{k}.
}
\value{
A list
\item{SD}{final sampling desing}
\item{SD_best}{best sampling design ever found}
\item{cost}{cost of \code{SD}}
\item{cost_best}{cost of \code{SD_best}}
\item{report}{\code{data.frame} with columns \code{cost} and \code{accepted}, rows refer to iterations.}

If \code{verbatim = TRUE} more information is returned:
The \code{report} has additional columns: \code{costTest} (cost of the design tested in this iteration, no matter if it was accepted; \code{cost} refers to the currently accepted design); \code{costBest} (best cost until then); \code{chi} (random value that was used for the acceptance decision).

In addition it returns a matrix each for \code{SDs}, \code{SDs_test}, \code{SDs_test} with the current, tested and best known sampling designs of all iterations.

If \code{acceptanceMethod = "vanGroenigen"} it returns the cooling parameters \code{cooling} and \code{startAcceptance} as they may be computed inside the algorithm.

It gives the iterations with \code{jumpBack} i.e. when the current sampling design was replaced by the known best.
}
\author{ kristina.helle@uni-muenster.de  }

\examples{
# the function is to be used inside of optimiseSD
# change parameters 
optimSD_ssa1 = replaceDefault(
  optimiseSD_ssa,  newDefaults = list(
    start_acc_vG = 0.1,
    aimCost = 0, 
    verbatim = TRUE,
    maxIterations = 3000,
    maxStableIterations = 500,
    maxIterationsJumpBack = 200   
  ),
  type = "optimisationFun.optimiseSD")[[1]] 

# define possible, fix, and initial sensors
data(radioactivePlumes_area)
locDel3 = sample.int(nLocations(radioactivePlumes_area), 5)
locKeep3 = sample(setdiff(1:nLocations(radioactivePlumes_area), locDel3), 100)
locAll3 = c(sample(setdiff(1:nLocations(radioactivePlumes_area), 
  c(locDel3, locKeep3)), 10), locDel3)

# prepare data
threshold = 1e-7
radioactivePlumes_area@values$detectable = calc(
  radioactivePlumes_area@values$maxdose,
  fun = function(x){x >= threshold})
radioactivePlumes_area@plumes$nDetectable = 
  summaryPlumes(radioactivePlumes_area, fun = sum, values = "detectable")[[2]]  
costInitial1 = multipleDetection(simulations = radioactivePlumes_area, 
  locations = c(locKeep3, locDel3))

# run optimisation
optSSA1 = optimiseSD(
  simulations = radioactivePlumes_area,
  costFun = multipleDetection,
  locationsAll = setdiff(1:nLocations(radioactivePlumes_area), c(locKeep3, locAll3)),                       
  locationsFix = locKeep3,
  locationsInitial = locDel3,
  aimCost = 0.05 * costInitial1[[1]], 
  aimNumber = length(locDel3),
  optimisationFun = optimSD_ssa1
)  

# visualise 
## cost curve
plot(optSSA1$report$costTest, pch = ".")
lines(optSSA1$report$costBest, col = 4)
lines(optSSA1$report$cost, col = 3)
points(optSSA1$report$costTest, pch = ".", col = optSSA1$report$accepted + 2)
## designs
allSDs = subsetSDF(radioactivePlumes_area@locations,
  locations = c(locKeep3, locDel3, optSSA1$SD[1:5], unique(as.integer(optSSA1$SDs_test))))
AllSDs = as(allSDs, "SpatialPointsDataFrame")  
radioactivePlumes_area@locations@data$nDetectable = 
  summaryLocations(radioactivePlumes_area, fun = sum, kinds = "detectable")[[2]] 
spplot(radioactivePlumes_area@locations, zcol = "nDetectable",
  sp.layout = list("sp.points", AllSDs, 
  pch = c(rep(4, length(locKeep3)), 
          rep(1, length(locDel3)), 
          rep(20, 5), rep(46, 1450)), 
  col = "green"))
}