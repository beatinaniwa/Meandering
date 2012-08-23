library(bcp)

args <- commandArgs(trailingOnly = TRUE)
minuteData <- data.frame(read.table(args[1], header=TRUE))
minuteX <- as.matrix(minuteData$Count)

minuteX.cp <- bcp(minuteX, return.mcmc=TRUE)

write(minuteX.cp$mcmc.rhos[,550], args[2])
