cd mplayer || exit 1

export LDFLAGS="-L/usr/lib"


export CC='gcc -m32'

./configure \
	--prefix=/usr/local/mplayer32 \
	--enable-cross-compile --target=i686-linux --enable-win32dll \
	--codecsdir=/usr/local/lib/win32 \
	--enable-{xv,vdpau,xvmc,x11} \
2>&1 | tee ../log


	