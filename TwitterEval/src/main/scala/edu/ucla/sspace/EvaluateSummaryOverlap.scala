package edu.ucla.sspace

object EvaluateSummaryOverlap {
    def main(args: Array[String]) {
        val summary1 = Util.loadFrame(args(0), sep=",").map(_(3))
        val summary2 = Util.loadFrame(args(1), sep=",").map(_(3))
        val numSummaries = summary1.size
        val numMatches = summary1.zip(summary2).map{ case(s1, s2) => s1 == s2 }.filter(_==true).size
        printf("%.03f\n", numMatches / numSummaries.toDouble)
    }
}
