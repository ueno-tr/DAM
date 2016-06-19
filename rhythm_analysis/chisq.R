chisq.pd <- function(x, min.period, max.period, alpha) {
N <- length(x)
variances = NULL
periods = seq(min.period, max.period)
rowlist = NULL
for(lc in periods){
    ncol = lc
    nrow = floor(N/ncol)
    rowlist = c(rowlist, nrow)
    x.trunc = x[1:(ncol*nrow)]
    x.reshape = t(array(x.trunc, c(ncol, nrow)))
    variances = c(variances, var(colMeans(x.reshape)))
}
Qp = (rowlist * periods * variances) / var(x)
df = periods - 1
pvals = 1-pchisq(Qp, df)
pass.periods = periods[pvals<alpha]
pass.pvals = pvals[pvals<alpha]
#return(cbind(pass.periods, pass.pvals))
return(cbind(periods[pvals==min(pvals)], pvals[pvals==min(pvals)], Qp[pvals==min(pvals)]))
}
