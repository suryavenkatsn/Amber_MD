#!/bin/bash

# Check if the command-line argument is provided
if [ ! -n "$1" ]; then
    echo ""
    echo "Usage: $0 <MDtimeperiod>"
    echo ""
    echo "Example: $0 20"
    echo "This will extract the results from MD simulation ran for 20 ns"
    echo ""
    exit
fi

# Check if .png files are present in the graphs_* folders and exit if it is not found
if ! ls */graphs_$1/*.png 1> /dev/null 2>&1; then
    echo "Error: No PNG files found. Use Con_agr_png.sh to create PNG files and use md_graph.py to create a collated PowerPoint file."
	echo "-------------------"
	echo " Use the script (without single quotes) to rename the ppt files ==> for i in *; do echo '\$i'; cd $i/graphs_20/; mv traj_analysis.pptx traj_analysis_'\$i'.pptx; cd ../../;done*"
    exit 1
fi

# Check if .pptx files are present in the graphs_* folders and exit if it is not found
if ! ls */graphs_$1/*.pptx 1> /dev/null 2>&1; then
    echo "Error: No pptx files found. Use md_graph.py to create a collated PowerPoint file."
	echo "-------------------"
	echo "Run 'mdgraph' at the directory where all the png files are kept"
    exit 1
fi

# Compiling PRED from multiple folders
ls */dg_$1/PRED_*.csv >> PRED_list.txt

# Copy PRED files from subdirectories to the current directory
cp */dg_$1/PRED_*.csv .

# Run a Python script called Compile_PRED.py from the $AMBERAUTO directory
python $AMBERAUTO/Compile_PRED.py

# Remove temporary PRED files
rm PRED_*.csv

# Check if BE_all.csv exists, and if yes, remove it
if [ -f BE_all.csv ]; then
    rm BE_all.csv
fi

# Concatenate BE_*.csv files from subdirectories into BE_all.csv
cat */dg_$1/BE_*.csv >> BE_all.csv

# Compile graphs
mkdir compiled_graphs

cp */graphs_$1/traj_* compiled_graphs

# Collect MD optimized poses
mkdir mdopt
cp */frames_$1/*_ns_$1.pdb mdopt
cp */frames_$1/*-ns-$1.pdb mdopt

# Filtered hydrogen bond graphs
mkdir hbond_all
cp */hbond_$1/avg_*.dat hbond_all
cd hbond_all
# Run a Python script called filter_hbond.py from the $AMBERAUTO directory
python $AMBERAUTO/filter_hbond.py
rm avg*

cd ../

if [ -e _extracted_$1/ ]; then
	rm -r _extracted_$1
fi

mkdir _extracted_$1
mv BE_all.csv PRED_list.txt Compiled_PRED.csv compiled_graphs/ hbond_all/ mdopt/ _extracted_$1/


