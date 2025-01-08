# UT99RPIServer
Docker image for Unreal Tournament 99 Game Server for Raspberry Pi

# Build image
docker build --progress=plain -t ut99:latest .

# Run Server
docker run -it --rm -p 7777:7777/udp -p 7778:7778/udp ut99

# Debug
docker run -it --rm -p 7777:7777/udp -p 7778:7778/udp --entrypoint bash ut99

# In Game
mutate bdbmapvote votemenu