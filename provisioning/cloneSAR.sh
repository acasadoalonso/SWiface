#!/bin/bash
rm html
sudo rm -r public
git clone https://github.com/acasadoalonso/RepoOGN-CGI-BIN-files.git         public
git clone https://github.com/acasadoalonso/RepoOGN-DataGatheringPart.git     public/main
ln -s public html
ls -la
