#!/bin/bash 

# This script 1)select data from a SUBJECTS_dir,
# 2) Creates stats directory
# 3) Saves tabulated data for subcortical volume and intenstity; cortical GWC, volume, area, cth

###### set dirs #####
# ..................#

#basefolder=/cluster/projects/p23/projects/Other_projects/VirtualHistology/AIBL
#subsdir=$basefolder/fs6.0_AgeSym
#statsdir=$basefolder/stats/BrainAge
#cohort=aibl
subsdir=${1}
statsdir=${2}
cohort=${3}


SUBJECTS_DIR=$subsdir
cd $subsdir
mkdir $statsdir -p

ls *.long.* -1d > $statsdir/subs.txt

# subcortical volume
asegstats2table --subjectsfile=$statsdir/subs.txt \
		--meas volume \
		--skip \
		--tablefile $statsdir/$cohort.subc.volume.txt

#subcortical intensity
asegstats2table --subjectsfile=$statsdir/subs.txt \
		--meas mean \
		--skip \
		--tablefile $statsdir/$cohort.subc.intensity.txt


for h in lh rh; do 
	#cortical gwc
	asegstats2table --subjectsfile=$statsdir/subs.txt \
			--stats $h.w-g.pct.stats \
			--all-segs \
			--meas mean \
			--skip \
			--tablefile $statsdir/$cohort.cort.$h.gwc.txt
	# cth area, volume, thickness
	for i in area volume thickness; do
		aparcstats2table --subjectsfile=$statsdir/subs.txt \
			--meas $i \
			--hemi $h \
			--skip \
			--tablefile $statsdir/$cohort.cort.$h.$i.txt

	done
done

rm $statsdir/subs.txt

