#' @title Moving average
#' @description
#' A simple moving average of a \code{vector}, \code{data.frame} or \code{matrix} using a convolution 
#' function written in C++/Rcpp for fast computing
#' @usage
#' movav(X,w)
#' @param X numeric \code{data.frame}, \code{matrix} or \code{vector} to process
#' @param w filter length
#' @author Antoine Stevens
#' @examples
#' data(NIRsoil)
#' wav <- as.numeric(colnames(NIRsoil$spc))
#' spc <- 1/10^NIRsoil$spc # conversion to reflectance
#' spc <- spc + rnorm(length(spc),0,0.001) # adding some noise
#' matplot(wav,t(spc[1:10,]),type='l',xlab='Wavelength /nm',ylab='Reflectance')
#' mov <- movav(spc,w=11) # window size of 11 bands
#' matlines(as.numeric(colnames(mov)),t(mov[1:10,])) # smoothed data
#' @return a \code{matrix} or \code{vector} with the filtered signal(s)
#' @seealso \code{\link[signal]{sgolayfilt}}, \code{\link{savitzkyGolay}}, \code{\link{gapDer}}, \code{\link{binning}}, \code{\link{continuumRemoval}}
#' @export
#'
movav <- function(X, w) {
    
    if (is.data.frame(X)) 
        X <- as.matrix(X)
    if (missing(w)) 
        stop("filter length w should be specified")
    if (w < 1) 
        stop("filter length w should be > 0")
    if (w == 1) 
        return(X)
    
    f <- rep(1, w)/w  # filter
    
    if (is.matrix(X)) {
        if (w >= ncol(X)) 
            stop("filter length w should be lower than ncol(X)")
        output <- convCppM(X, f)  # Convolution
        g <- ceiling((w - 1)/2)
        colnames(output) <- colnames(X)[((g + w%%2):(ncol(X) - g))]
        rownames(output) <- rownames(X)
    }
    
    if (is.vector(X)) {
        if (w >= length(X)) 
            stop("filter length w should be lower than length(X)")
        output <- convCppV(X, f)  # Convolution
        g <- (w - 1)/2
        names(output) <- names(X)[((g + w%%2):(length(X) - g))]
    }
    
    return(output)
} 
