echo $TRAVIS_BRANCH
echo $TRAVIS_BUILD_DIR
echo $TRAVIS_BUILD_ID
echo $TRAVIS_BUILD_NUMBER
echo $TRAVIS_COMMIT
echo $TRAVIS_COMMIT_RANGE
echo $TRAVIS_JOB_ID
echo $TRAVIS_JOB_NUMBER
echo $TRAVIS_PULL_REQUEST
echo $TRAVIS_SECURE_ENV_VARS
echo $TRAVIS_REPO_SLUG

if [ "$TRAVIS_PULL_REQUEST" == "false" ]; then
    echo -e "Starting to update gh-pages\n"

    #copy data we're interested in to other place
    # cp -R coverage $HOME/coverage
    mkdir -p $HOME/$TRAVIS_BUILD_NUMBER
    cp -f output.xml log.html report.html $HOME/$TRAVIS_BUILD_NUMBER

    result=`grep "All Test" output.xml`
    nOfPass=${result##*pass=\"}
    nOfPass=${nOfPass%%\"*}

    nOfFail=${result##*fail=\"}
    nOfFail=${nOfFail%%\"*}

    #go to home and setup git
    # echo $HOME
    cd $HOME

    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis"

    #using token clone gh-pages branch
    git clone --quiet --branch=gh-pages https://${GH_TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git gh-pages > /dev/null

    #go into diractory and copy data we're interested in to that directory
    cd gh-pages
    echo -e "$TRAVIS_BUILD_NUMBER\t$nOfPass\t$nOfFail" >> summary.csv
    cp -rf $HOME/$TRAVIS_BUILD_NUMBER .

    #add, commit and push files
    git add -f .
    git commit -m "Travis build $TRAVIS_BUILD_NUMBER pushed to gh-pages"
    git push -fq origin gh-pages > /dev/null

    echo -e "Done...\n"
fi
