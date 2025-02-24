res="HIN"
m=$(awk '/HIN/ {print $4}' rec.pdb | tail -1)
if [ $res == $m ];then
	tail -1 tes.txt
else
	tail -1 se.sh
fi
	
