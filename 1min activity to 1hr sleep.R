##1minのactivity dataをsleepに変換（sleepが1、awakeが0）
##arrayデータを入れる
##グラフ出力は別にする？

##activityを睡眠に変換
##最後の4分の判定は、5分前の判定を入れる。要検討。
act2sleep <- function(x) {
  sleep <- array(0, dim=c(1440*3, 32, length(x[1,1,])))

  for(j in 1:length(x[1,1,])){

    for(i in 1:(1440*3-4)){
      a <- x[i:(i+4),,j]
      b <- apply(a,2,sum)

      for(h in 1:32){
        sleep[i,h,j] <- sleep[i,h,j] + (b[h] == 0) ##TRUEなら1足す
      }
    }

    sleep[4317:4320,,j] <- sleep[4316,,j]
  }
  dimnames(sleep) <- dimnames(x)
  return(sleep)
}



##1時間の睡眠時間を設定
##act2sleepの結果を入れる
hrsleep <- function(x){
  hr <- array(0, dim=c(72, 32, length(x[1,1,])))

  for(j in 1:length(x[1,1,])){

    for(i in 1:72) {
       a <- x[(i*60-59):(i*60),,j]
       hr[i,,j] <- apply(a,2,sum)
     }

   }
   dimnames(hr) <- dimnames(x)
   return(hr)
}



##規定したチャンネルで1時間ずつの睡眠の平均値とSEMを出力
##チャンネル情報はcsvファイルで別に入れる（1列目にモニター番号、2列目に最初のチャンネル、3列目に最後のチャンネル、4列目にgenotype）
##出力するのはデータフレームで、1列目に時間、2列目にgenotype、3列目に睡眠の平均値、4列目にSEM
##入力はxがhrsleepの結果、yがチャンネル情報

meanSEM <- function(x,y){
  out <- data.frame(matrix(NA, ncol=4, nrow=72*length(y[,1])))
  part <- data.frame(matrix(0, ncol=4, nrow=72))
  part[,1] <- c(1:72)


  for(i in 1:length(y[,1])){
    part[,2] <- y[i,4]

    a <- x[,,y[i,1]]
    b <- a[,as.numeric(y[i,2]):as.numeric(y[i,3])]

    part[,3] <- apply(b,1,mean)
    part[,4] <- apply(b,1,sd)/sqrt(length(b[1,]))

    out[(i*72-71):(i*72),] <- part
  }

  colnames(out) <- c("time", "genotype", "mean", "SEM")
  return(out)
}



##グラフに出力
library(ggplot2)
p <- ggplot(df, aes(x = time, y = mean,group=genotype, colour=genotype) ) + geom_line()

errors <- aes(ymax = mean + SEM, ymin = mean - SEM)
p <- p + geom_errorbar(errors, width = 0.2) + geom_point(size = 2)
