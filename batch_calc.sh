mkdir optimized_confs


cat << EOF > ./command.sh
echo " > Running conformer search"
mkdir -p 0.crest
cp FILENAMEFILENAME.xyz 0.crest
cd 0.crest
crest FILENAMEFILENAME.xyz -zs --gfn2 -T 4 > out

#sorting…
#(ocio: gli ho detto di bypassare i check topologici,
#controlla che esca roba giusta!)
echo " > Sorting conformers"
crest crest_best.xyz --cregen crest_conformers.xyz --notopo >> out
echo " > Pruning"
crest --screen crest_ensemble.xyz >> out
cp crest_ensemble.xyz ..
echo " > Done"
cd ..

mkdir -p tmp_orca
cp orca_opt.inp tmp_orca
cp crest_ensemble.xyz tmp_orca/tmp_confs.xyz
cd tmp_orca
#splitta ensemble
echo "Extracting files..."
obabel -ixyz tmp_confs.xyz -oxyz -Oto_be_opt.xyz -m
rm tmp_confs.xyz
mkdir -p tmp_tmp

d=0
for j in to_be_opt*.xyz
do
let "d=d+1"
done

echo "Optimizing with ORCA"
c=1

for j in to_be_opt*.xyz
do
echo " > \$c/\$d"

rm -f -r tmp_tmp/*
cp \$j tmp_tmp/opt_me.xyz
cp orca_opt.inp tmp_tmp/orca_opt.inp
cd tmp_tmp
~/orca/orca orca_opt.inp > out
orca_en=\$(grep "FINAL SINGLE POINT ENERGY" out | tail -1 | awk '{print \$5}')
#echo -ne "\t\$orca_en"
sed -i "s/Coordinates from ORCA.*/        \$orca_en/" orca_opt.xyz
cp orca_opt.xyz "../optimized\$c.xyz"

let "c=c+1"
cd ..

#echo $j
done
#cat ./tmp_orca/optimized1.xyz


cat optimized*.xyz > orca_optimized_merged.xyz

cp orca_optimized_merged.xyz ..

cd ..

echo " > Pruning orca-optimized ensemble..."
crest orca_optimized_merged.xyz --cregen orca_optimized_merged.xyz > out

cp crest_ensemble.xyz ../optimized_confs/FILENAMEFILENAME.xyz

cd ..


rm -f -r tmp_orca
rm -f orca_opt.inp
rm -f crest_ensemble.xyz
EOF

sudo chmod +x command.sh


for ii in *.xyz
do
i="${ii%.*}"
mkdir $i
cp $ii $i
cp command.sh $i
cd $i
sed -i "s/FILENAMEFILENAME/$i/" command.sh



echo
echo "Now working in folder $i"

if [[ ! -f $i.xyz ]] 
then
read -p  "A command script has been written
with reference to a $i.xyz file which WAS NOT FOUND.
Rename it manually to $i.xyz and press any key to continue"
fi



cat << EOF > orca_opt.inp
! B3LYP 6-31G* TightOpt
%pal nprocs 5 end

*xyzfile 0 1 opt_me.xyz
EOF

./command.sh

cd ..
done
