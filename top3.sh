sourcep
while read line; do
  echo $line
  z=$line
  python /home/analytics/Copy/projects/kent/kent.py -e -v $z -s $z 
done < top3.txt
