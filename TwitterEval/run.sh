#!/bin/bash

keyWords="gymnastics tennis archery judo fencing swimming"

run="scala -J-Xmx2g -cp target/TwitterEval-assembly-1.0.0.jar"
base="edu.ucla.sspace"
tokenizer=data/en-token.bin
englishFilter=data/classifier.nb.english-filter.json
featureModel=split
summariesPerDay=200
resultDir=results
trainingSize=500000

mkdir $resultDir

if [ 0 != 0 ]; then
    echo "Already Run"
# Extract the first N tweets from the list (this should be a large numbe up to
# the time when the olympics began).  Then use those tweets to build an
# unsupervised classifier that will filter out blatantly non-english tweets.
python src/main/python/PrintFirstNTweets.py $trainingSize > $resultDir/tweet.english-filter.train.txt
$run $base.TrainEnglishTweetFilter $resultDir/tweet.english-filter.train.txt $englishFilter 
fi

for word in $keyWords; do
    if [ 0 != 0 ]; then
        echo "skipped"

    echo "Extracting tweets for $word"
    # Extract the tweets for the word of interest.
    python src/main/python/PrintTaggedTweetText.py $word > $resultDir/tweet.$word.raw.txt

    echo "Filtering out non-english tweets using the unsupervised classifier"
    # Remove any non-english tweets as decided by the classifier trained on the
    # 500,000 tweets before the Olympic games officially started.
    $run $base.FilterEnglishTweets $englishFilter $resultDir/tweet.$word.raw.txt > $resultDir/tweet.$word.english.txt

    echo "Running the NER for $word"
    # Run Stanford's Named Entity Recognizer over the tweets.
    ./src/main/shell/NERTweets.sh $resultDir/tweet.$word.english.txt $resultDir/tweet.$word.full_tagged.txt

    echo "Extracting basis mappings for $word"
    # Extract the basis mappings for each tweet.
    $run $base.ExtractBasisLists $resultDir/tweet.$word.full_tagged.txt \
                                 $resultDir/tweet.$word.token_basis.dat \
                                 $resultDir/tweet.$word.ne_basis.dat

    echo "Split the tweets into day segments"
    # Split each tweet into days.  This part needs to be fixed/updated/replaced,
    # but sorta works well enough.
    $run $base.DaySplit $resultDir/tweet.$word.full_tagged.txt $resultDir/tweet.$word

    for part in $resultDir/tweet.$word.part.*.dat; do
        partId=`echo $part | cut -d "." -f 4`

        # Now batch cluster each part for the word using mean and median methods.
        for method in mean median; do
            echo "Clustering $word part $partId using $method"
            $run $base.BatchClusterTweets $part \
                                          $resultDir/tweet.$word.token_basis.dat \
                                          $resultDir/tweet.$word.ne_basis.dat \
                                          $summariesPerDay \
                                          $resultDir/tweet.$word.batch-$method.$partId.groups.dat \
                                          $resultDir/tweet.$word.batch-$method.$partId.summary.dat \
                                          $featureModel $method
        done

        # Run the particle filter over each of the partitions for each word.
        $run $base.ParticleFilterTweets $part \
                                        $resultDir/tweet.$word.token_basis.dat \
                                        $resultDir/tweet.$word.ne_basis.dat \
                                        $resultDir/tweet.$word.particle-mean.$partId.groups.dat \
                                        $resultDir/tweet.$word.particle-mean.$partId.summary.dat \
                                        $featureModel 
    done

    for part in $resultDir/tweet.$word.part.*.dat; do
        partId=`echo $part | cut -d "." -f 4`
        for method in batch-mean batch-median particle-mean; do
            for summary in mean median phrase; do
                $run $base.SummarizeTweets $featureModel \
                                           $resultDir/tweet.$word.token_basis.dat \
                                           $resultDir/tweet.$word.ne_basis.dat \
                                           $part \
                                           $resultDir/tweet.$word.$method.$partId.groups.dat \
                                           $resultDir/tweet.$word.$method.$partId.$summary.summary.dat \
                                           $summary
            done
        done
    done

    # For each clustering method, smash together all the parts into one large
    # group for the csv files.
    for method in batch-mean batch-median particle-mean; do
        $run $base.MergeDayGroupLists $resultDir/tweet.$word.$method.*.groups.dat > $resultDir/tweet.$word.$method.all.groups.csv
        for summary in mean median phrase; do
            $run $base.MergeDaySplitsLists $resultDir/tweet.$word.$method.*.$summary.summary.dat > $resultDir/tweet.$word.$method.all.$summary.summary.csv
        done
    done

    fi

    # Now do the processing using bayesian change point analysis.  This is
    # mostly done in R with other codes simply to munge the format into the
    # expected csv files.

    # First count the number of tweets per minute in the dataset.
    $run $base.MinuteCounter $resultDir/$tweet.$sport.english.txt \
                             $resultDir/tweet.$sport.minute-counts.dat
    # Next extract the change points for the minutes using bcp.
    R --no-restore --no-save --args \
        $resultDir/tweet.$sport.minute-counts.dat \
        $resultDir/tweet.$sport.bcp.mat < src/main/R/ComputeChangePoints.R
    # Fixup the format so that each datapoint is on it's own line.
    cat $resultDir/tweet.$sport.bcp.mat | tr " " "\n" > $resultDir/tweet.$sport.bcp.dat
    # Merge the minute-count data with the change point indicator values.
    paste $resultDir/tweet.$sport.minute-counts.dat \
          $resultDir/tweet.$sport.bcp.dat > $resultDir/tweet.$sport.bcp.splits.dat
    # Convert the changepoint values into group and summary csv files.  We do
    # this for each of the summary methods available.
    for summary in mean median phrase; do
        $run.$base.ProcessBcpSplits joint \
                                    $resultDir/tweet.$sport.token_basis.dat \
                                    $resultDir/tweet.$sport.ne_basis.dat \
                                    $resultDir/tweet.$sport.bcp.groups.dat \
                                    tweet.$sport.bcp.all.groups.csv \ 
                                    tweet.$sport.bcp.$summary.summary.csv \
                                    $summary \
                                    $resultDir/tweet.$sport.part.*.dat
    done
done
