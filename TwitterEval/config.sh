#!/bin/bash

keyWords="gymnastics tennis archery judo fencing"
methods="batch-mean batch-median particle-mean bcp"

run="scala -J-Xmx2g -cp target/TwitterEval-assembly-1.0.0.jar"
base="edu.ucla.sspace"
tokenizer=data/en-token.bin
englishFilter=data/classifier.nb.english-filter.json
featureModel=split
summariesPerDay=200
resultDir=results
trainingSize=500000
