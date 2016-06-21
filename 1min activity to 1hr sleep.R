##1minのactivity dataを1hrのsleepに変換する

##3日分のactivity dataをimport
test <- matrix(scan("test.csv", sep=","), ncol=32, byrow=T)

#5minのbinを3日分設定 aは5分ごとのsleep（0 or 1）
a <- matrix(0, ncol=32, nrow=length(test[,1])/5)

##5分ずつ切り取り、行列bとする
##5分間のactivityのtotalをcとする
##totalが0であればaに1を入れる
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
