package edu.ucla.sspace

import scala.xml.XML

object ParseRawSemEval {
    def main(args: Array[String]) {
        val root = XML.loadFile(args(0))
        for (elements <- root.child)
            println(elements.text.toLowerCase.trim)
    }
}
