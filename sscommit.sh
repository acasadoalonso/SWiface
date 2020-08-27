rm *funcs.py 
cp /nfs/OGN/src/funcs/parserfuncs.py .
cp /nfs/OGN/src/funcs/ogntfuncs.py .
cp /nfs/OGN/src/funcs/ognddbfuncs.py .
cp /nfs/OGN/src/funcs/flarmfuncs.py .
git add .
git commit
git push origin master
git push glidernet master
