#DAMのMonitor file(.txt)をimport
#32列のデータ+12列の不要部分
#最初12列は不要なのでこの関数中で削除し、32列の行列を出力
#importするモニタを引数nで指定する

importMfile <- function(n) {#importするモニタ番号n
files <- list.files() #ディレクトリ内のファイル名をfilesに代入

target <- sprintf("%2d.txt", n)	#n.txtというファイル名を指定させる＊Macでfile scanした用　Winの場合は、6は006となるのでそれに合わせて00%1d.txtなどと変更する

for (file.name in files) {
    if (regexpr(target, file.name)  < 0) { # ファイル名の最後が 'n.txt'か？
        next                                 # そうでなければスキップ．
    }

a <- data.matrix(read.table(file.name, sep="\t")) #文字などが入っているためscanが使えない　44列データになる
b <- a[,11:42] #最初12列を削除
colnames(b) <- NULL #列の名前を取り除く
}
return(b)
}
