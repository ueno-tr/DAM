#フォルダ内のDAMのMonitor file(.txt)を全てimportし、列方向に結合する
#モニターファイルの長さは同じ長さであること　一致しないと使えない　24時間ちょうどでない場合は引数のnをいじる
#32列のデータ+12列の不要部分
#最初12列は不要なのでこの関数中で削除し、32列の行列を出力

importMall <- function(n) {#データの日数をnで入れる
s <- matrix(0, ncol = 1, nrow=1440*n)

files <- list.files() #ディレクトリ内のファイル名をfilesに代入

for (file.name in files) {
    if (regexpr('.txt$', file.name)  < 0) { # ファイル名の最後が '.txt'か？
        next                                 # そうでなければスキップ．
    }

a <- data.matrix(read.table(file.name, sep="\t")) #文字などが入っているためscanが使えない　44列データになる
b <- a[,11:42] #最初12列を削除
colnames(b) <- NULL #列の名前を取り除く
s <- cbind(s,b)
}
t <- s[,2:length(s[1,])]
return(t)
}
