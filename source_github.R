##githubからsourceする
source_github <- function(u) {
   # load package
   require(RCurl)
   # read script lines from website and evaluate
   script <- getURL(u, ssl.verifypeer = FALSE)
   eval(parse(text = script))
 }

##使い方
source_github("https://raw.githubusercontent.com/ueno-tr/DAM/master/summary/all.R")



##githubからsourceする
##evalのオプションが違うもの　こちらだと読み込んだ関数が使えるか
source_github <- function(u) {
   # load package
   require(RCurl)
   # read script lines from website and evaluate
   script <- getURL(u, ssl.verifypeer = FALSE)
    eval(parse(text = script),envir=.GlobalEnv)
 }

##使い方
source_github("https://raw.githubusercontent.com/ueno-tr/DAM/master/summary/DAM%20function%20all.R")

source_github("https://raw.githubusercontent.com/ueno-tr/DAM/master/summary/all.R")
