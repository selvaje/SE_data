ls
ls 
cd
ls
ls ost4sem/
ls ost4sem/grassdb/
ls ost4sem/grassdb/europe/
exit
v.in.ogr
v.in.ogr -e dsn=/home/user/ost4sem/project/vect_ste/raw_data/curve.shp output=curvelivel --o location=Floods
d.mon start=x2
d.vect curvelivel
g.mapset mapset=Floods
g.gisenv
g.list vect
exit
g.region -p
g.region -p
