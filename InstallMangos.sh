

cd "/sources/build"

  cmake .. -DCMAKE_INSTALL_PREFIX="/mangos" -DDEBUG=0 -DBUILD_EXTRACTORS=ON -DPCH=1 -DBUILD_PLAYERBOT=ON -DBUILD_IMMERSIVE=OFF && \
  make

mkdir /mangos
  cp -a /sources/build/src/mangosd/mangosd /mangos
  cp -a /sources/build/src/realmd/realmd /mangos

rm -rf /sources/build 
