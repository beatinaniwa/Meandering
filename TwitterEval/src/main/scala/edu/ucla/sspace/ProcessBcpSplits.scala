package edu.ucla.sspace

import edu.ucla.sspace.similarity.CosineSimilarity

import scala.io.Source
import java.io.PrintWriter


object ProcessBcpSplits {
    val lambda = 0.5
    val beta = 100
    val w = (0.45, 0.45, 0.10)
    val sim = new CosineSimilarity()

    def main(args: Array[String]) {
        val converter = TweetModeler.load(args(0), args(1), args(2))
        val changeIter = Source.fromFile(args(3)).getLines
        var changePointSeconds = changeIter.filter(_.endsWith("1"))
                                           .map(_.split("\\s+")(0).toLong * 60)
                                           .toList

        var groupTweets = List[Tweet]()
        var groupId = 1

        val simFunc = (t1: Tweet, t2: Tweet) => Tweet.sim(t1, t2, lambda, beta, w, sim)
        val summaryMethod = args(6) match {
            case "median" => Tweet.medianSummary _
            case "mean" => Tweet.meanSummary _
            case "phrase" => Tweet.phraseGraphSummary _
        }

        val summaryWriter = new PrintWriter(args(5))
        summaryWriter.println("Start,Mean,Group,Summary")
        val groupsWriter = new PrintWriter(args(4))
        groupsWriter.println("Time,Group")

        val tweetIter = args.slice(7, args.length).map(converter.tweetIterator).reduce(_++_)

        for (tweet <- tweetIter) {
            if (tweet.timestamp > changePointSeconds.head) {
                val startTime = groupTweets.map(_.timestamp).min
                val summaryTweet = summaryMethod(groupTweets, converter, simFunc)
                val meanTime = summaryTweet.timestamp
                val summary = converter.rawText(summaryTweet).replace("\"", "'").replace(",", ";")
                summaryWriter.println("%d,%d,%d,%s".format(startTime, meanTime, groupId, summary))

                changePointSeconds = changePointSeconds.tail
                groupId += 1
                groupTweets = List[Tweet]()
            }

            groupTweets :+= tweet
            groupsWriter.println("%d,%d".format(tweet.timestamp, groupId))

        }

        summaryWriter.close
        groupsWriter.close
    }
}
