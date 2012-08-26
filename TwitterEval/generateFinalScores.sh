#!/bin/bash

source ./config.sh

label=tweet-t
outLabel=twitter-t
segmentDat=$outLabel.segmentation.scores.dat
segmentTex=$outLabel.segmentation.scores.tex

if [ 0 != 0 ]; then
    echo "Already Run"
fi

# Run the initial evaluation which compares each segmentation algorithm against
# known event boundaries for each sport.  since each summarization method will
# have the same boundaries, we use just the boundaries listed in the mean
# summary output 
for sport in $keyWords; do
    for method in $methods; do
        error=`$run $base.EvaluateSegmentsAgainstEvents \
                    $resultDir/$label.$sport.$method.all.mean.summary.csv \
                    $resultDir/olympics.$sport.times.dat `
        echo $sport $method $error
    done
done > $resultDir/$segmentDat

# Convert that output to an easy to use tex tabular for presentation or paper
# usage.
$run $base.FormSegmentationTable \
    $resultDir/$segmentDat \
    false double > src/main/tex/$segmentTex

# Compute the amount of raw agreement between each summarization method using
# the same segmentation algorithm.
for pair in "mean-median" "mean-phrase" "median-phrase"; do
    m1=`echo $pair | cut -d "-" -f 1`
    m2=`echo $pair | cut -d "-" -f 2`
    for sport in $keyWords; do
        for method in $methods; do
            error=`$run $base.EvaluateSummaryOverlap \
                        $resultDir/$label.$sport.$method.all.$m1.summary.csv \
                        $resultDir/$label.$sport.$method.all.$m2.summary.csv`
            echo $sport $method $error
        done
    done > $resultDir/$outLabel.summary.$pair.dat

    $run $base.FormSegmentationTable \
        $resultDir/$outLabel.summary.$pair.dat \
        false double > src/main/tex/$outLabel.summary.$pair.tex
done

# Compute the percentage of duplicate summaries within each complete systems
# output.
for summary in mean median phrase; do
    for sport in $keyWords; do
        for method in $methods; do
            error=`$run $base.EvaluateSummaryDuplicates \
                        $resultDir/$label.$sport.$method.all.$summary.summary.csv`
            echo $sport $method $error
        done
    done > $resultDir/$outLabel.duplicate.$summary.dat

    $run $base.FormSegmentationTable \
        $resultDir/$outLabel.duplicate.$summary.dat \
        false double > src/main/tex/$outLabel.duplicate.summary.tex
done
