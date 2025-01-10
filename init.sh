#!/usr/bin/env bash

echo "Replacing port by $PORT"
sed -i "s/^Port=.*/Port=$PORT/" /root/.utpg/System/UnrealTournament.ini

echo "Replacing admin password by env variable"
sed -i "s/^AdminPassword=.*/AdminPassword=$ADMIN_PASSWORD/" /root/.utpg/System/UnrealTournament.ini

echo "Replacing bChangeLevels by $MAP_AUTO_CHANGE"
sed -i "s/^bChangeLevels=.*/bChangeLevels=$MAP_AUTO_CHANGE/" /root/.utpg/System/UnrealTournament.ini

echo "Replacing server name by $SERVER_NAME"
sed -i "s/^ServerName=.*/ServerName=$SERVER_NAME/" /root/.utpg/System/UnrealTournament.ini
sed -i "s/^ShortName=.*/ShortName=$SERVER_NAME/" /root/.utpg/System/UnrealTournament.ini

echo "Replacing FragLimit by $FRAG_LIMIT"
sed -i "s/^FragLimit=.*/FragLimit=$FRAG_LIMIT/" /root/.utpg/System/UnrealTournament.ini

echo "Starting Server on port $PORT"
./ucc-bin server "$MAP?Game=Botpack.DeathMatchPlus?Mutator=MapVoteLA13.BDBMapVote" ini=/root/.utpg/System/UnrealTournament.ini -nohomedir