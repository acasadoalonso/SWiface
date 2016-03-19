sudo mount casadonfs:/nfs/NFS/Backups /bkups
sudo mount casadoix2:/nfs/Backups /mnt
rsync -ruqHL --exclude=".AppleDouble/" /mnt/ /bkups/ &
