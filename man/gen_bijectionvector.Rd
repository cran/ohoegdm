% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/RcppExports.R
\name{gen_bijectionvector}
\alias{gen_bijectionvector}
\title{Generate a vector to map polytomous vector to integers}
\usage{
gen_bijectionvector(K, M)
}
\arguments{
\item{K}{Number of Attributes}

\item{M}{Number of Response Categories}
}
\value{
Return a \eqn{K}-length vector containing the bijection vector.
}
\description{
Converts class into a bijection to integers
}
