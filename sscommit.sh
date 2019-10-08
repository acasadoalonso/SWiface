rm *funcs.py kglid.py 
cp /nfs/OGN/src/funcs/parserfuncs.py .
cp /nfs/OGN/src/funcs/ogntfuncs.py .
cp /nfs/OGN/src/kglid.py .
git add .
git commit
git push origin master
git push glidernet master
