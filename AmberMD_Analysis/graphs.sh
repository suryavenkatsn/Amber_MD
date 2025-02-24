sh ./conv_agr_png.sh
python ../md_graphs.py
for i in traj_analysis_*.pptx;
do echo $i
rm $i
mv traj_analysis.pptx $i
done
