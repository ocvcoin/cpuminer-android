#!/bin/bash

if (( $EUID != 0 )); then
    echo "
	Please run as root
	"
    exit
fi

export DEBIAN_FRONTEND=noninteractive

set -e

apt update

apt -y install pkg-config wget unzip git tar cmake

apt -y upgrade ca-certificates

set +e




if [ ! -d "/opt/android-ndk-r12b/ok" ]; then

	rm /opt/android-ndk-r12b-linux-x86_64.zip

	rm -rf /opt/android-ndk-r12b
	
	set -e

	wget --output-document="/opt/android-ndk-r12b-linux-x86_64.zip" https://dl.google.com/android/repository/android-ndk-r12b-linux-x86_64.zip

	unzip -d /opt /opt/android-ndk-r12b-linux-x86_64.zip
	
	
	mkdir -p /opt/android-ndk-r12b/arm/
	mkdir -p /opt/android-ndk-r12b/arm64/
	mkdir -p /opt/android-ndk-r12b/x86/
	mkdir -p /opt/android-ndk-r12b/x86_64/


	bash /opt/android-ndk-r12b/build/tools/make-standalone-toolchain.sh --arch=arm --ndk-dir=/opt/android-ndk-r12b --install-dir=/opt/android-ndk-r12b/arm/ --verbose 
	bash /opt/android-ndk-r12b/build/tools/make-standalone-toolchain.sh --arch=arm64 --ndk-dir=/opt/android-ndk-r12b --install-dir=/opt/android-ndk-r12b/arm64/ --verbose 
	bash /opt/android-ndk-r12b/build/tools/make-standalone-toolchain.sh --arch=x86 --ndk-dir=/opt/android-ndk-r12b --install-dir=/opt/android-ndk-r12b/x86/ --verbose 
	bash /opt/android-ndk-r12b/build/tools/make-standalone-toolchain.sh --arch=x86_64 --ndk-dir=/opt/android-ndk-r12b --install-dir=/opt/android-ndk-r12b/x86_64/ --verbose 


	mkdir /opt/android-ndk-r12b/ok/	
	
	set +e

fi




miner_path=$(pwd)



if [ ! -d "$miner_path/../curl-7.35.0/ok" ]; then

	cd "$miner_path/../"
	rm -rf curl-7.35.0
	rm curl-7.35.0.tar.bz2
	
	set -e
	
	wget --output-document="$miner_path/../curl-7.35.0.tar.bz2" https://curl.haxx.se/download/curl-7.35.0.tar.bz2
	tar -xvf curl-7.35.0.tar.bz2
	mkdir "$miner_path/../curl-7.35.0/ok"
	
	set +e

fi



if [ ! -d "$miner_path/../ocv2_algo/ok" ]; then

	cd "$miner_path/../"
	rm -rf ocv2_algo
	
	set -e
	
	git clone https://github.com/ocvcoin/ocv2_algo.git	
	mkdir "$miner_path/../ocv2_algo/ok"
	
	set +e

fi








cd "$miner_path/../ocv2_algo"

mkdir dependencies/opencv


cd dependencies/opencv


if [ ! -d "opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810/ok" ]; then
    
	
	rm 70bbf17b133496bd7d54d034b0f94bd869e0e810.zip
	
	set -e
	
    wget --output-document="$miner_path/../ocv2_algo/dependencies/opencv/70bbf17b133496bd7d54d034b0f94bd869e0e810.zip" https://github.com/opencv/opencv/archive/70bbf17b133496bd7d54d034b0f94bd869e0e810.zip
	unzip 70bbf17b133496bd7d54d034b0f94bd869e0e810.zip
	
	mkdir "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810/ok"
	
	set +e
	
	
fi

sed -i '21,22 s/^/#/' "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810/cmake/OpenCVCompilerOptions.cmake"

sed -i 's/PyString_AsString(obj);/(char*)PyString_AsString(obj);/' "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810/modules/python/src2/cv2.cpp"

### ARM fix! NEON instructions calculates wrong hash!
sed -i 's:define CV_NEON 1:define CV_NEON 0:g' "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810/modules/core/include/opencv2/core/cvdef.h"



### "arm64-v8a"
### "/opt/android-ndk-r12b/arm64/bin/aarch64-linux-android-g++"



cd "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810"

rm -rf build_arm64-v8a

rm -rf arm64-v8a

mkdir build_arm64-v8a && cd build_arm64-v8a

export ANDROID_NDK=/opt/android-ndk-r12b





cmake -DANDROID_ABI="arm64-v8a" -DCMAKE_TOOLCHAIN_FILE="$PWD/../platforms/android/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX:PATH="$PWD/../../arm64-v8a" -DCMAKE_SKIP_RPATH="ON" -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DBUILD_opencv_flann=OFF -DBUILD_opencv_ml=OFF -DBUILD_opencv_video=OFF -DBUILD_opencv_shape=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_objdetect=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_features2d=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_stitching=OFF -DBUILD_opencv_videostab=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_ZLIB=OFF -DBUILD_TIFF=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF -DBUILD_PNG=OFF -DBUILD_OPENEXR=OFF -DBUILD_TBB=OFF -DBUILD_WITH_STATIC_CRT=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DWITH_1394=OFF -DWITH_AVFOUNDATION=OFF -DWITH_CARBON=OFF -DWITH_CAROTENE=OFF -DWITH_VTK=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_NVCUVID=OFF -DWITH_EIGEN=OFF -DWITH_VFW=OFF -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GSTREAMER_0_10=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DWITH_IPP=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_OPENVX=OFF -DWITH_OPENNI=OFF -DWITH_OPENNI2=OFF -DWITH_PNG=OFF -DWITH_GDCM=OFF -DWITH_PVAPI=OFF -DWITH_GIGEAPI=OFF -DWITH_ARAVIS=OFF -DWITH_QT=OFF -DWITH_WIN32UI=OFF -DWITH_QUICKTIME=OFF -DWITH_QTKIT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_CSTRIPES=OFF -DWITH_PTHREADS_PF=OFF -DWITH_TIFF=OFF -DWITH_UNICAP=OFF -DWITH_V4L=OFF -DWITH_LIBV4L=OFF -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DWITH_XIMEA=OFF -DWITH_XINE=OFF -DWITH_CLP=OFF -DWITH_OPENCL=OFF -DWITH_OPENCL_SVM=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_DIRECTX=OFF -DWITH_INTELPERC=OFF -DWITH_IPP_A=OFF -DWITH_MATLAB=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF -DWITH_GDAL=OFF -DWITH_GPHOTO2=OFF -DWITH_LAPACK=OFF -DCMAKE_C_FLAGS="-O3" -DCMAKE_CXX_FLAGS="-O3" -DINSTALL_CREATE_DISTRIB=ON ..




make && make install



mkdir -p "$PWD/../../arm64-v8a/lib/pkgconfig"
cp "unix-install/opencv.pc" "$PWD/../../arm64-v8a/lib/pkgconfig/opencv.pc"


cd ../../../../


mkdir lib

mkdir tmp



mkdir "tmp/arm64-v8a"

mkdir "lib/arm64-v8a"



/opt/android-ndk-r12b/arm64/bin/aarch64-linux-android-g++ -c -o "tmp/arm64-v8a/ocv2.o" include/ocv2.cpp -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/arm64-v8a/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -fPIC -O3 -pipe -Wl,-soname,libocv2.so


/opt/android-ndk-r12b/arm64/bin/aarch64-linux-android-g++ -shared -o "lib/arm64-v8a/libocv2.so" "tmp/arm64-v8a/ocv2.o" -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/arm64-v8a/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -O3 -pipe -Wl,-soname,libocv2.so



mkdir "$miner_path/jni/arm64-v8a/"
cp "lib/arm64-v8a/libocv2.so" "$miner_path/jni/arm64-v8a/"











### "armeabi-v7a"
### "/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++"



cd "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810"

rm -rf build_armeabi-v7a

rm -rf armeabi-v7a

mkdir build_armeabi-v7a && cd build_armeabi-v7a

export ANDROID_NDK=/opt/android-ndk-r12b





cmake -DANDROID_ABI="armeabi-v7a" -DCMAKE_TOOLCHAIN_FILE="$PWD/../platforms/android/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX:PATH="$PWD/../../armeabi-v7a" -DCMAKE_SKIP_RPATH="ON" -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DBUILD_opencv_flann=OFF -DBUILD_opencv_ml=OFF -DBUILD_opencv_video=OFF -DBUILD_opencv_shape=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_objdetect=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_features2d=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_stitching=OFF -DBUILD_opencv_videostab=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_ZLIB=OFF -DBUILD_TIFF=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF -DBUILD_PNG=OFF -DBUILD_OPENEXR=OFF -DBUILD_TBB=OFF -DBUILD_WITH_STATIC_CRT=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DWITH_1394=OFF -DWITH_AVFOUNDATION=OFF -DWITH_CARBON=OFF -DWITH_CAROTENE=OFF -DWITH_VTK=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_NVCUVID=OFF -DWITH_EIGEN=OFF -DWITH_VFW=OFF -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GSTREAMER_0_10=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DWITH_IPP=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_OPENVX=OFF -DWITH_OPENNI=OFF -DWITH_OPENNI2=OFF -DWITH_PNG=OFF -DWITH_GDCM=OFF -DWITH_PVAPI=OFF -DWITH_GIGEAPI=OFF -DWITH_ARAVIS=OFF -DWITH_QT=OFF -DWITH_WIN32UI=OFF -DWITH_QUICKTIME=OFF -DWITH_QTKIT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_CSTRIPES=OFF -DWITH_PTHREADS_PF=OFF -DWITH_TIFF=OFF -DWITH_UNICAP=OFF -DWITH_V4L=OFF -DWITH_LIBV4L=OFF -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DWITH_XIMEA=OFF -DWITH_XINE=OFF -DWITH_CLP=OFF -DWITH_OPENCL=OFF -DWITH_OPENCL_SVM=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_DIRECTX=OFF -DWITH_INTELPERC=OFF -DWITH_IPP_A=OFF -DWITH_MATLAB=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF -DWITH_GDAL=OFF -DWITH_GPHOTO2=OFF -DWITH_LAPACK=OFF -DCMAKE_C_FLAGS="-O3" -DCMAKE_CXX_FLAGS="-O3" -DINSTALL_CREATE_DISTRIB=ON ..




make && make install



mkdir -p "$PWD/../../armeabi-v7a/lib/pkgconfig"
cp "unix-install/opencv.pc" "$PWD/../../armeabi-v7a/lib/pkgconfig/opencv.pc"


cd ../../../../


mkdir lib

mkdir tmp



mkdir "tmp/armeabi-v7a"

mkdir "lib/armeabi-v7a"



/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++ -c -o "tmp/armeabi-v7a/ocv2.o" include/ocv2.cpp -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/armeabi-v7a/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -fPIC -O3 -pipe -Wl,-soname,libocv2.so


/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++ -shared -o "lib/armeabi-v7a/libocv2.so" "tmp/armeabi-v7a/ocv2.o" -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/armeabi-v7a/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -O3 -pipe -Wl,-soname,libocv2.so



mkdir "$miner_path/jni/armeabi-v7a/"
cp "lib/armeabi-v7a/libocv2.so" "$miner_path/jni/armeabi-v7a/"









### "armeabi" aka armv5te
### "/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++"



cd "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810"

rm -rf build_armeabi

rm -rf armeabi

mkdir build_armeabi && cd build_armeabi

export ANDROID_NDK=/opt/android-ndk-r12b





cmake -DANDROID_ABI="armeabi" -DCMAKE_TOOLCHAIN_FILE="$PWD/../platforms/android/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX:PATH="$PWD/../../armeabi" -DCMAKE_SKIP_RPATH="ON" -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DBUILD_opencv_flann=OFF -DBUILD_opencv_ml=OFF -DBUILD_opencv_video=OFF -DBUILD_opencv_shape=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_objdetect=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_features2d=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_stitching=OFF -DBUILD_opencv_videostab=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_ZLIB=OFF -DBUILD_TIFF=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF -DBUILD_PNG=OFF -DBUILD_OPENEXR=OFF -DBUILD_TBB=OFF -DBUILD_WITH_STATIC_CRT=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DWITH_1394=OFF -DWITH_AVFOUNDATION=OFF -DWITH_CARBON=OFF -DWITH_CAROTENE=OFF -DWITH_VTK=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_NVCUVID=OFF -DWITH_EIGEN=OFF -DWITH_VFW=OFF -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GSTREAMER_0_10=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DWITH_IPP=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_OPENVX=OFF -DWITH_OPENNI=OFF -DWITH_OPENNI2=OFF -DWITH_PNG=OFF -DWITH_GDCM=OFF -DWITH_PVAPI=OFF -DWITH_GIGEAPI=OFF -DWITH_ARAVIS=OFF -DWITH_QT=OFF -DWITH_WIN32UI=OFF -DWITH_QUICKTIME=OFF -DWITH_QTKIT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_CSTRIPES=OFF -DWITH_PTHREADS_PF=OFF -DWITH_TIFF=OFF -DWITH_UNICAP=OFF -DWITH_V4L=OFF -DWITH_LIBV4L=OFF -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DWITH_XIMEA=OFF -DWITH_XINE=OFF -DWITH_CLP=OFF -DWITH_OPENCL=OFF -DWITH_OPENCL_SVM=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_DIRECTX=OFF -DWITH_INTELPERC=OFF -DWITH_IPP_A=OFF -DWITH_MATLAB=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF -DWITH_GDAL=OFF -DWITH_GPHOTO2=OFF -DWITH_LAPACK=OFF -DCMAKE_C_FLAGS="-O3" -DCMAKE_CXX_FLAGS="-O3" -DINSTALL_CREATE_DISTRIB=ON ..




make && make install



mkdir -p "$PWD/../../armeabi/lib/pkgconfig"
cp "unix-install/opencv.pc" "$PWD/../../armeabi/lib/pkgconfig/opencv.pc"


cd ../../../../


mkdir lib

mkdir tmp



mkdir "tmp/armeabi"

mkdir "lib/armeabi"



/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++ -c -o "tmp/armeabi/ocv2.o" include/ocv2.cpp -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/armeabi/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -fPIC -O3 -pipe -Wl,-soname,libocv2.so


/opt/android-ndk-r12b/arm/bin/arm-linux-androideabi-g++ -shared -o "lib/armeabi/libocv2.so" "tmp/armeabi/ocv2.o" -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/armeabi/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -O3 -pipe -Wl,-soname,libocv2.so



mkdir "$miner_path/jni/armeabi/"


cp "lib/armeabi/libocv2.so" "$miner_path/jni/armeabi/"



    
	
	






### "x86_64"
### "/opt/android-ndk-r12b/x86_64/bin/x86_64-linux-android-g++"



cd "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810"

rm -rf build_x86_64

rm -rf x86_64

mkdir build_x86_64 && cd build_x86_64

export ANDROID_NDK=/opt/android-ndk-r12b





cmake -DANDROID_ABI="x86_64" -DCMAKE_TOOLCHAIN_FILE="$PWD/../platforms/android/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX:PATH="$PWD/../../x86_64" -DCMAKE_SKIP_RPATH="ON" -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DBUILD_opencv_flann=OFF -DBUILD_opencv_ml=OFF -DBUILD_opencv_video=OFF -DBUILD_opencv_shape=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_objdetect=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_features2d=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_stitching=OFF -DBUILD_opencv_videostab=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_ZLIB=OFF -DBUILD_TIFF=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF -DBUILD_PNG=OFF -DBUILD_OPENEXR=OFF -DBUILD_TBB=OFF -DBUILD_WITH_STATIC_CRT=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DWITH_1394=OFF -DWITH_AVFOUNDATION=OFF -DWITH_CARBON=OFF -DWITH_CAROTENE=OFF -DWITH_VTK=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_NVCUVID=OFF -DWITH_EIGEN=OFF -DWITH_VFW=OFF -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GSTREAMER_0_10=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DWITH_IPP=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_OPENVX=OFF -DWITH_OPENNI=OFF -DWITH_OPENNI2=OFF -DWITH_PNG=OFF -DWITH_GDCM=OFF -DWITH_PVAPI=OFF -DWITH_GIGEAPI=OFF -DWITH_ARAVIS=OFF -DWITH_QT=OFF -DWITH_WIN32UI=OFF -DWITH_QUICKTIME=OFF -DWITH_QTKIT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_CSTRIPES=OFF -DWITH_PTHREADS_PF=OFF -DWITH_TIFF=OFF -DWITH_UNICAP=OFF -DWITH_V4L=OFF -DWITH_LIBV4L=OFF -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DWITH_XIMEA=OFF -DWITH_XINE=OFF -DWITH_CLP=OFF -DWITH_OPENCL=OFF -DWITH_OPENCL_SVM=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_DIRECTX=OFF -DWITH_INTELPERC=OFF -DWITH_IPP_A=OFF -DWITH_MATLAB=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF -DWITH_GDAL=OFF -DWITH_GPHOTO2=OFF -DWITH_LAPACK=OFF -DCMAKE_C_FLAGS="-O3" -DCMAKE_CXX_FLAGS="-O3" -DINSTALL_CREATE_DISTRIB=ON ..




make && make install



mkdir -p "$PWD/../../x86_64/lib/pkgconfig"
cp "unix-install/opencv.pc" "$PWD/../../x86_64/lib/pkgconfig/opencv.pc"


cd ../../../../


mkdir lib

mkdir tmp



mkdir "tmp/x86_64"

mkdir "lib/x86_64"



/opt/android-ndk-r12b/x86_64/bin/x86_64-linux-android-g++ -c -o "tmp/x86_64/ocv2.o" include/ocv2.cpp -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/x86_64/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -fPIC -O3 -pipe -Wl,-soname,libocv2.so


/opt/android-ndk-r12b/x86_64/bin/x86_64-linux-android-g++ -shared -o "lib/x86_64/libocv2.so" "tmp/x86_64/ocv2.o" -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/x86_64/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -O3 -pipe -Wl,-soname,libocv2.so



mkdir "$miner_path/jni/x86_64/"
cp "lib/x86_64/libocv2.so" "$miner_path/jni/x86_64/"










### "x86"
### "/opt/android-ndk-r12b/x86/bin/i686-linux-android-g++"



cd "$miner_path/../ocv2_algo/dependencies/opencv/opencv-70bbf17b133496bd7d54d034b0f94bd869e0e810"

rm -rf build_x86

rm -rf x86

mkdir build_x86 && cd build_x86

export ANDROID_NDK=/opt/android-ndk-r12b





cmake -DANDROID_ABI="x86" -DCMAKE_TOOLCHAIN_FILE="$PWD/../platforms/android/android.toolchain.cmake" -DCMAKE_INSTALL_PREFIX:PATH="$PWD/../../x86" -DCMAKE_SKIP_RPATH="ON" -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_FIND_LIBRARY_SUFFIXES=".a" -DBUILD_opencv_flann=OFF -DBUILD_opencv_ml=OFF -DBUILD_opencv_video=OFF -DBUILD_opencv_shape=OFF -DBUILD_opencv_videoio=OFF -DBUILD_opencv_highgui=OFF -DBUILD_opencv_objdetect=OFF -DBUILD_opencv_superres=OFF -DBUILD_opencv_ts=OFF -DBUILD_opencv_features2d=OFF -DBUILD_opencv_calib3d=OFF -DBUILD_opencv_stitching=OFF -DBUILD_opencv_videostab=OFF -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DBUILD_ZLIB=OFF -DBUILD_TIFF=OFF -DBUILD_JASPER=OFF -DBUILD_JPEG=OFF -DBUILD_PNG=OFF -DBUILD_OPENEXR=OFF -DBUILD_TBB=OFF -DBUILD_WITH_STATIC_CRT=ON -DINSTALL_C_EXAMPLES=OFF -DINSTALL_PYTHON_EXAMPLES=OFF -DWITH_1394=OFF -DWITH_AVFOUNDATION=OFF -DWITH_CARBON=OFF -DWITH_CAROTENE=OFF -DWITH_VTK=OFF -DWITH_CUDA=OFF -DWITH_CUFFT=OFF -DWITH_CUBLAS=OFF -DWITH_NVCUVID=OFF -DWITH_EIGEN=OFF -DWITH_VFW=OFF -DWITH_FFMPEG=OFF -DWITH_GSTREAMER=OFF -DWITH_GSTREAMER_0_10=OFF -DWITH_GTK=OFF -DWITH_GTK_2_X=OFF -DWITH_IPP=OFF -DWITH_JASPER=OFF -DWITH_JPEG=OFF -DWITH_WEBP=OFF -DWITH_OPENEXR=OFF -DWITH_OPENGL=OFF -DWITH_OPENVX=OFF -DWITH_OPENNI=OFF -DWITH_OPENNI2=OFF -DWITH_PNG=OFF -DWITH_GDCM=OFF -DWITH_PVAPI=OFF -DWITH_GIGEAPI=OFF -DWITH_ARAVIS=OFF -DWITH_QT=OFF -DWITH_WIN32UI=OFF -DWITH_QUICKTIME=OFF -DWITH_QTKIT=OFF -DWITH_TBB=OFF -DWITH_OPENMP=OFF -DWITH_CSTRIPES=OFF -DWITH_PTHREADS_PF=OFF -DWITH_TIFF=OFF -DWITH_UNICAP=OFF -DWITH_V4L=OFF -DWITH_LIBV4L=OFF -DWITH_DSHOW=OFF -DWITH_MSMF=OFF -DWITH_XIMEA=OFF -DWITH_XINE=OFF -DWITH_CLP=OFF -DWITH_OPENCL=OFF -DWITH_OPENCL_SVM=OFF -DWITH_OPENCLAMDFFT=OFF -DWITH_OPENCLAMDBLAS=OFF -DWITH_DIRECTX=OFF -DWITH_INTELPERC=OFF -DWITH_IPP_A=OFF -DWITH_MATLAB=OFF -DWITH_VA=OFF -DWITH_VA_INTEL=OFF -DWITH_GDAL=OFF -DWITH_GPHOTO2=OFF -DWITH_LAPACK=OFF -DCMAKE_C_FLAGS="-O3" -DCMAKE_CXX_FLAGS="-O3" -DINSTALL_CREATE_DISTRIB=ON ..




make && make install



mkdir -p "$PWD/../../x86/lib/pkgconfig"
cp "unix-install/opencv.pc" "$PWD/../../x86/lib/pkgconfig/opencv.pc"


cd ../../../../


mkdir lib

mkdir tmp



mkdir "tmp/x86"

mkdir "lib/x86"



/opt/android-ndk-r12b/x86/bin/i686-linux-android-g++ -c -o "tmp/x86/ocv2.o" include/ocv2.cpp -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/x86/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -fPIC -O3 -pipe -Wl,-soname,libocv2.so


/opt/android-ndk-r12b/x86/bin/i686-linux-android-g++ -shared -o "lib/x86/libocv2.so" "tmp/x86/ocv2.o" -I$PWD/dependencies/sha `env PKG_CONFIG_LIBDIR=$PWD/dependencies/opencv/x86/lib/pkgconfig pkg-config --static --cflags --libs opencv` -std=c++11 -O3 -pipe -Wl,-soname,libocv2.so



mkdir "$miner_path/jni/x86/"
cp "lib/x86/libocv2.so" "$miner_path/jni/x86/"









cd "$miner_path"

bash "$miner_path/build-libcurl.sh" "$miner_path/../curl-7.35.0/"


cd "$miner_path"


/opt/android-ndk-r12b/ndk-build


