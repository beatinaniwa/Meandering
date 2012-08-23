#!/bin/bash

source ./config.sh

segmentDat=twitter.segmentation.scores.dat
segmentTex=twitter.segmentation.scores.tex

# Run the initial evaluation which compares each segmentation algorithm against
# known event boundaries for each sport.  since each summarization method will
# have the same boundaries, we use just the boundaries listed in the mean
# summary output 
for sport in $sports; do
    for method in $methods; do
        error=`$run $base.EvaluateSegmentsAgainstEvents \
                    results/tweet.$sport.$method.all.mean.summary.csv \
                    results/olympics.$sport.times.dat `
        echo $sport $method $error
    done
done > $resultsDir/$segmentDat

# Convert that output to an easy to use tex tabular for presentation or paper
# usage.
$run $base.FormSegmentationTable $resultsDir/$segmentDat > src/main/tex/$segmentTex
