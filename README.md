# UT99RPIServer
Docker image for Unreal Tournament 99 Game Server for Raspberry Pi

Depending on platform releases can be found here:
https://github.com/OldUnreal/UnrealTournamentPatches/releases/

# Build image Raspberry Pi or arm

```
docker build -t ut99:latest .
docker build --progress=plain -t ut99:latest .
```

# Build image Linux amd64 (x64_86)

```
docker build -t ut99:latest \
 --build-arg PATCH=https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469e-rc7/OldUnreal-UTPatch469e-Linux-amd64.tar.bz2 \
 .
```

# Run Server
```
# Default run
docker run -d -p 7777:7777/udp -p 7778:7778/udp ut99
# Default + Web Admin on port 8080
docker run -d -p 7777:7777/udp -p 7778:7778/udp -p 8080:8080 -e ADMIN_PASSWORD=qwerty123 ut99
# Default + DM-Fractal map
docker run -d -p 7777:7777/udp -p 7778:7778/udp -e MAP="DM-Fractal.unr" -e FRAG_LIMIT=15 ut99
# Default + Different, 8888 port
docker run -d -p 8888:8888/udp -p 8889:8889/udp -e PORT=8888 ut99
...
ENV VARIABLES:
PORT=7777
ADMIN_PASSWORD=qwerty123
GAME_PASSWORD=
MAP=DM-Barricade.unr
MUTATORS=
MAP_AUTO_CHANGE=True
SERVER_NAME="Server Name"
FRAG_LIMIT=10
REPLACE_PROPS="PROP1=VAL1;PROP2=VAL2"
APPEND_PROPS="PROP10=VAL10;PROP20=VAL20"
```

# Debug
```
docker run -it --rm -p 7777:7777/udp -p 7778:7778/udp --entrypoint bash ut99
```
# In Game
```
mutate bdbmapvote votemenu
```
