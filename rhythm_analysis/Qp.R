#32匹のn(>=5)daysのデータから、5daysのsliding windowでchi-squareを行い、Qpの最大値を出力する
#入力は32列、1440xn行の行列
#出力は32列、n-4行の行列
Qp.chisq <- function(y, min.period, max.period, alpha) {

	m <- length(y[,1]) / 1440

	out <- matrix(0, ncol=32, nrow=m-4)
	x <- numeric(1440*5)

	for (j in 1:32){
		for (i in 1:(m-4)){
			x <- y[(1440*(i-1)+1):(1440*(i+4)),j]


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
b <- cbind(periods[pvals==min(pvals)], pvals[pvals==min(pvals)], Qp[pvals==min(pvals)])

out[i,j] <- max(b[,3])
}
}
return(out)
}
