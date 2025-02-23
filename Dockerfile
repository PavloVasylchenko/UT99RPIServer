FROM ubuntu:24.04 AS builder

# Specifies the path to the ISO file to be used.
ARG ISO=https://archive.org/download/ut-goty/UT_GOTY_CD1.iso
# Specifies the path to the patch version file.
ARG PATCH=https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469e-rc7/OldUnreal-UTPatch469e-Linux-arm64.tar.bz2
# List of files and directories within the ISO file to be ignored (filtered) during the unpacking process.
ARG SKIP=https://github.com/OldUnreal/FullGameInstallers/raw/refs/heads/master/Windows/Installer/skip.txt
# URL to the MapVote mutator that will be enabled by default, allowing players to vote for the next map.
ARG MAPVOTE=https://unreal-archive-files.eu-central-1.linodeobjects.com/Unreal%20Tournament/Mutators/M/8/8/c441c8/MapvoteLA13.zip
# Game folder
ARG UNREAL=/Unreal

RUN mkdir storage

# Downloading files required for building the image.
ADD ${ISO} /storage/
ADD ${PATCH} /storage/
ADD ${SKIP} /storage/
ADD ${MAPVOTE} /storage/

RUN mkdir ${UNREAL} && cd ${UNREAL}

# Specifies the time zone required for installing libsdl2-2.0-0.
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Installs dependencies for unpacking archives and graphics libraries required to run the game.
RUN apt-get update && apt-get install -y \
    bzip2 \
    p7zip-full \
    libsdl2-2.0-0

# Unpacks the contents of the ISO file, using a skip list to filter only the required files.
RUN 7z x -aoa -o/Unreal/ -x@/storage/$(basename ${SKIP}) /storage/$(basename ${ISO})
# Unpacks the MapVote mutator files.
RUN 7z x -aoa -o/storage/ /storage/$(basename ${MAPVOTE})
# Unpacks the patch file.
RUN tar vxf /storage/$(basename ${PATCH}) -C /Unreal/
# Prints the result to the console.
RUN ls -lah /storage/

# Set Environment Variables (if necessary)
ENV DEBIAN_FRONTEND=noninteractive
############################################# SYSTEM FOLDER ##########################################################################################
WORKDIR ${UNREAL}
RUN echo "ARCH=$(uname -m)" > unreal.env && echo "SYSTEM_FOLDER=$( [ $(uname -m) = 'x86_64' ] && echo 'System64' || [ $(uname -m) = 'aarch64' ] && echo 'SystemARM64' || echo 'System' )" >> unreal.env
RUN . $(pwd)/unreal.env && \
    mkdir libs && \
    cp -r /usr/lib/$(uname -m)-linux-gnu/* ${UNREAL}/libs/

# List of required libraries, we copy just all available to make things simpler

# libFLAC.so.12
# libLLVM.so.19.1
# libSDL2-2.0.so.0
# libX11-xcb.so.1
# libX11.so.6
# libXau.so.6
# libXcursor.so.1
# libXdmcp.so.6
# libXext.so.6
# libXfixes.so.3
# libXi.so.6
# libXrandr.so.2
# libXrender.so.1
# libXss.so.1
# libapparmor.so.1
# libasound.so.2
# libasyncns.so.0
# libbsd.so.0
# libdbus-1.so.3
# libdecor-0.so.0
# libdrm.so.2
# libdrm_amdgpu.so.1
# libdrm_radeon.so.1
# libedit.so.2
# libelf.so.1
# libexpat.so.1
# libgallium-24.2.8-1ubuntu1~24.04.1.so
# libgbm.so.1
# libglapi.so.0
# libicudata.so.74
# libicuuc.so.74
# libmp3lame.so.0
# libmpg123.so.0
# libogg.so.0
# libopus.so.0
# libpulse.so.0
# libpulsecommon-16.1.so
# libsamplerate.so.0
# libsensors.so.5
# libsndfile.so.1
# libvorbis.so.0
# libvorbisenc.so.2
# libwayland-client.so.0
# libwayland-cursor.so.0
# libwayland-egl.so.1
# libwayland-server.so.0
# libxcb-dri2.so.0
# libxcb-dri3.so.0
# libxcb-present.so.0
# libxcb-randr.so.0
# libxcb-sync.so.1
# libxcb-xfixes.so.0
# libxcb.so.1
# libxkbcommon.so.0
# libxml2.so.2
# libxshmfence.so.1

############################################# END SYSTEM FOLDER ######################################################################################
############################################# DECOMPRESS MAPS AND REMOVE COMPRESSED FILES ############################################################
# Set Working Directory
WORKDIR ${UNREAL}

# Decompress all .uz files in ./Maps/
RUN . ${UNREAL}/unreal.env && \
    UZS=$(find ./Maps/ -type f -name '*.uz') && \
    for uz in $UZS; do \
        echo "Decompressing $uz"; \
        ./$SYSTEM_FOLDER/ucc-bin decompress "../Maps/$(basename $uz)" -nohomedir; \
    done

# Removes compressed files after decompression.
RUN . ${UNREAL}/unreal.env && \
    mv ./$SYSTEM_FOLDER/*.unr ./Maps/

# Removes compressed files after decompression.
RUN find ./Maps/ -type f -name '*.uz' | xargs rm
############################################# END DECOMPRESS MAPS AND REMOVE COMPRESSED FILES ########################################################

############################################# SET PROPERTY FILE VALUES ###############################################################################
# Set Working Directory
WORKDIR ${UNREAL}/System

RUN sed -i 's/^AdminPassword=.*/AdminPassword=qwerty123/' UnrealTournament.ini
RUN sed -i 's/^ServerName=.*/ServerName=vasylchenko.me UT Server/' UnrealTournament.ini
RUN sed -i 's/^ShortName=.*/ShortName=vasylchenko.me/' UnrealTournament.ini
RUN sed -i 's/^Difficulty=.*/Difficulty=5/' UnrealTournament.ini
RUN sed -i 's/^Difficulty=.*/Difficulty=5/' User.ini
RUN sed -i 's/^bEnabled=.*/bEnabled=True/' UnrealTournament.ini

RUN sed -i '/^\[Botpack\.DeathMatchPlus\]/a  \
BotSkill=5\n\
bNoviceMode=False\n\
MinPlayers=6\n\
AirControl=0.350000\n\
FragLimit=30\n\
TimeLimit=0\n\
bChangeLevels=True\n\
bMegaSpeed=False\n\
bAltScoring=False\n\
bMultiWeaponStay=True\n\
bForceRespawn=False\n\
bTournament=False\n\
NetWait=10\n\
RestartWait=15\n\
MaxCommanders=0\n\
InitialBots=4\n\
bSimulateKickers=True\n\
bNoMonsters=False\n\
bHumansOnly=False\n\
bClassicDeathMessages=False\n\
MinFOV=80.000000\n\
MaxFOV=130.000000\n\
MaxNameChanges=0\n\
bFixMultiWeaponBug=True\n\
bFixFeignDeathZoomBug=True' UnrealTournament.ini

RUN sed -i '/^\[Engine\.GameEngine\]/a  \
ServerPackages=MapVoteLA13' UnrealTournament.ini

RUN echo "\n\
[IpServer.UdpServerUplink]\n\
DoUplink=True\n\
MasterServerAddress=master.333networks.com\n\
MasterServerPort=27900\n\
" >> UnrealTournament.ini
############################################# END SET PROPERTY FILE VALUES ###########################################################################

# Uses a new image to avoid storing unnecessary libraries and data.
FROM ubuntu:24.04

ARG UNREAL=/Unreal

ENV PORT=7777
ENV ADMIN_PASSWORD=qwerty123
ENV GAME_PASSWORD=""
ENV MAP=DM-Barricade.unr
ENV MUTATORS=""
ENV MAP_AUTO_CHANGE=True
ENV SERVER_NAME="UT99 vasylchenko.me"
ENV FRAG_LIMIT=30
ENV REPLACE_PROPS=""
ENV APPEND_PROPS=""

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Copies data from the previous image.
COPY --from=builder /Unreal /Unreal
COPY --from=builder /storage/System/ /Unreal/System/

# Set Working Directory
WORKDIR ${UNREAL}

COPY ./init.sh ${UNREAL}/

RUN chmod +x ${UNREAL}/init.sh

EXPOSE 7777/udp 7778/udp
# Define ENTRYPOINT
#ENTRYPOINT ["./ucc-bin", "server", "DM-Barricade.unr?Game=Botpack.DeathMatchPlus?Mutator=MapVoteLA13.BDBMapVote", "ini=/root/.utpg/System/UnrealTournament.ini", "-nohomedir"]
ENTRYPOINT ["./init.sh"]
