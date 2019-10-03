

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
  cp -a /sources/build/contrib/extractor/ad /mangos
  cp -a /sources/build/contrib/mmap/MoveMapGen /mangos
  cp -a /sources/build/contrib/vmap_assembler/vmap_assembler /mangos
  cp -a /sources/build/contrib/vmap_extractor/vmapextract/vmap_extractor /mangos
  cp -a /sources/build/contrib/extractor_scripts /mangos
  cp -a /sources/build/src/mangosd/mangosd /mangos
  cp -a /sources/build/src/realmd/realmd /mangos

rm -rf /sources 
