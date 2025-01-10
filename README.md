# UT99RPIServer
Docker image for Unreal Tournament 99 Game Server for Raspberry Pi

# Build image
```
docker build --progress=plain -t ut99:latest .
```
# Run Server
```
docker run -it --rm -p 7777:7777/udp -p 7778:7778/udp ut99
docker run -it --rm -p 7777:7777/udp -p 7778:7778/udp -e MAP="DM-Fractal.unr" -e FRAG_LIMIT=15 ut99
docker run -it --rm -p 8888:8888/udp -p 8889:8889/udp -e PORT=8888 ut99
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
