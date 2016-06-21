##DAMの生データから最後10日分のみを切り出す
##ファイルが長い時、多数のファイルを同時に処理する時に軽くできる
##txtファイルとして出力　DAM file scanを用いる場合はこちら

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



##下記はRDSとして保存する場合　データ容量が軽くなる
##データフレームとなる
##この後もRで解析できればこちら
files <- list.files() #ディレクトリ内のファイル名をfilesに代入

for (file.name in files) {
    if (regexpr('.txt$', file.name)  < 0) { # ファイル名の最後が '.txt'か？
        next                                 # そうでなければスキップ．
    }

    a <- read.table(file.name, sep="\t") #テキストデータ読み込み
    b <- length(a[,1]) #aの行数
    c <- a[(b-14400):b,] #最後10日分のデータのみ切り取る

    saveRDS(c, paste(strtrim(file.name,9), ".rds", sep=""))
    }
