#!/bin/bash

# Git Setting
echo "Git Setting: Start"
git config --global user.name "${ACCOUNT_ID}"
git config --global user.email "${EMAIL_ADDRESS}"
git remote set-url origin https://${ACCOUNT_ID}:${GITHUB_TOKEN}@github.com/${ACCOUNT_ID}/${PROJECT_NAME}.git
git checkout -b master
echo "Git Setting: Finished"

# Download Json
echo "Download Json: Start"
rm -v ./data/*
JSON_RESPONSE=$(curl "https://xxxxxxxxxx.microcms.io/api/v1/posts" -H "X-API-KEY: ${MICROCMS_API_KEY}")
CONTENTS_LENGTH=$(echo $JSON_RESPONSE | jq ".totalCount")
for j in $( seq 0 $(($CONTENTS_LENGTH - 1)) ); do
  row=$(echo $JSON_RESPONSE | jq .contents[$j] -r )
  slug=$(echo $JSON_RESPONSE | jq .contents[$j].slug -r )
  echo $row > ./data/$slug.json
  echo "Download: ./data/$slug.json"
done
echo "Download Json: Finished"

# Check Update
echo "Check Update: Start"
DIFF_FILES=$(git status -s ./data | wc -l)
if [ $DIFF_FILES -gt 0 ] ; then
  git add ./data
  DATE=$(date "+%Y/%m/%d-%H:%M:%S")
  git commit -m '[AutoBackup] microCMS update. DATE:'$DATE
  git push origin HEAD
  echo "Check Update: Update $DIFF_FILES Files."
else
  echo "Check Update: Nothing Updated."
fi
echo "Check Update: Finished"
