\name{par3dinterp}
\alias{par3dinterp}
\title{Interpolator for par3d parameters}
\description{
Returns a function which interpolates \code{par3d} parameter values,
suitable for use in animations.
}
\usage{
par3dinterp(times = NULL, userMatrix, scale, zoom, FOV, 
            method = c("spline", "linear"), 
            extrapolate = c("oscillate", "cycle", "constant", "natural"),
            dev = rgl.cur(), subscene = par3d("listeners", dev = dev))
}
\arguments{
  \item{times}{ Times at which values are recorded or a list; see below }
  \item{userMatrix}{ Values of \code{par3d("userMatrix")} }
  \item{scale}{ Values of \code{par3d("scale")} }
  \item{zoom}{ Values of \code{par3d("zoom")} }
  \item{FOV}{ Values of \code{par3d("FOV")} }
  \item{method}{ Method of interpolation }
  \item{extrapolate}{ How to extrapolate outside the time range }
  \item{dev}{ Which rgl device to use }
  \item{subscene}{ Which subscene to use }
}
\details{
This function is intended to be used in constructing animations.  It produces
a function that returns a list suitable to pass to \code{\link{par3d}}, to set 
the viewpoint at a given point in time.

All of the parameters are optional.  Only those \code{par3d} parameters that are 
specified will be returned.

The input values other than \code{times} may each be specified as
lists, giving the parameter value settings at a fixed time, or as
matrices or arrays.  If not lists, the following formats should be
used: \code{userMatrix} can be a \code{4 x 4 x n} array, or a \code{4
x 4n} matrix; \code{scale} should be an \code{n x 3} matrix;
\code{zoom} and \code{FOV} should be length \code{n} vectors.

An alternative form of input is to put all of the above arguments into
a list (i.e. a list of lists, or a list of arrays/matrices/vectors),
and pass it as the first argument.  This is the most convenient way to
use this function with the  function
\code{\link{tkpar3dsave}}.

Interpolation is by cubic spline or linear interpolation in an appropriate
coordinate-wise fashion.  Extrapolation may oscillate
(repeat the sequence forward, backward, forward, etc.), cycle (repeat
it forward), be constant (no repetition outside the specified time
range), or be natural (linear on an appropriate scale).   
In the case of cycling, the first and last specified values
should be equal, or the last one will be dropped.  Natural extrapolation
is only supported with spline interpolation.

}
\value{
A function is returned.  The function takes one argument, and returns a list of 
\code{par3d} settings interpolated to that time.
}
\note{
Prior to rgl version 0.95.1476, the
\code{subscene} argument defaulted to the
current subscene, and any additional entries would
be ignored by \code{\link{play3d}}.  The current
default value of \code{par3d("listeners", dev = dev)} means that all subscenes that share 
mouse responses will also share modifications
by this function.
}
\author{Duncan Murdoch }
\seealso{ \code{\link{play3d}} to play the animation. }
\examples{
f <- par3dinterp( zoom = c(1, 2, 3, 1) )
f(0)
f(1)
f(0.5)
\dontrun{
play3d(f)
}
}
\keyword{ dplot }
