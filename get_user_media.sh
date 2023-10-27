#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <Instagram Username> <Bussiness id> <Access Token>"
  exit 1
fi

username="$1"
bussiness_id="$2"
access_token="$3"

media_url="https://graph.facebook.com/v18.0/${bussiness_id}?fields=business_discovery.username(${username})%7Bfollowers_count,media_count,media.limit%281000%29%7Bcaption,media_url,permalink,timestamp,username,children%7Bmedia_url%7D%7D%7D&access_token=${access_token}"

response=$(curl -s "$media_url")
echo $response
if [ -z "$response" ]; then
  echo "Failed to fetch media data. Please check your access token or try again later."
  exit 1
fi

media_data=$(echo "$response" | jq -r '.business_discovery.media.data')
if [ -z "$media_data" ]; then
  echo "No media found for the specified user."
  exit 1
fi

mkdir -p downloads

for row in $(echo "$media_data" | jq -c '.[]'); do
  media_url=$(echo "$row" | jq -r '.media_url')
  media_id=$(echo "$row" | jq -r '.id')
  file_name="downloads/${media_id}.jpg"

  curl -s -o "$file_name" "$media_url"
  echo "Downloaded: $file_name"
done

echo "Download completed."
