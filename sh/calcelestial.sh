git clone https://github.com/stv0g/calcelestial
cd calcelestial/
sh autogen.sh 
./configure
sudo apt -y install libcurl4-openssl-dev libjson-c-dev libnova-dev
make
sudo make install

