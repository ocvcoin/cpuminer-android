Ocvcoin Android Miner

forked from mdelling/cpuminer-android



Build on UBUNTU
----------------


```
sudo apt update

sudo apt -y install git

git clone https://github.com/ocvcoin/cpuminer-android.git

cd cpuminer-android && sudo bash build.sh

```

When the script finishes, it will have compiled all the required NDK shared objects. Now you can copy the "cpuminer-android" folder to a PC with Android Studio installed, import the project and build the APK.
