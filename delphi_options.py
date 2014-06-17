#!/usr/bin/env python
import os
import numpy as np
import csv
import math
import subprocess
import time
from optparse import OptionParser

#
#CONSTANTS# YOU CAN CHANGE THESE TO DIFFERENT VALUES 
#
SAVE_TO='temp'
COUNTRY_REGION=''
EXECUTE=''
CONTAINER='8112c'

def argsOptions():
    usage = "usage: %prog [options]"
    parser = OptionParser(usage=usage)
    parser.add_option("-s", "--save_to", action="store", dest="save_to", default=SAVE_TO, help="location to save output [default="+SAVE_TO+"]")
    parser.add_option("-r", "--show_regions", action="store_true", dest="show_regions", default=False, help="print regions and exit")
    parser.add_option("-c", "--show_countries", action="store", dest="country_region", default=COUNTRY_REGION, help="print countries in given region and exit")
    parser.add_option("-e", "--execute", action="store_true", dest="execute", default=False, help="execute video start prediction model")
    parser.add_option("-v", "--container", action="store", dest="container", default=CONTAINER, help="container_id on which to execute model [required for execution]")
    
    (options, args)	= parser.parse_args()	
    return (options, args)

def print_file(filename):
    f = open(filename)
    for line in f:
        print line,
    f.close()

def run_sql(cmd):
    p = subprocess.Popen(cmd, shell=True, stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    out, err = p.communicate()
    print(out)
    print(err)

def create_temp_container(filename):
    count = 0
    cmd = "-n -q \"create table datascience.temp_container as select video_id,date_d,sum(video_play_cnt) from reporting.cl_country_video_parent where source in (\'ios\',\'android\',\'direct\') and country in (\'cl\',\'co\',\'cr\',\'mx\',\'cu\',\'do\',\'ec\',\'sv\',\'gf\',\'gt\',\'gy\',\'ht\',\'hn\',\'ni\',\'pa\',\'py\',\'pe\',\'ar\',\'bo\',\'sr\',\'uy\',\'br\',\'fk\',\'ve\',\'us\',\'ca\',\'gl\',\'gu\',\'ms\',\'pm\',\'ky\',\'mq\',\'dm\',\'gd\',\'gp\',\'jm\',\'an\',\'pr\',\'kn\',\'lc\',\'ai\',\'ag\',\'aw\',\'bs\',\'bb\',\'bz\',\'bm\',\'tt\',\'tc\',\'vg\',\'mf\',\'vi\',\'vc\') and video_id in ("
    f = open(filename, 'r')
    for lines in f.readlines():
    #with open('video_id.csv') as f:
        #lines = f.read()
        if count > 0:
            cmd = cmd+"\'"+lines.strip('\n')+"\',"
        print(count)
        count += 1
    cmd = cmd[:-1]+") group by 1,2 order by 2,1;\" -d rs"
    print(cmd)
    return (cmd)
