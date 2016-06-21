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
