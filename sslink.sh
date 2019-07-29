rm *funcs.py
rm kglid.py 
for f in $(ls -ctr /nfs/OGN/src/*funcs.py ); do
                echo "Processing file:" $f
                ln -s $f .
done
ln -s /nfs/OGN/src/kglid.py .
ls -la *funcs.py kglid.py 
