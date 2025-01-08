FROM ubuntu:24.04 AS builder

ARG ISO=https://archive.org/download/ut-goty/UT_GOTY_CD1.iso
ARG PATCH=https://github.com/OldUnreal/UnrealTournamentPatches/releases/download/v469e-rc4/OldUnreal-UTPatch469e-Linux-arm64.tar.bz2
ARG SKIP=https://github.com/OldUnreal/FullGameInstallers/raw/refs/heads/master/Windows/Installer/skip.txt
ARG SYSTEM_SUFFIX=ARM64

RUN mkdir storage

ADD ${ISO} /storage/
ADD ${PATCH} /storage/
ADD ${SKIP} /storage/

RUN mkdir Unreal && cd Unreal/

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Install Dependencies
RUN apt-get update && apt-get install -y \
    bzip2 \
    p7zip-full \
    libsdl2-2.0-0

RUN ls -lah /storage/

RUN 7z x -aoa -o/Unreal/ -x@/storage/$(basename ${SKIP}) /storage/$(basename ${ISO})

RUN tar vxf /storage/$(basename ${PATCH}) -C /Unreal/

# Set Environment Variables (if necessary)
ENV DEBIAN_FRONTEND=noninteractive

# Set Working Directory
WORKDIR /Unreal/System${SYSTEM_SUFFIX}

# Decompress all .uz files in ../Maps/
RUN UZS=$(find /Unreal/Maps/ -type f -name '*.uz') && \
    for uz in $UZS; do \
        echo "Decompressing $uz"; \
        /Unreal/System${SYSTEM_SUFFIX}/ucc-bin decompress "$uz"; \
    done

RUN mv /root/.utpg/System/*.unr /Unreal/Maps/

##############################

FROM ubuntu:24.04

ARG SYSTEM_SUFFIX=ARM64

RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Install Dependencies
#RUN apt-get update && apt-get install -y \
#    bzip2 \
#    p7zip-full \
#    libsdl2-2.0-0 && \
#    apt-get clean

COPY --from=builder /Unreal /Unreal
COPY --from=builder /root/.utpg /root/.utpg
COPY --from=builder /usr/lib/aarch64-linux-gnu /usr/lib/aarch64-linux-gnu

WORKDIR /root/.utpg/System/
RUN sed -i 's/^AdminPassword=.*/AdminPassword=qwerty123/' UnrealTournament.ini
RUN sed -i 's/^ServerName=.*/ServerName=vasylchenko.me UT Server/' UnrealTournament.ini
RUN sed -i 's/^ShortName=.*/ShortName=vasylchenko.me/' UnrealTournament.ini
RUN sed -i 's/^Difficulty=.*/Difficulty=5/' UnrealTournament.ini
RUN sed -i 's/^bEnabled=.*/bEnabled=True/' UnrealTournament.ini

RUN sed -i '/^\[Botpack\.DeathMatchPlus\]/a  \
BotSkill=5\n\
bNoviceMode=False\n\
MinPlayers=5\n\
AirControl=0.350000\n\
FragLimit=10\n\
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

#RUN sed -i '/^\[Engine\.GameEngine\]/a  \
#ServerPackages=MapVoteLA13' UnrealTournament.ini

# Set Working Directory
WORKDIR /Unreal/System${SYSTEM_SUFFIX}

EXPOSE 7777/udp 7778/udp
# Define ENTRYPOINT
#ENTRYPOINT ["./ucc-bin", "server", "DM-Barricade.unr", "log=server.log", "ini=../System/UnrealTournament.ini", "-nohomedir"]
ENTRYPOINT ["./ucc-bin", "server", "DM-Barricade.unr", "ini=/root/.utpg/System/UnrealTournament.ini", "-nohomedir"]

