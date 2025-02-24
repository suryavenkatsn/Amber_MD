EXE=pmemd.cuda
PRMTOP=YOUR_TOP_HERE
INPCRD=05_min_all.restrt

OLD=$INPCRD
NEW=06_nvt_initial
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD -x $NEW.nc
OLD=$NEW.restrt
NEW=07_npt_initial
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD -x $NEW.nc
OLD=$NEW.restrt
NEW=08_npt_pbceq
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD -x $NEW.nc