git clone https://github.com/stv0g/calcelestial
cd calcelestial/
sudo apt-get install -y libnova-dev libcurl4-openssl-dev libjson-c-dev libdb-dev autoconf make gcc pkg-config
autoreconf -i 
./configure 
sudo make install

