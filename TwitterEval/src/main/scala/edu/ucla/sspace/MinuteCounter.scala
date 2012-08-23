package edu.ucla.sspace

import scala.io.Source

import java.io.PrintWriter


object MinuteCounter {
    def main(args:Array[String]) {
        val tweetIter = Source.fromFile(args(0)).getLines
//        tweetIter.next
        val tweetTimes = tweetIter.map(_.split("\\s+")(0).toDouble.toInt)
        var lastMinute = 0
        var minuteCount = 0
        val writer = new PrintWriter(args(1))
        writer.println("Time Count")
        for ( time <- tweetTimes) {
            val minute = time / 60
            if (minute != lastMinute) {
                if (lastMinute > 0) {
                    writer.println("%d %d".format(lastMinute, minuteCount))
                    for (m <- lastMinute+1 until minute)
                        writer.println("%d 0".format(m))
                }
                lastMinute = minute
                minuteCount = 0
            }
            minuteCount += 1
        }
        writer.println("%d %d".format(lastMinute, minuteCount))
        writer.close
    }
}
