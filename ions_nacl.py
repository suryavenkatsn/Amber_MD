import cmath
import argparse
parser = argparse.ArgumentParser(description='Ions to Neutralize the System.')
parser.add_argument("-i", "--print_float", help="Prints the total unperturbed charge of the system.", type=float)
args = parser.parse_args()
print('Total unperturbed charge of the system: ',format(args.print_float))
if float(args.print_float) >= 0:
  print('Cl-')
else:
  print('Na+')
