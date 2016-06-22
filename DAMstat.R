##11種類の統計量を求める
##input: x=importMarrayの出力、y=act2sleepの出力
##ともにモニター数が3次元目となる配列

DAMstat <- function(x,y) {
  out <- array(0, dim=c(11, 32, length(x[1,1,])))
  rownames(out) <- c("total acitivy counts", "time active", "percent of time active", "amount of time resting", "waking activity index", "number of activity-rest bout", "mean length of activity period", "mean activity counts during one activity period", "maximum time of one activity period", "mean length of resting period", "maximum time of one resting period")

  for(j in 1:length(x[1,1,])) {
    out[1,,j] <- apply(x[,,j], 2, sum)/3

    sleep <- apply(y[,,j], 2, sum)/3
    out[4,,j] <- sleep/60
    out[2,,j] <- (1440 - sleep)/60
    out[3,,j] <- (1440 - sleep)/14.4

    out[5,,j] <- out[1,,j]/(1440-sleep)

    z <- matrix(0, ncol=32)
    bout1 <- rbind(z, y[,,j])
    bout2 <- rbind(y[,,j], z)
    bout3 <- bout1 - bout2
    bout4 <- bout3[2:(length(bout3[,1])-1),]
    bout5 <- bout4*bout4
    out[6,,j] <- apply(bout5, 2, sum)/3/2

    out[10,,j] <- sleep / out[6,,j]

    out[7,,j] <- (1440 - sleep) / out[6,,j]

    out[8,,j] <- out[1,,j]/out[6,,j]

    z <- (y-1)*(y-1)

    for (m in 1:length(y[1,,j])) {
          for (n in 2:length(y[,m,j])) {
            if (y[n,m,j] == 1) {
              y[n,m,j] <- y[n-1,m,j] + 1
              }
              else {
                y[n,m,j] <- 0
                }
                }
                }
                out[11,,j] <- apply(y[,,j], 2, max)

                for (m in 1:length(z[1,,j])) {
                      for (n in 2:length(z[,m,j])) {
                        if (z[n,m,j] == 1) {
                          z[n,m,j] <- z[n-1,m,j] + 1
                          }
                          else {
                            z[n,m,j] <- 0
                            }
                            }
                            }
                            out[9,,j] <- apply(z[,,j], 2, max)

  }
  dimnames(out) <- list(rownames(out), colnames(out), dimnames(x)[[3]])

  ##配列から行列に変換
  b <- matrix(NA,ncol=32)
  row.names(b) <- dimnames(out)[[3]][1]
  stat <- out[,,1]
  stat <- rbind(b,stat)

  for(i in 2:length(out[1,1,])) {
	row.names(b) <- dimnames(out)[[3]][i]
	stat <- rbind(stat,b,out[,,i])
  }

  return(stat)
}
