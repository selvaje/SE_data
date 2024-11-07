ls
exit
man r.info
g.manual -i
 g.gisenv
ls
pwd
cd ~/ost4sem/grassdb/europe/
man g.mapset
g.mapset -l
g.mapset mapset=PCEM
g.gisenv
g.list type=vect
g.list type=rast
g.list vect
g.list type=rast
g.mapsets addmapset=Vmodel
g.list type=rast
ls
ls Vmodel/
ls Vmodel/cellhd/
g.mapsets -l
g.gisenv
g.list type=rast
g.copy rast=potveg_ita@Vmodel,pvegita 
g.list rast
g.remove rast=pvegita
  g.remove rast=potveg_europe@Vmodel
g.remove rast=potveg_europe
g.list rast
g.region -p
g.region -d
g.region -p
g.region n=6015390 e=5676400 s=3303955 w=3876180 res=1000 save=scandinavia --overwrite
g.region -p
g.region n=6015390 e=5676400 s=3303955 w=3876180 res=1000 save=scandinavia --overwrite
qgis &
g.region -d
ls PERMANENT/windows/ 
pwd
ls */windows/ 
more Vmodel/windows/italy 
g.region italy@Vmodel
g.region italy@Vmodel -p
g.region res=20000 -p
g.region italy@Vmodel -p
g.region res=20000 -p
r.mapcalc fnfpc_italy20k = fnfpc 
g.region alpine@PCEMstat res=10000 -p
r.mapcalc fnfpc_alpine10k = fnfpc 
g.region alp_car@PCEM res=5000 -p
r.mapcalc fnfpc_alpine_carpatien5k = fnfpc 
exti
extit
exit
man r.info
g.mapset -p 
g.mapset
g.mapset -l 
g.region -p 
g.region -p 
g.region -p | grep west
g.region -p | grep west | awk '{  print $2   }' 
g.region -p 
g.region -p | awk '{ if (NR==7) print $2 }' 
g.gui tcltk 
g.gui tcltk &
g.region -d 
exit
d.mon -l
g.region rast=fnfpc
g.region -p
qgis &
ls
ls ost4sem/
ls ost4sem/studycase/
ls ost4sem/studycase/ITA_veg/
ls ost4sem/studycase/ITA_veg/Bohn_nat_veg/
ls -l ost4sem/studycase/ITA_veg/Bohn_nat_veg/
ls -l ost4sem/studycase/ITA_veg/Bohn_nat_veg/bon18a
d.mon start=x0
d.rast fnfpc
d.mon start=x1
d.rast fnfpc_alpine10k 
g.region rast=fnfpc_alpine10k 
d.mon start=x1
d.rast fnfpc_alpine10k
g.region rast=fnfpc_alpine_carpatien5k
d.mon start=x3
d.rast fnfpc_alpine_carpatien5k
g.region italy@Vmodel -p 
exit
g.region italy@Vmodel -p 
# 
# we see that the Italian g.region has 1km res and 1500 x 1140 pixels
# 
# We now resample the g.region at 20km using the res=new_res option
g.region res=20000 -p # we have now 75 x 57 pixels of 20k resolution
# 
# we can create a new forest non forest map with the new extent and resolution using r.mapcalc function r.mapcalc details
r.mapcalc fnfpc_italy20k = fnfpc 
# 
# Now create the two other maps:
g.region alpine@PCEMstat res=10000 -p
r.mapcalc fnfpc_alpine10k = fnfpc 
g.region alp_car@PCEM res=5000 -p
r.mapcalc fnfpc_alpine_carpatien5k = fnfpc 
# 
# You can save a new extent and resolution as g.mapset with the save=name_new_ option
g.list rast
g.region rast=fnfpc res=50000
d.mon start=x5
d.rast fnfpc
g.copy rast=fnfpc,eu1 
g.copy rast=fnfpc_alpine_carpatien5k,ac5 
g.copy rast=fnfpc_alpine10k,a10
g.copy rast=fnfpc_italy20k,i20
g.list rast
g.remove rast=fnfpc_alpine_carpatien5k
g.remove rast=fnfpc_alpine10k
g.remove rast=fnfpc_italy20k
g.list rast
man cat
cat ~/ost4sem/exercise/basic_adv_grass/green_palett_5class
more ~/ost4sem/exercise/basic_adv_grass/green_palett_5class
kate ~/ost4sem/exercise/basic_adv_grass/green_palett_5class
man r.colors
for map in a10 ac5 eu1 i20 ; do  g.region rast=$map # setting the region;  cat ~/ost4sem/exercise/basic_adv_grass/green_palett_5class |r.colors map=$map  color=rules ;  d.mon start=PNG ;     d.rast $map ;     d.vect map=EUcountry@EUforest fcolor="none" color=red;  d.mon stop=PNG;  mv  map.png ~/ost4sem/exercise/basic_adv_grass/output_map_$map; done
ls ~/ost4sem/exercise/basic_adv_grass/
F-spot ~/ost4sem/exercise/basic_adv_grass/ 
f-spot ~/ost4sem/exercise/basic_adv_grass/output_map_a10 
display ~/ost4sem/exercise/basic_adv_grass/output_map_a10 
display ~/ost4sem/exercise/basic_adv_grass/output_map_a10 &
display ~/ost4sem/exercise/basic_adv_grass/output_map_eu1 &
display ~/ost4sem/exercise/basic_adv_grass/output_map_i20 &
cd ~/ost4sem/exercise/basic_adv_grass/output_map_i20 &
cd ~/ost4sem/exercise/basic_adv_grass/
pwd
ls
convert output_map_eu1 outtry.jpg
display outtry.jpg
for map in a10 ac5 eu1 i20 ; do  g.region rast=$map # setting the region;  cat ~/ost4sem/exercise/basic_adv_grass/green_palett_5class |r.colors map=$map  color=rules ;  d.mon start=PNG ;     d.rast $map ;     d.vect map=EUcountry@EUforest fcolor="none" color=red;  d.mon stop=PNG;  mv  map.png ~/ost4sem/exercise/basic_adv_grass/output_map_$map.png; done
ls
ls -l
rm *output_map
ls *output_map
ls
ls output_map_???
ls -l
ls output_map_???
ls output_map_???.png
ls output_map_???
rm output_map_???
ls -l
exit
exit
echo $GIS_LOCK
g.list
g.list rast
R
exit
R
exit
qgis
qgis
exit
R
exit
qgis
R
R
exit
exit
g.list rast 
qgis
exit
qgis
exit
