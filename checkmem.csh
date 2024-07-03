#!/bin/csh -x
set jobid=19773415
set path=$path /u/scicon/tools/bin
echo `date` >> memorytest1.$jobid
#qps $jobid >> memorytest1.$jobid
#qtop -H 0 -p 8 $jobid >> memorytest1.$jobid
qtop.pl -p 28 $jobid >> memorytest1.$jobid
#qsh $jobid "cat /proc/meminfo" >> memorytest1.$jobid
