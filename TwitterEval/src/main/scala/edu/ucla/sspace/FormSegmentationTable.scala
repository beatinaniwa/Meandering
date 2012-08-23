package edu.ucla.sspace

import scala.io.Source


object FormSegmentationTable {
    def main(args: Array[String]) {
        val scores = Source.fromFile(args(0)).getLines.map(_.split("\\s+")).toList
        val sports = scores.map(_(0)).toSet
        val methods = scores.map(_(1)).toSet
        val scoreMap = scores.map(a => ( (a(0), a(1)), a(2).toInt ))
                             .toMap

        printf("""\begin{tabular}{|c|%s|}""", methods.toList.map(_=>"c").mkString("|"))
        println
        println("""\hline""")
        printf("""Sport & %s \\""", methods.mkString(" & "))
        println
        println("""\hline""")
        for (sport <- sports) {
            printf("""%s & %s \\""", sport, printResults(methods.toList.map(method => scoreMap((sport, method)))))
            println
        }
        println("""\hline""")
        println("""\end{tabular}""")
    }

    def printResults(scores: List[Int], checkMax: Boolean = false) = {
        val best = if (checkMax) scores.max else scores.min
        scores.map(score => 
                if (score == best) """\textbf{%d}""".format(score)
                else "%d".format(score)
        ).mkString(" & ")
    }
}
