#!/bin/sh

# For Linux

# zabbix_agentd.conf
# UserParameter=upsmon[*],/etc/zabbix/scripts/nut-ups.sh $1 $2

# UPSC Path
UPSC="/bin/upsc"

ups=$1

if [ $ups = ups.discovery ]; then

    echo "{\n\t\"data\":["
    first=1
    ${UPSC} -l 2>&1 | grep -v SSL | while read discovered ; do
        if [ $first -eq 0 ]; then
            echo ","
        fi
        echo "\t\t{ \"{#UPSNAME}\":\t\"${discovered}\" }"
        first=0
    done
    echo "\n\t]\n}"

else
key=$2

if [ $key = ups.status ]; then
        state=`${UPSC} $ups $key 2>&1 | grep -v SSL`
#       echo $state
        case $state in
                OL*)            echo 1 ;; #'On line (mains is present)' ;;
                OB)             echo 2 ;; #'On battery (mains is not present)' ;;
                LB)             echo 3 ;; #'Low battery' ;;
                RB)             echo 4 ;; #'The battery needs to be replaced' ;;
                CHRG)           echo 5 ;; #'The battery is charging' ;;
                DISCHRG)        echo 6 ;; #'The battery is discharging (inverter is providing load power)' ;;
                BYPASS)         echo 7 ;; #'UPS bypass circuit is active echo no battery protection is available' ;;
                CAL)            echo 8 ;; #'UPS is currently performing runtime calibration (on battery)' ;;
                OFF)            echo 9 ;; #'UPS is offline and is not supplying power to the load' ;;
                OVER)           echo 10 ;; #'UPS is overloaded' ;;
                TRIM)           echo 11 ;; #'UPS is trimming incoming voltage (called "buck" in some hardware)' ;;
                BOOST)          echo 12 ;; #'UPS is boosting incoming voltage' ;;
                * )             echo 0 ;; #'unknown state' ;;
        esac
else
        ${UPSC} $ups $key  2>&1 | grep -v SSL
fi

fi
