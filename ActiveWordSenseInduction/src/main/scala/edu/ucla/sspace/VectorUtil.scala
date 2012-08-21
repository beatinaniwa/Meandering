package edu.ucla.sspace

import scalala.tensor.sparse.SparseVector

import scala.io.Source


object VectorUtil {
    def loadSparseData(dataFile: String) = {
        val lines = Source.fromFile(dataFile).getLines
        val Array(numRows, numCols) = lines.next.split("\\s+").map(_.toInt)
        lines.toList
             .map(line => {
                 val sv = SparseVector.zeros[Double](numCols)
                 for ( Array(c, v) <- line.split("\\s+").map(_.split(":")) )
                     sv(c.toInt) = v.toDouble
                 sv.t
        })
    }
}
