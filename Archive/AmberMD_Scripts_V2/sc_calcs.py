import cmath
import argparse
parser = argparse.ArgumentParser(description='Volume of the System.')
parser.add_argument("-v", "--print_float", help="Prints the total volume of the system.", type=float)
args = parser.parse_args()
print('Volume of the System: ',format(args.print_float))
litre=10**-27
vl=float(args.print_float) * float(litre)
print('Volume of the box in litres:',format(vl))
sc=0.15
c=((float(sc) * 1000)/1 * (1/10**3) * (6.022*10**23/1))
print('Number of chloride/Sodium ions present in one litre of solution:',format(c))
i=float(vl) * float(c)
ions=round(i)
print('Number of chloride/sodium ions needed for 150 mM NaCl:\n',format(ions))

