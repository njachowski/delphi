#!/usr/bin/env python
import os
import shutil
import delphi_options as ko
import subprocess

dbn = 'python /Users/nick/Copy/scripts/db/db.py '
#rs_export = 'python '+os.environ['copy']+'scripts/rs_export.py '

(options, args) = ko.argsOptions() #set up options

if os.path.exists(options.save_to): #check if dir exists already
    print('File \"'+options.save_to+'\" already exists')
else: 
    os.makedirs(options.save_to)
    print('Created directory \"'+options.save_to+'\"')
    os.chdir(options.save_to)
if options.show_regions:
    print("Printing regions...")
    cmd = dbn+"\"select distinct region from datascience.key_countries;\" -d pg -s regions.csv"
    ko.run_sql(cmd)
    ko.print_file('regions.csv');
if len(options.country_region) > 0:
    print("Printing countries for given region...")
    cmd = dbn+"\"select country_code,country_name from datascience.key_countries where region=\'"+options.country_region+"\';\" -d pg -s countries.csv"
    ko.run_sql(cmd)
    ko.print_file('countries.csv')
if options.execute:
    if len(options.container) == 0:    
        print("You must specify a container_id to execute the program")
    print("Executing 36-month video start prediction model")
    print("\n[1 of 5] Getting list of videos for given container")
    cmd = dbn+"\"select distinct id from reporting.videos where container_id=\'"+options.container+"\' and licensed and state='normal' and type=\'episode\';\" -d pg -s vid_list.csv"#+options.container+".csv"
    ko.run_sql(cmd)
    ko.print_file('vid_list.csv')#options.container+'.csv')
    cmd = dbn+"\"select distinct id,number,title,title_detailed,origin_language,content_owner_id,genres from reporting.videos where container_id=\'"+options.container+"\' and licensed and state='normal' and type=\'episode\';\" -d pg -s vid_list_detail.csv"#+options.container+".csv"
    ko.run_sql(cmd)
    ko.print_file('vid_list_detail.csv')
    print("\n[2 of 5] Creating datascience.temp_date table")
    cmd = dbn+"\"drop table datascience.temp_date;\" -d rs"
    ko.run_sql(cmd)
    cmd = dbn+"\"create table datascience.temp_date as select date_d,sum(video_play_cnt) from reporting.cl_country_video_parent where source in (\'ios\',\'android\',\'direct\') and country in (\'cl\',\'co\',\'cr\',\'mx\',\'cu\',\'do\',\'ec\',\'sv\',\'gf\',\'gt\',\'gy\',\'ht\',\'hn\',\'ni\',\'pa\',\'py\',\'pe\',\'ar\',\'bo\',\'sr\',\'uy\',\'br\',\'fk\',\'ve\',\'us\',\'ca\',\'gl\',\'gu\',\'ms\',\'pm\',\'ky\',\'mq\',\'dm\',\'gd\',\'gp\',\'jm\',\'an\',\'pr\',\'kn\',\'lc\',\'ai\',\'ag\',\'aw\',\'bs\',\'bb\',\'bz\',\'bm\',\'tt\',\'tc\',\'vg\',\'mf\',\'vi\',\'vc\') group by 1 order by 1;\" -d rs"
    ko.run_sql(cmd)
    print("\n[3 of 5] Creating datascience.temp_container table")
    cmd = dbn+"\"drop table datascience.temp_container;\" -d rs"
    ko.run_sql(cmd)
    cmd = dbn+ko.create_temp_container('vid_list.csv')
    ko.run_sql(cmd)
    cmd = dbn+"\"alter table datascience.temp_container add column denom int;\" -d rs"
    ko.run_sql(cmd)
    cmd = dbn+"\"alter table datascience.temp_container add column vs_normal float;\" -d rs"
    ko.run_sql(cmd)
    cmd = dbn+"\"update datascience.temp_container set denom=T.sum from datascience.temp_date as T where datascience.temp_container.date_d=T.date_d;\" -d rs"
    ko.run_sql(cmd)
    cmd = dbn+"\"update datascience.temp_container set vs_normal=(sum::float/denom::float);\" -d rs"
    ko.run_sql(cmd)
    print("\n[4 of 5] Downloading datascience.temp_container as data.csv")
    cmd = dbn+"\"select * from datascience.temp_container;\" -d rs -s data.csv"#+options.container+".csv"
    ko.run_sql(cmd)
    print("\n[5 of 5] Now it's time to run the model and calculate the long-term value")
    ko.run_sql('R CMD BATCH --slave ../a.R out.txt')
