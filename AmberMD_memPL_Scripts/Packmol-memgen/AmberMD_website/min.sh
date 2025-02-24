EXE=pmemd.cuda
PRMTOP=YOUR_TOP_HERE
INPCRD=YOUR_CRD_HERE

OLD=$INPCRD
NEW=01_min_water_primary
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD

OLD=$NEW.restrt
NEW=02_min_water_secondary
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD

OLD=$NEW.restrt
NEW=03_min_lipids_primary
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD

OLD=$NEW.restrt
NEW=04_min_lipids_secondary
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD

OLD=$NEW.restrt
NEW=05_min_all
$EXE -O -i $NEW.in -o $NEW.out -p $PRMTOP -c $OLD -r $NEW.restrt -ref $OLD