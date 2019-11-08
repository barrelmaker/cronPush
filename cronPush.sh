#!/bin/bash

# Gives a 50% chance that the crontab executes
if [ $(( ( RANDOM % 10 )  + 1 )) -le 6 ]; then
    exit 0
fi

# Goes to proper directory
cd
cd $HOME/Documents/Projects/cronPush

# Sets the Github username and email
git config --global user.name "barrelmaker"
git config --global user.email cooperleong0@gmail.com

# Creates a counter variable to keep track of the number of pushes,
# Will also be used to count the index of the words in the text file
CRON_PUSH_COUNTER=$(< $HOME/Documents/Projects/cronPush/cronPushCounter.txt)
CRON_PUSH_COUNTER=$((CRON_PUSH_COUNTER + 1))
echo $CRON_PUSH_COUNTER > $HOME/Documents/Projects/cronPush/cronPushCounter.txt
echo $CRON_PUSH_COUNTER

# Sets the variable CRON_PUSH_TIME to be the current time
CRON_PUSH_TIME=$(date)
echo $CRON_PUSH_TIME > $HOME/Documents/Projects/cronPush/cronPushTime.txt
echo $CRON_PUSH_TIME

# Gets the number of words in the text file
WORD_COUNT=$(wc -w <lorem.txt)

# If either there is no input text or the counter has pushed all the text
if ! [ -s lorem.txt ] || [ $CRON_PUSH_COUNTER -gt $WORD_COUNT ]; then
    echo "Text is empty or counter exceeded maximum word count"
    exit 0
fi

# Add a word to the current text file
cat lorem.txt | cut -d " " -f -$CRON_PUSH_COUNTER>loremPush.txt

# Setting the branch and repo variables
set -e
branch=$(git branch | sed -n -e 's/^\* \(.*\)/\1/p')
repo=$(basename -s .git `git config --get remote.origin.url`)

# Concatenates to the README.md
echo "### Push" $CRON_PUSH_COUNTER "on" $CRON_PUSH_TIME>> README.md 
cat loremPush.txt>>README.md

# Check which branch
if [ "$repo" == "cronPush" ] && [ "$branch" == "master" ]; then
    git add .
    git commit -m "Add push cron ssh private random to README"
    git push git@github.com:barrelmaker/cronPush.git
fi
