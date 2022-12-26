for i in */
do
cd $i

echo "Now working in folder $i"

if [[ ! -f $i.xyz ]] 
then
read -p  "A command script has been written
with reference to a $i.xyz file which WAS NOT FOUND.
Rename it manually to $i.xyz and press any key to continue"
fi

cat << EOF > orca_opt.inp
! HF 3-21G Opt
%pal nprocs 4 end

*xyzfile 0 1 opt_me.xyz
EOF

cat << EOF > ./command.sh
echo " > Running conformer search"
crest $i.xyz -zs --gfn2 -T 4 > out

#sorting…
#(ocio: gli ho detto di bypassare i check topologici,
#controlla che esca roba giusta!)
echo " > Sorting conformers"
crest crest_best.xyz --cregen crest_conformers.xyz --notopo >> out
echo " > Pruning"
crest --screen crest_ensemble.xyz >> out
echo " > Done"

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

rm -r tmp_tmp/*
cp \$j tmp_tmp/opt_me.xyz
cp orca_opt.inp tmp_tmp/orca_opt.inp
cd tmp_tmp
~/orca/orca orca_opt.inp > out
cp orca_opt.xyz "../optimized\$c.xyz"

let "c=c+1"
cd ..

#echo $j
done


EOF

./command.sh


cd ..

done
