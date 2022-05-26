colon := :
$(colon) := :

all: overthrust_3D_initial_model.h5 external-allocator mmap-allocator reset

overthrust_3D_initial_model.h5:
	wget ftp://slim.gatech.edu/data/SoftwareRelease/WaveformInversion.jl/3DFWI/overthrust_3D_initial_model.h5

external-allocator: overthrust_3D_initial_model.h5
	echo "Running External allocator"
	git checkout external-allocator
	DEVITO_OPT=advanced \
	DEVITO_LANGUAGE=openmp \
	DEVITO_PLATFORM=skx \
	OMP_NUM_THREADS=18 \
	OMP_PLACES="{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}" \
	OMP_PROC_BIND=close \
	DEVITO_LOGGING=DEBUG \
	time numactl --cpubind=0 --interleave=0  python simple.py
	rm -rf /scr01/array.dat

mmap-allocator: overthrust_3D_initial_model.h5
	echo "Running MMAP allocator"
	git checkout mmap-allocator
	DEVITO_OPT=advanced \
	DEVITO_LANGUAGE=openmp \
	DEVITO_PLATFORM=skx \
	OMP_NUM_THREADS=18 \
	OMP_PLACES="{0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17}" \
	OMP_PROC_BIND=close \
	DEVITO_CHECKPOINT_DIR='/scr01/' \
	DEVITO_LOGGING=DEBUG \
	time numactl --cpubind=0 --interleave=0  python simple.py
	rm -rf /scr01/tmp*

reset:
	git checkout master