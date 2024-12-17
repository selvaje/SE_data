test -r ~/.alias && . ~/.alias
PS1='GRASS $_GRASS_DB_PLACE:\W > '
grass_prompt() {
    MAPSET_PATH="`g.gisenv get=GISDBASE,LOCATION_NAME,MAPSET separator='/'`"
    _GRASS_DB_PLACE="`g.gisenv get=LOCATION_NAME,MAPSET separator='/'`"
    
    if [ "$_grass_old_mapset" != "$MAPSET_PATH" ] ; then
        history -a
        history -c
        HISTFILE="$MAPSET_PATH/.bash_history"
        history -r
        _grass_old_mapset="$MAPSET_PATH"
    fi
    
    if test -f "$MAPSET_PATH/cell/MASK" && test -d "$MAPSET_PATH/grid3/RASTER3D_MASK" ; then
        echo "[2D and 3D raster MASKs present]"
    elif test -f "$MAPSET_PATH/cell/MASK" ; then
        echo "[Raster MASK present]"
    elif test -d "$MAPSET_PATH/grid3/RASTER3D_MASK" ; then
        echo "[3D raster MASK present]"
    fi
}
PROMPT_COMMAND=grass_prompt
export HOME="/home/selv"
export PATH="/usr/lib/grass84/bin:/usr/lib/grass84/scripts:/home/selv/.grass8/addons/bin:/home/selv/.grass8/addons/scripts:/home/selv/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/selv/julia-1.9.3/bin"
trap "exit" TERM
