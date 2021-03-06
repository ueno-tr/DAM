##DAMの生データから最後10日分のみを切り出す
##ファイルが長い時、多数のファイルを同時に処理する時に軽くできる
##txtファイルとして出力　DAM file scanを用いる場合はこちら
DAMcompress <- function(){
files <- list.files() #ディレクトリ内のファイル名をfilesに代入

for (file.name in files) {
    if (regexpr('.txt$', file.name)  < 0) { # ファイル名の最後が '.txt'か？
        next                                 # そうでなければスキップ．
    }

    a <- read.table(file.name, sep="\t") #テキストデータ読み込み
    b <- length(a[,1]) #aの行数
    c <- a[(b-14400):b,] #最後10日分のデータのみ切り取る

    write.table(c, file.name, col.names=FALSE, row.names=FALSE, sep="\t", quote=FALSE)
    }
}

##複数モニターのデータを三次元配列（array）にするか
##4320行、32列、モニター数の三次元配列
##3次元目を指定する名前をファイル名であるモニター番号（M10 etc）とするか
##DAM file scanで3日分など切り出し後に使用

importMarray <- function() {

  files <- list.files() #ディレクトリ内のファイル名をfilesに代入
  files <- files[1:(length(files)-1)] #summary.csvが最後に来るはずなので、これを除く


  t <- array(0, dim=c(1440*3, 32, length(files)))

  for (i in 1:length(files)) {
  file.name <- files[i]

    if (regexpr('.txt$', file.name)  < 0) { # ファイル名の最後が '.txt'か？
        next                                 # そうでなければリストから削除してスキップ．
    }

    a <- data.matrix(read.table(file.name, sep="\t")) #文字などが入っているためscanが使えない　44列データになる
    b <- a[,11:42] #最初10列を削除
    colnames(b) <- NULL #列の名前を取り除く

    t[,,i] <- b
    }

    ##filesの名前をM022などにする（1604282226CtM022.txtと言う名前を想定）
    ##後ろから8文字目~後ろから5文字目
    for (i in 1:length(files)){
      files[i] <- substring(files[i],nchar(files[i])-7,nchar(files[i])-4)
      }

      ##三次元目の名前をモニター番号にする
      dimnames(t) <- list(rownames(t), colnames(t), files)

      return(t)
      }

##32匹の活動をプロット
##arrayデータを入れる

barplotall <- function(x) {

  for(j in 1:length(x[1,1,])){

    file.name  <- unlist(dimnames(x)[3])[j]
    pdf(paste(file.name, ".pdf", sep=""), width=11, height=8)

    par(oma = c(0, 0, 2, 0))
	  par(mfcol = c(11,3)) #11行3列の形でプロット出力
	  par(mai = c(0, 0, 0, 0)) #余白設定

	for (i in 1:length(x[1,,j])) {
		title <- sprintf("%d", i)
		a <- x[,i,j]
		plot(a,  ty="h",xlab = NA, ylab = NA, axes=FALSE, ylim=c(0,50)) #x軸に時間軸 y軸にx座標の値
		text(0, 40, title)
    mtext(side = 3, line=0, outer=T, text =file.name, cex=1.5)
		}


    dev.off()

		}
  }

  ##1minのactivity dataをsleepに変換（sleepが1、awakeが0）
  ##arrayデータを入れる
  ##グラフ出力は別にする？

  ##activityを睡眠に変換
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



  ##1時間の睡眠時間dを設定
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
  ##チャンネル情報はtsvファイルで別に入れる（1列目にモニター番号、2列目に最初のチャンネル、3列目に最後のチャンネル、4列目にgenotype）
  ##出力するのはデータフレームで、1列目に時間、2列目にgenotype、3列目に睡眠の平均値、4列目にSEM
  ##入力はxがhrsleepの結果、yがチャンネル情報

  meanSEM <- function(x,y){
    out <- data.frame(matrix(NA, ncol=4, nrow=72*length(y[,1])))
    part <- data.frame(matrix(0, ncol=4, nrow=72))
    part[,1] <- c(1:72)


    for(i in 1:length(y[,1])){
      part[,2] <- y[i,4]

      a <- x[,,y[i,1]]

      s <- as.numeric(y[i,2]):as.numeric(y[i,3])
      t <- as.integer(unlist(strsplit(y[i,5],",")))
      u <- s[-which(s %in% t)]

      if(is.na(t)){
        b <- a[,s]
      }
      else{
        b <- a[,u]
      }

      part[,3] <- apply(b,1,mean)
      part[,4] <- apply(b,1,sd)/sqrt(length(b[1,]))

      out[(i*72-71):(i*72),] <- part
    }

    colnames(out) <- c("time", "genotype", "mean", "SEM")
    return(out)
  }

  ##11種類の統計量を求める
  ##input: x=importMarrayの出力、y=act2sleepの出力
  ##ともにモニター数が3次元目となる配列

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
    b <- matrix(rep(paste("C", c(1:32), sep = "")),ncol=32)
    row.names(b) <- dimnames(out)[[3]][1]
    stat <- out[,,1]
    stat <- rbind(b,stat)

    for(i in 2:length(out[1,1,])) {
  	row.names(b) <- dimnames(out)[[3]][i]
  	stat <- rbind(stat,b,out[,,i])
    }

    return(stat)
  }


  ##1hr sleepとstatをエクセルファイルとして出力
  ##hrsleepの結果をxに、DAMstatの結果をyに入れる

  library(openxlsx)

  outDAM <- function(x,y) {
    NewWb <- createWorkbook(creator = "Taro Ueno")

    for(j in 1:length(x[1,1,])){
      name  <- unlist(dimnames(x)[3])[j]
      addWorksheet(wb = NewWb, sheetName = name, gridLines = TRUE)
      writeData(wb = NewWb, sheet = name, x = x[,,j], startCol = 1, startRow = 1)
    }

    addWorksheet(wb = NewWb, sheetName = "stat", gridLines = TRUE)
    writeData(wb = NewWb, sheet = "stat", x = y, rowNames=TRUE, colNames=FALSE, startCol = 1, startRow = 1)

    openXL(NewWb)

    saveWorkbook(wb = NewWb, "result.xlsx", overwrite = TRUE)
  }

##解析の前半部分をまとめた関数DAM1
DAMsleep1 <- function() {
Marray <- importMarray()
barplotall(Marray)
sleep <- act2sleep(Marray)
hrs <- hrsleep(sleep)

stat <- DAMstat(Marray, sleep)

library(openxlsx)
outDAM(hrs, stat)

return(hrs)
  }

##解析の後半部分をまとめた関数DAM2
##DAM1の結果を引数に入れる
DAMsleep2 <- function(hrs) {
  library(readxl)
  summary <- read_excel("summary.xls")

  out <- meanSEM(hrs, summary)

  ##グラフに出力
  library(ggplot2)
  p <- ggplot(out, aes(x = time, y = mean,group=genotype, colour=genotype) ) + geom_line() + ylab("sleep (min/hr)")

  errors <- aes(ymax = mean + SEM, ymin = mean - SEM)
  p <- p + geom_errorbar(errors, width = 0.2) + geom_point(size = 2)
  p
}
