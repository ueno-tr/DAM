##関数定義後の実行
##DAMfilescanによる3日分のデータと、summary.xlsファイルがワーキングディレクトリに必要

Marray <- importMarray()
barplotall(Marray)
sleep <- act2sleep(Marray)
hrs <- hrsleep(sleep)

stat <- DAMstat(Marray, sleep)

library(openxlsx)
outDAM(hrs, stat)

##ここまでまず行い、生データを確認してsummaryを修正する

library(readxl)
summary <- read_excel("summary.xls")

out <- meanSEM(hrs, summary)

##グラフに出力
library(ggplot2)
p <- ggplot(out, aes(x = time, y = mean,group=genotype, colour=genotype) ) + geom_line() + ylab("sleep (min/hr)")

errors <- aes(ymax = mean + SEM, ymin = mean - SEM)
p <- p + geom_errorbar(errors, width = 0.2) + geom_point(size = 2)
p
