##複数モニターのデータを三次元配列（array）にするか
##4320行、32列、モニター数の三次元配列
##3次元目を指定する名前をファイル名であるモニター番号（M10 etc）とするか
##DAM file scanで3日分など切り出し後に使用


importMarray <- function(n) {#データの日数をnで入れる

files <- list.files() #ディレクトリ内のファイル名をfilesに代入

t <- array(0, dim=c(1440*n, 32, length(files)))


for (i in 1:length(files)) {
  file.name <- files[i]

    if (regexpr('.txt$', file.name)  < 0) { # ファイル名の最後が '.txt'か？
        next                                 # そうでなければスキップ．
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

dimnames(t) <- list(rownames(t), colnames(t), files)

return(t)
}
