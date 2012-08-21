package edu.ucla.sspace

import VectorUtil._
import graphical.SphericalGaussianRasmussen
import graphical.gibbs.FiniteSphericalGaussianMixtureModel

import scala.math.pow


object Induce {
    def main(args: Array[String]) {
        val data = loadSparseData(args(0))
        val nTrials = args(1).toInt
        val alpha = args(2).toDouble
        val k = args(3).toInt
        val mu = data.reduce(_+_).toDense / data.size
        val variance = data.map(_-mu).map(_.norm(2)).map(pow(_, 2)).sum / data.size
        println(variance)
        val generator = new SphericalGaussianRasmussen(mu, variance)
        val learner = new FiniteSphericalGaussianMixtureModel(nTrials, alpha, generator) 
        val assignments = learner.train(data, k)
        assignments.foreach(println)
    }
}
