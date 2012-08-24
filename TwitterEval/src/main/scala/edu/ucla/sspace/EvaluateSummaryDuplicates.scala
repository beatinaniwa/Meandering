package edu.ucla.sspace

object EvaluateSummaryDuplicates {
    def main(args: Array[String]) {
        val summaries = Util.loadFrame(args(0), sep=",").map(_(3))
        val totalSummaries = summaries.size
        val numUnique = summaries.toSet.size
        val numDuplicates = totalSummaries - numUnique
        printf("%.02f\n", 100*numDuplicates/totalSummaries.toDouble) 
    }
}
