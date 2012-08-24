package edu.ucla.sspace

import scala.io.Source
import scala.math.abs


object EvaluateSegmentsAgainstEvents {
    def main(args: Array[String]) {
        val segmentIter = Source.fromFile(args(0)).getLines
        segmentIter.next
        val segmentList = segmentIter.map(_.split(",", 4)(0).toLong).toSet.toList.sorted
        val eventList = Source.fromFile(args(1)).getLines.map(_.toLong).toSet.toList.sorted

        val segmentError = eventList.map(event => abs(event - findBestSegment(event, segmentList.head, segmentList.tail))).sum
        printf("%.03f\n", segmentError/eventList.size.toDouble)
    }

    def findBestSegment(eventTime: Long, bestTime: Long, segmentList: List[Long]) : Long =
        segmentList match {
            case head::tail => if (head > eventTime) if ( abs(bestTime - eventTime) < abs(head - eventTime) ) bestTime 
                                                     else eventTime
                               else findBestSegment(eventTime, head, tail)
            case emptyList => bestTime
        }
}
