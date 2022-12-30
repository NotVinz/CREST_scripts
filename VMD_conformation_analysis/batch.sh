echo > report.txt
for i in optimized*.xyz
do
vmd $i -dispdev text -e prova.tcl  > /dev/null 2> /dev/null

nrg=$(head -2 $i | tail -1 | awk '{print $1}')

symm=$(cat /tmp/conformerscript.dat)

echo "$i" "$nrg" "$symm"

done
