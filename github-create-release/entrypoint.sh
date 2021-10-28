#!/bin/sh -l
echo "Draft: $DRAFT"
echo "Prerelease: $PRERELEASE"
echo "Generate_Release_Notes: $GENERATE_RELEASE_NOTES"
curl \
  -X POST \
  -H "Authorization: $TOKEN_NAME $PAT" \
  https://api.github.com/repos/$GITHUB_OWNER/$GITHUB_REPO/releases \
  -d '{"'"tag_name"'":"'"$TAG_NAME"'", "'"name"'":"'"$NAME"'", "'"body"'":"'"$BODY"'", "'"draft"'":'$DRAFT', "'"prerelease"'":'$PRERELEASE', "'"discussion_category_name"'":"'"$DISCUSSION_CATEGORY_NAME"'",
        "'"general_release_notes"'":'$GENERATE_RELEASE_NOTES'}'

  #"{\"tag_name\":\"$TAG_NAME\", \"name\":\"$NAME\", \"body\":\"$BODY\", \"draft\": \"'$DRAFT'\", \"prerelease\": \"'$PRERELEASE'\" , 
  #      \"discussion_category_name\":\"$DISCUSSION_CATEGORY_NAME\", \"general_release_notes\": \"'$GENERATE_RELEASE_NOTES'\"}" 

  