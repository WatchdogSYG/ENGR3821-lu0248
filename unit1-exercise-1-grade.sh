#!/bin/bash
if [ "x$1" == "x" ]; then
  echo "You must supply the name of the script you wish to test."
fi

if [ -e exercise1.txt ]; then rm -f exercise1.txt; fi
# 2. Get contents of tar ball, and sort them, and exclude time stamps
tar ztvf unit1-solution1.tgz | cut -c1-30,48- | LC_COLLATE=C sort > exercise1.txt
# 3. Compare output with template.
differentlines=`diff exercise1.txt unit1-exercise-1-template.txt | grep "^>" | wc -l` # count each differing line only once
if [ $differentlines -gt 20 ]; then differentlines=20; fi
# 4. Work out grade based on output and size of script
deduct=$((differentlines * 3))
outputpoints=$((60 - deduct))
# Size points only apply if you can get 100% on the correctness.
sizepoints=0
size=`cat $1 | wc -c`
if [ $size -le 2419 ]; then sizepoints=5; fi
if [ $size -le 1697 ]; then sizepoints=15; fi
if [ $size -le 975 ]; then sizepoints=25; fi
if [ $size -le 828 ]; then sizepoints=40; fi
if [ $differentlines -gt 0 ]; then sizepoints=0; fi

echo "Correctness points: $outputpoints"
echo "Size points: $sizepoints"
echo
total=$((outputpoints + sizepoints))
echo "TOTAL: $total"

if [ $differentlines -gt 0 ]; then
  echo "Differences in output that need to be fixed:"
  diff exercise1.txt unit1-exercise-1-template.txt
fi
