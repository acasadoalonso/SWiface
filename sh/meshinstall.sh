#! /bin/sh
# Install and uninstall the mesh agent
case "$1" in
  install)
    echo "Installing mesh agent for mesh Ángel"
    mkdir /usr/local/mesh
    wget -nv http://meshcentral.com/public/dh.ashx?mesh=F433C13F1F90B5176498D5C55A8535C29B01C408656D810999C535011637B8FD -O /usr/local/mesh/mesh_arm.msh
    wget -nv http://meshcentral.com/public/dh.ashx?agent=10 -O /usr/local/mesh/mesh_arm
    wget -nv http://meshcentral.com/public/dh.ashx?request=initdscript -O /etc/init.d/mesh
    chmod 755 /usr/local/mesh/mesh_arm
    chmod 755 /etc/init.d/mesh
    update-rc.d mesh defaults
    /usr/local/mesh/mesh_arm start
    ;;
  remove)
    echo "Removing the mesh agent"
    /usr/local/mesh/mesh_arm stop
    rm -f /usr/local/mesh/mesh_arm*
    rmdir /usr/local/mesh
    update-rc.d -f mesh remove
    rm /etc/init.d/mesh
    ;;
  *)
    echo "Usage: sudo ./meshinstall {install|remove}"
    exit 1
    ;;
esac
exit 0

