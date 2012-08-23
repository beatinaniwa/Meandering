package edu.ucla.sspace

import scala.io.Source


object FormSegmentationTable {
    def main(args: Array[String]) {
        val scores = Source.fromFile(args(0)).getLines.map(_.split("\\s+")).toList
        val sports = scores.map(_(0)).toSet
        val methods = scores.map(_(1)).toSet
        val checkMax = args(1).toBoolean
        val isInt = args(2) match {
            case "double" => false 
            case "int" => true
            case _ => throw new IllegalArgumentException("not a valid type")
        }

        val scoreMap = scores.map(a => ( (a(0), a(1)), a(2).toDouble ))
                             .toMap

        printf("""\begin{tabular}{|c|%s|}""", methods.toList.map(_=>"c").mkString("|"))
        println
        println("""\hline""")
        printf("""Sport & %s \\""", methods.mkString(" & "))
        println
        println("""\hline""")
        for (sport <- sports) {
            printf("""%s & %s \\""", sport, printResults(methods.toList.map(method => scoreMap((sport, method))),
                                                         checkMax=checkMax,
                                                         isInt=isInt))
            println
        }
        println("""\hline""")
        println("""\end{tabular}""")
    }

    def printResults(scores: List[Double], checkMax: Boolean = false, isInt: Boolean = true) = {
        val best = if (checkMax) scores.max else scores.min
        scores.map(score => 
                if (isInt)  {
                    if (score == best) """\textbf{%.0f}""".format(score)
                    else "%.0f".format(score)
                } else {
                    if (score == best) """\textbf{%.02f}""".format(score)
                    else "%.02f".format(score)
                }
        ).mkString(" & ")
    }
}
