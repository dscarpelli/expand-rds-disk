#!/bin/bash

##############################################
# Allocates more disk space to the specified 
# RDS DB instance.  Default is gp2 10% bigger.
#
# 2018 - Don Scarpelli
##############################################

# Set default % increase (1.00 = 100%)
default=0.10

cyan="\033[36m"
grn="\033[32m"
clr="\033[0m"

source ~/.profile

usage() {
  echo "Usage: $0 -d <db-instance> [-s <new_total_size>]"
  exit 1
}

while getopts "d:s:h" opt; do
  case $opt in
    d)
      instance=$OPTARG
    ;;
    s)
      newsize=$OPTARG
    ;;
    h)
      usage
    ;;
    *)
      usage
    ;;
  esac
done

if [[ -z $instance ]]; then
  echo "Please specify DB instance"
  usage
fi

if [[ -z $newsize ]]; then
  oldsize=$(/usr/local/bin/aws rds describe-db-instances --db-instance-identifier $instance --output text || echo "failed")
  if [[ "$oldsize" == "failed" ]]; then
    echo "API call failed, aborting."
    exit 1
  fi
  oldsize=$(echo "$oldsize" | grep DBINSTANCES | awk '{print $2}')
  newsize=$(echo $oldsize \* $default | bc)
  newsize=$(echo $oldsize + $newsize | bc)
  newsize=${newsize%.*}
fi

echo -en "${cyan}Expanding ${grn}$instance${cyan} to ${grn}${newsize}${cyan} GB in 10 seconds, Ctrl+C to abort...${clr}"
sleep 10

echo "/usr/local/bin/aws rds modify-db-instance \
        --db-instance-identifier $instance \
        --allocated-storage $newsize" >/dev/null

echo -e "${grn}Done${clr}"
exit 0
