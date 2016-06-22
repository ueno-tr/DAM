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
