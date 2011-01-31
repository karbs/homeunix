#
# outputs string
#
trace() {
	echo "*** homeunix (trace): $*"
}


#
# Creates some necessary directories in user's home
#
homeunix_create_dirs(){
	mkdir -p $HOME/{bin,tmp}
}


#
# Sets Midnight Commander console colors
# Usage: homeunix_mc_colors { background } { foreground }
# Possible colors described in mc(1)
#
homeunix_mc_colors(){
	b=${1:-black}
	t=${2:-lightgray}
	y=${3:-yellow}
	export MC_COLOR_TABLE=normal=$t,$b:editnormal=$t,$b:marked=$y,$b:editmarked=$b,$t:selected=$b,$t:markselect=$y,$t
}

