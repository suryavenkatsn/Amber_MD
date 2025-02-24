#!/usr/bin/perl

use strict;

my $antechamber="/home/charmm-gui/local/amber10/bin/antechamber";

#default starting mass is 450, append is x

#check for ligand and type
if ($#ARGV+1  != 3){
   print "Usage: ligand2charmm.pl ligand nc index\n";
   exit -1;
}

my $lname=shift;
my $nc=shift;
my $index=shift;
my $ligand=$lname;
my $lowerlname=lc $lname;
my $massappend;

$index=int($index);
if ($index > 25){
    my $exceed = $index - 25;
    my $first  = int(($exceed - 1)/26);
    my $second = $exceed - $first * 26 - 1;
    $massappend = chr($first+ord('A')).chr($second+ord('A'));
}else{
    $massappend = chr(ord('A')+$index);
}
$massappend = 'x'.$massappend;

#process it
#`$babel -isdf $lname.sdf -omol2 $lowerlname.mol2`;
# correct small decimal point error
my $molnc=`awk '{sum=sum+\$9; if (\$0 == "@<TRIPOS>BOND") exit} END{print sum}' $lname.mol2`;
if ($molnc < 0) { $molnc=int($molnc-0.5); }
else { $molnc=int($molnc+0.5); }
if ($nc == 'x') { $nc = $molnc };

`$antechamber -rn $ligand -s 2 -nc $nc -i $lname.mol2 -fi mol2 -o $lowerlname -fo charmm -c bcc -pf y`;
#check output
my $filesize = -s "$lowerlname.rtf";
if ($filesize == 0) { exit; }
#charge correction
my $fnc=`grep 'ATOM' $lowerlname.rtf | awk '{sum=sum+\$4} END{print sum}'`;

#post-process topology file
`mv $lowerlname.rtf $lowerlname.rtf.old`;
`mv $lowerlname.prm $lowerlname.prm.old`;
`head -n 3 $lowerlname.prm.old > $lowerlname.prm`;

my $IFH;
my $OFH;
my $POFH;
open $IFH, "<$lowerlname.rtf.old";
open $OFH, ">$lowerlname.rtf";
open $POFH, ">>$lowerlname.prm";

#process rtf file
my @lines= <$IFH>;
my $first=1;
foreach my $line (@lines){
    #if it's a mass line, rebuild it and add it to the protein topology
    if ($line =~ /^MASS\s+(\d+)\s+(\S+)\s+(\S+)/){
      my $newAtomType="_$2$massappend";
      if ($first){
	print $POFH "ATOMS\n";
	$first=0;
      }
      printf ( $OFH  "MASS   %3d %-6s %9.6f\n",-1, $newAtomType, $3);
      printf ( $POFH "MASS   %3d %-6s %9.6f\n",-1, $newAtomType, $3);
    }elsif ($line =~ /^(ATOM\s+\S+\s+)(\S+)\s+(\S+)/){
      #fix atomtype in ATOM sections
      my $newAtomType="_$2$massappend";
      #charge correction
      my $charge=$3;
      if (abs($fnc-$nc) != 0 && abs($fnc-$nc) < 0.001) {
          $charge=$charge-$fnc+$nc;
          $fnc=$nc;
      }
      printf ( $OFH "%s%-6s%10.6f\n",$1, $newAtomType, $charge);
    }elsif ($line =~ /^ANGL/){
	next;
    }elsif ($line =~ /^DIHE/){
	next;
    }else{
      printf $OFH $line;
    }
}

close $IFH;
close $OFH;
close $POFH;



#post-process parameter file

my $IFH;
my $OFH;
open $IFH, "<$lowerlname.prm.old";
open $OFH, ">>$lowerlname.prm";

my $state="";
my @lines= <$IFH>;
foreach my $line (@lines){
    #if it's a mass line, rebuild it
    if ($line =~ /BOND/){
      $state="BOND";
      print $OFH "\n";
    }
    if ($line =~ /ANGLE/){
      $state="ANGLE";
    }
    if ($line =~ /DIHEDRAL/){
      $state="DIHEDRAL";
    }
    if ($line =~ /IMPHI/){
      $state="IMPHI";
    }
    if ($line =~ /^NONBONDED/){
      $state="NONBONDED";
      printf ( $OFH "NONBONDED nbxmod  5 atom cdiel shift vatom vdistance vswitch -\n");
    }elsif ( $line=~/^CUTNB/){
      printf ( $OFH "cutnb 14.0 ctofnb 12.0 ctonnb 10.0 eps 1.0 e14fac 1.0 wmin 1.5\n");
    }elsif (!$state){ #Do nothing
    }elsif ($state eq "BOND"){
      if ($line =~ /^(\S+)\s+(\S+)(.+)/){ 
	my $a="_$1$massappend";
	my $b="_$2$massappend";
        printf ($OFH "%-3s %s%s\n",$a, $b,$3);
      }elsif ($line =~ /BOND/){
        printf ($OFH "BONDS\n");
      }else {printf $OFH $line;}
    }elsif ($state eq "ANGLE"){
      if ($line =~ /^(\S+)\s+(\S+)\s+(\S+)(.+)/){ 
	my $a="_$1$massappend";
	my $b="_$2$massappend";
	my $c="_$3$massappend";
        printf ($OFH "%-3s %3s %s%s\n",$a, $b,$c, $4);
      }elsif ($line =~ /ANGLE/){
        printf ($OFH "ANGLES\n");
      }else {printf $OFH $line;}
    }elsif ($state eq "DIHEDRAL"){
      if ($line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(.+)/){
        my $a="X", my $b="X", my $c="X", my $d="X";
        if (!($1 eq "X")) {$a="_$1$massappend";}
        if (!($2 eq "X")) {$b="_$2$massappend";}
        if (!($3 eq "X")) {$c="_$3$massappend";}
        if (!($4 eq "X")) {$d="_$4$massappend";}
        printf ($OFH "%-6s%-6s%-6s%-6s%9.3f%s\n",$a, $b, $c, $d,$5,$6);
      }elsif ($line =~ /DIHEDRAL/){
        printf ($OFH "DIHEDRALS\n");
      }else {printf $OFH $line;}
    }elsif ($state eq "IMPHI"){
      if ($line =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)\s+(\S+)(.+)/){
        my $a="X", my $b="X", my $c="X", my $d="X";
        if (!($1 eq "X")) {$a="_$1$massappend";}
        if (!($2 eq "X")) {$b="_$2$massappend";}
        if (!($3 eq "X")) {$c="_$3$massappend";}
        if (!($4 eq "X")) {$d="_$4$massappend";}
        printf ($OFH "%-6s%-6s%-6s%-6s%9.3f%s\n",$a, $b, $c, $d,$5,$6);
      }elsif ($line =~ /IMPHI/){
        printf ($OFH "IMPROPER\n");
      }else {printf $OFH $line;}
    }elsif ($state eq "NONBONDED"){
      if ($line=~/^\!/){
        print $OFH "$line";
      }elsif ($line=~/^(\w+)(.*)/){
        print $OFH "_$1$massappend$2\n";
      }elsif ($line=~/^\s+(\w+)(.*)/){
        print $OFH " _$1$massappend$2\n";
      }else{
        print $OFH "_$massappend$line\n";
      }
    }else{
      printf $OFH $line;
    }
}

close $IFH;
close $OFH;

# create topology file
my $IFH;
my $OFH;
open $IFH, "<$lowerlname.inp";
open $OFH, ">$lowerlname.crd";
print $OFH "* Residues coordinate\n";
print $OFH "*\n"; 


my $count=0;
my @lines= <$IFH>;
while ($count < (scalar @lines)-1){
  if ($lines[$count] =~ /^\s*(\d+)$/){
    my $num=$1;
    if ($lines[$count+1] =~ /^\s*\S+\s+\S+\s+$ligand\s+\S+\s+\S+\s+\S+\s+\S+$/){
      for (my $i=$count;$i<$count+$num+1; $i++){
	print $OFH $lines[$i];
      }
      last;
    }
  }
  $count++;
}

## make inp data
#my $OFH;
#open $OFH, ">$lowerlname.inp.add";
#print $OFH <<EOF;
#! $ligand
#open read card unit 10 name $lowerlname.rtf  \! ligand
#read  rtf card unit 10 append
#
#open read card unit 20 name $lowerlname.prm  \! ligand
#read  para flex card unit 20 append
#
#!Read sequence card
#!* Reading the coordinates of residue
#!*
#!    1
#! $ligand
#
#read sequence $ligand 1
#generate $ligand setup warn first none last none
#
#open read card unit 10 name $lowerlname.crd
#read coor card unit 10 append
#
#EOF
#
##end
`rm -rf mopac.out mopac.pdb mopac.in divcon.pdb $lowerlname.rtf.old $lowerlname.prm.old`;
#`rm -rf mopac.out mopac.pdb mopac.in divcon.pdb $lname.sdf $lowerlname.mol2`;
#chdir $cwd;
