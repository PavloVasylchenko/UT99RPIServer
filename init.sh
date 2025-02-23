#!/usr/bin/env bash

#TARGET_FILE="${1:-}"

TARGET_FILE="./System/UnrealTournament.ini"

echo "Replacing port by $PORT"
sed -i "s/^Port=.*/Port=$PORT/" "$TARGET_FILE"

echo "Replacing admin password by env variable"
sed -i "s/^AdminPassword=.*/AdminPassword=$ADMIN_PASSWORD/" "$TARGET_FILE"

echo "Replacing bChangeLevels by $MAP_AUTO_CHANGE"
sed -i "s/^bChangeLevels=.*/bChangeLevels=$MAP_AUTO_CHANGE/" "$TARGET_FILE"

echo "Replacing server name by $SERVER_NAME"
sed -i "s/^ServerName=.*/ServerName=$SERVER_NAME/" "$TARGET_FILE"
sed -i "s/^ShortName=.*/ShortName=$SERVER_NAME/" "$TARGET_FILE"

echo "Replacing FragLimit by $FRAG_LIMIT"
sed -i "s/^FragLimit=.*/FragLimit=$FRAG_LIMIT/" "$TARGET_FILE"

set -euo pipefail

if [[ -z "$TARGET_FILE" ]]; then
  echo "Usage: $0 <target_file>"
  exit 1
fi

# 1. Replace existing parameters with values from $REPLACE_PROPS
if [[ -n "${REPLACE_PROPS:-}" ]]; then
  IFS=';' read -ra REPLACE_PAIRS <<< "$REPLACE_PROPS"
  for pair in "${REPLACE_PAIRS[@]}"; do
    varName="${pair%%=*}"
    varValue="${pair#*=}"
    # Replace lines of the form varName=anything with varName=varValue
    # If varName does not exist, sed won't find it and won't change anything
    sed -i "s|^${varName}=.*|${varName}=${varValue}|" "$TARGET_FILE"
  done
fi

# 2. Append new parameters from $APPEND_PROPS
if [[ -n "${APPEND_PROPS:-}" ]]; then
  IFS=';' read -ra APPEND_PAIRS <<< "$APPEND_PROPS"
  for pair in "${APPEND_PAIRS[@]}"; do
    varName="${pair%%=*}"
    varValue="${pair#*=}"
    # Only append if the parameter is NOT already in the file
    if ! grep -q "^${varName}=" "$TARGET_FILE"; then
      echo "${varName}=${varValue}" >> "$TARGET_FILE"
    fi
  done
fi

echo "Starting Server on port $PORT"
. "$(pwd)/unreal.env"
echo " Loading props $(pwd)/unreal.env"
echo "System folder is $SYSTEM_FOLDER"
export LD_LIBRARY_PATH="$(pwd)/libs:$(pwd)/libs/pulseaudio"
echo "Running ./$SYSTEM_FOLDER/ucc-bin server \"$MAP?Game=Botpack.DeathMatchPlus?Mutator=MapVoteLA13.BDBMapVote,relics.RelicStrength,relics.RelicSpeed,relics.RelicRegen,relics.RelicRedemption,relics.RelicDefense,relics.RelicDeath\" ini=../System/UnrealTournament.ini userini=../System/User.ini -nohomedir"
./$SYSTEM_FOLDER/ucc-bin server "$MAP?Game=Botpack.DeathMatchPlus?Mutator=MapVoteLA13.BDBMapVote,relics.RelicStrength,relics.RelicSpeed,relics.RelicRegen,relics.RelicRedemption,relics.RelicDefense,relics.RelicDeath" ini=../System/UnrealTournament.ini userini=../System/User.ini -nohomedir
