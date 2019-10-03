

  cd "/sources/build"


P_SOAP="0"
P_DEBUG="0"
P_STD_MALLOC="1"
P_ACE_EXTERNAL="1"
P_PGRESQL="0"
P_TOOLS="1"
P_SD3="1"
P_ELUNA="1"
P_BOTS="1"

  cmake .. -DCMAKE_INSTALL_PREFIX="/mangos" -DDEBUG=0 -DBUILD_EXTRACTORS=ON -DPCH=1 -DBUILD_PLAYERBOT=ON -DBUILD_IMMERSIVE=OFF && \
  make

mkdir /mangos
cp /sources/linux/src/tools/Extractor_projects/Movemap-Generator/movemap-generator /mangos
cp /sources/linux/src/tools/Extractor_projects/map-extractor/map-extractor /mangos
cp /sources/linux/src/tools/Extractor_projects/vmap-extractor/vmap-extractor /mangos
cp /sources/linux/src/mangosd/mangosd /mangos
cp /sources/linux/src/realmd/realmd /mangos

rm -rf /sources 
