#!/bin/bash
python3 ions_nacl.py -i 5.6 >> ions.txt
echo ========================================
python3 sc_calcs.py -v 630207.996 >> sc.txt

