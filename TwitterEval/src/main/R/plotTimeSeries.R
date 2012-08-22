library(ggplot2)

tData <- data.frame(read.table("results/tweet.archery.batch-mean.all.groups.dat", header=TRUE))
eData <- data.frame(read.table("results/olympics.archery.times.uniq.dat", header=FALSE))

#     geom_vline(xintercept=as.numeric(eData$V1)) +
p <- ggplot(tData, aes(x=Time)) + 
     geom_histogram(binwidth=100) + 
     xlab("") +
     ylab("") +
     ylim(0, 50)+
     theme_bw() +
     opts(axis.ticks = theme_blank(), 
          axis.text.x = theme_blank(),
          axis.text.y = theme_blank())

ggsave("tweet.archery.example-partition.pdf")
