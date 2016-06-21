##1minのactivity dataを1hrのsleepに変換してグラフ出力

##3日分のactivity dataをimport
test <- matrix(scan("test.csv", sep=","), ncol=32, byrow=T)

#5minのbinを3日分設定 aは5分ごとのsleep（0 or 1）
a <- matrix(0, ncol=32, nrow=length(test[,1])/5)

##5分ずつ切り取り、行列bとする
##5分間のactivityのtotalをcとする
##totalが0であればaに1を入れる
##ここは5分で区切っているが、要修正
for(i in 1:(length(test[,1])/5)) {
  b <- test[((i-1)*5+1):(i*5), ]
  c <- apply(b,2,sum)
  for(j in 1:32){
    if(c[j] == 0){
      a[i,j] <- 1
    }
  }
}

##1時間の睡眠時間dを設定
d <- matrix(0,ncol=32, nrow=length(test[,1])/60)

for(i in 1:(length(a[,1])/12)) {
  e <- a[((i-1)*12+1):(i*12), ]
  d[i,] <- apply(e,2,sum)
}

##5倍して1時間の睡眠時間に変換
d <- d*5

##規定したチャンネルで1時間ずつの睡眠の平均値とSEMを出力
##xに1時間の睡眠時間dを、yにまとめたいチャンネルのベクトルを入れる
##1列目に平均値、2列目にSEM

meanSEM <- function(x,y){
  out <- matrix(0, ncol=2, nrow=72)
  part <- x[,y]
  out[,1] <- apply(part,1,mean)
  out[,2] <- apply(part,1,sd)/sqrt(length(part[1,]))
  df <- data.frame(out)
  colnames(df) <- c("mean", "SEM")
  return(df)
}

##まとめて解析するchannelを設定
channel <- c(1:16)
mean <- meanSEM(d, channel)

##グラフに出力
library(ggplot2)
p <- ggplot(mean, aes(x = c(1:72), y = mean)) + geom_line()

errors <- aes(ymax = mean + SEM, ymin = mean - SEM)
p <- p + geom_errorbar(errors, width = 0.2) + geom_point(size = 2)
