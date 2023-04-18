##### create output dir 
mkdir -p output1   output2 output3 


#########Solution 1 #########*

rm -f output1/*.txt

# Creates a txt file with the list of all uniq dates

awk -F , '{ if(NF>5) { if ($1 > 0) { print $1 }}}'  US_00090*.mon  | sort | uniq > output1/dates.txt

# Creates a txt file with the list of all uniq station ID, longitude, latitude. 

paste -d " " <(grep gsim.no   US_00090*.mon | awk '{print $4}') \
             <(grep longitude US_00090*.mon | awk '{print $4}') \
             <(grep latitude  US_00090*.mon | awk '{print $4}') | sort -k 1,1 > output1/ID_x_y.txt

## loop trought the dates.txt 

for DATE in $(cat output1/dates.txt ) ; do 
echo processing $DATE

grep ^$DATE US_00090*.mon  | awk '{ gsub(":"," "); gsub(","," ");if($3!="NA"){print substr($1,1,10),$3}}' | sort -k 1,1 > output1/${DATE}_ID_mean.txt 

join -1 1 -2 1 output1/ID_x_y.txt output1/${DATE}_ID_mean.txt  > output1/${DATE}_ID_x_y_mean.txt
rm output1/${DATE}_ID_mean.txt 

done 

#########Solution 2 #########

rm -f output2/*.txt 
#loop over all US files
n=0
for i in US_00090*.mon ; do
#pull out information of interest
gsim=$(awk 'NR==11 {print $4}' $i)
lat=$(awk 'NR==15 {print $4}' $i)
long=$(awk 'NR==16 {print $4}' $i)

#make new directory with name of gsim ID to store txt files in
mkdir $output$gsim

#awk uses these and spits out txt files named by the date
n=$(expr $n + 1)
echo $gsim $n

awk -v gsim=$gsim -v lat=$lat -v long=$long -v output=$output \
' NR>22 {gsub(","," "); if($2!="NA"){print gsim,long,lat,$2 >> "output2/"$1"_ID_x_y_mean.txt"}}' $i

rm -r $gsim
done


#########Solution 3 #########
rm -f output3/*.txt

awk '{gsub(",", "");
     gsub("\t", " ");
     if($2=="gsim.no")   {station=$4};
     if($2=="latitude")  {lat=$4};
     if($2=="longitude") {lon=$4};
     if($1 ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/ && $2!="NA" )
     { print station, lat , lon , $2 >  "output3/"substr($1,1,7)"_ID_x_y_mean.txt" }
}' US_00090*.mon 


exit
    
