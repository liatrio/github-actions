#!/bin/sh -l


curl \
  -X POST \
  -H "Authorization: $TOKEN_NAME $PAT" \
  https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases \
  -d "{\"tag_name\":\"$TAG_NAME\", \"name\":\"$NAME\", \"body\":\"$BODY\", \"draft\": $DRAFT, \"prerelease\": $PRERELEASE , 
        \"discussion_category_name\":\"$DISCUSSION_CATEGORY_NAME\", \"general_release_notes\": $GENERAL_RELEASE_NOTES}" \
  --fail

  