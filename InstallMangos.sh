

cd "/sources/build"

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

rm -rf /sources/build 
