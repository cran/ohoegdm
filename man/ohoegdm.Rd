% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ohoegdm-wrapper.R
\name{ohoegdm}
\alias{ohoegdm}
\title{Ordinal Higher-Order General Diagnostic Model under the
Exploratory Framework (OHOEGDM)}
\usage{
ohoegdm(
  y,
  k,
  m = 2,
  order = k,
  sd_mh = 0.4,
  burnin = 1000L,
  chain_length = 10000L,
  l0 = c(1, rep(100, sum(choose(k, seq_len(order))))),
  l1 = c(1, rep(1, sum(choose(k, seq_len(order))))),
  m0 = 0,
  bq = 1
)
}
\arguments{
\item{y}{Ordinal Item Matrix}

\item{k}{Dimension to estimate for Q matrix}

\item{m}{Number of Item Categories. Default is \code{2} matching the binary case.}

\item{order}{Highest interaction order to consider. Default model-specified \code{k}.}

\item{sd_mh}{Metropolis-Hastings standard deviation tuning parameter.}

\item{burnin}{Amount of Draws to Burn}

\item{chain_length}{Number of Iterations for chain.}

\item{l0}{Spike parameter. Default 1 for intercept and 100
coefficients}

\item{l1}{Slab parameter. Default 1 for all values.}

\item{m0, bq}{Additional tuning parameters.}
}
\value{
A \code{ohoegdm} object containing four named lists:
\itemize{
\item \strong{\code{estimates}}: Averaged chain iterations
\itemize{
\item \code{thetas}: Average theta coefficients
\item \code{betas}: Average beta coefficients
\item \code{deltas}: Average activeness of coefficients
\item \code{classes}: Average class membership
\item \code{m2lls}: Average negative two times log-likelihood
\item \code{omegas}: Average omega
\item \code{kappas} : Average category threshold parameter
\item \code{taus}: Average \eqn{K}-vectors of factor intercept
\item \code{lambdas}: Average \eqn{K}-vectors of factor loadings
\item \code{guessing}: Average guessing item parameter
\item \code{slipping}: Average slipping item parameter
\item \code{QS}: Average activeness of Q matrix entries
}
\item \strong{\code{chain}}: Chain iterations from the underlying \emph{C++} rountine.
\itemize{
\item \code{thetas}: Theta coefficients iterations
\item \code{betas}:  Beta coefficients iterations
\item \code{deltas}: Activeness of coefficients iterations
\item \code{classes}:  Class membership iterations
\item \code{m2lls}: Negative two times log-likelihood iterations
\item \code{omegas}:  Omega iterations
\item \code{kappas} : Category threshold parameter iterations
\item \code{taus}: \eqn{K}-vector of factor intercept iterations
\item \code{lambdas}: \eqn{K}-vector of factor loadings iterations
\item \code{guessing}: Guessing item parameter iterations
\item \code{slipping}: Slipping item parameter iterations
}
\item \strong{\code{details}}: Properties used to estimate the model
\itemize{
\item \code{n}: Number of Subjects
\item \code{j}: Number of Items
\item \code{k}: Number of Traits
\item \code{m}: Number of Item Categories.
\item \code{order}: Highest interaction order to consider. Default model-specified \code{k}.
\item \code{sd_mh}: Metropolis-Hastings standard deviation tuning parameter.
\item \code{l0}: Spike parameter
\item \code{l1}: Slab parameter
\item \code{m0}, \code{bq}: Additional tuning parameters
\item \code{burnin}: Number of Iterations to discard
\item \code{chain_length}: Number of Iterations to keep
\item \code{runtime}: Elapsed time algorithm run time in the \emph{C++} code.
}
\item \strong{\code{recovery}}: Assess recovery metrics under a simulation study.
\itemize{
\item \code{Q_item_encoded}: Per-iteration item encodings from Q matrix.
\item \code{MHsum}: Average acceptance from metropolis hastings sampler
}
}
}
\description{
Performs the Gibbs sampling routine for an ordinal higher-order EGDM.
}
\details{
The \strong{\code{estimates}} list contains the mean information from the sampling
procedure. Meanwhile, the \strong{\code{chain}} list contains full MCMC values. Moreover,
the \strong{\code{details}} list provides information regarding the estimation call.
Lastly, the \strong{\code{recovery}} list stores values that can be used when
assessing the method under a simulation study.
}
\examples{
# Simulation Study
if (requireNamespace("edmdata", quietly = TRUE)) {
# Q and Beta Design ----

# Obtain the full K3 Q matrix from edmdata
data("qmatrix_oracle_k3_j20", package = "edmdata")
Q_full = qmatrix_oracle_k3_j20

# Retain only a subset of the original Q matrix
removal_idx = -c(3, 5, 9, 12, 15, 18, 19, 20)
Q = Q_full[removal_idx, ]

# Construct the beta matrix by-hand
beta = matrix(0, 20, ncol = 8)

# Intercept
beta[, 1] = 1

# Main effects
beta[1:3, 2] = 1.5
beta[4:6, 3] = 1.5
beta[7:9, 5] = 1.5

# Setup two-way effects
beta[10, c(2, 3)] = 1
beta[11, c(3, 4)] = 1

beta[12, c(2, 5)] = 1
beta[13, c(2, 5)] = 1
beta[14, c(2, 6)] = 1

beta[15, c(3, 5)] = 1
beta[16, c(3, 5)] = 1
beta[17, c(3, 7)] = 1

# Setup three-way effects
beta[18:20, c(2, 3, 5)] = 0.75

# Decrease the number of Beta rows
beta = beta[removal_idx,]

# Construct additional parameters for data simulation
Kappa = matrix(c(0, 1, 2), nrow = 20, ncol = 3, byrow =TRUE) # mkappa
lambda = c(0.25, 1.5, -1.25) # mlambdas
tau = c(0, -0.5, 0.5) # mtaus


# Simulation conditions ---- 
N = 100        # Number of Observations
J = nrow(beta) # Number of Items
M = 4          # Number of Response Categories
Malpha = 2     # Number of Classes
K = ncol(Q)    # Number of Attributes
order = K      # Highest interaction to consider
sdmtheta = 1   # Standard deviation for theta values

# Simulate data ---- 

# Generate theta values
theta = rnorm(N, sd = sdmtheta)

# Generate alphas 
Zs = matrix(1, N, 1) \%*\% tau + 
     matrix(theta, N, 1) \%*\% lambda + 
     matrix(rnorm(N * K), N, K)
Alphas = 1 * (Zs > 0)

vv = gen_bijectionvector(K, Malpha)
CLs = Alphas \%*\% vv
Atab = GenerateAtable(Malpha ^ K, K, Malpha, order)$Atable

# Simulate item-level data
Ysim = sim_slcm(N, J, M, Malpha ^ K, CLs, Atab, beta, Kappa)

# Establish chain properties 
# Standard Deviation of MH. Set depending on sample size.
# If sample size is:
#  - small, allow for larger standard deviation
#  - large, allow for smaller standard deviation.
sd_mh = .4 
burnin = 50        # Set for demonstration purposes, increase to at least 5,000 in practice.
chain_length = 100 # Set for demonstration purposes, increase to at least 40,000 in practice.

# Setup spike-slab parameters
l0s = c(1, rep(100, Malpha ^ K - 1))
l1s = c(1, rep(1, Malpha ^ K - 1))

my_model = ohoegdm::ohoegdm(
  y = Ysim,
  k = K,
  m = M,
  order = order,
  l0 = l0s,
  l1 = l1s,
  m0 = 0,
  bq = 1,
  sd_mh = sd_mh,
  burnin = burnin,
  chain_length = chain_length
)
}
}
