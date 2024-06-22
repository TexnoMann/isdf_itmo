from ros:noetic

SHELL ["/bin/bash", "-ci"]
ENV DEBIAN_FRONTEND noninteractive

RUN echo "source /opt/ros/noetic/setup.bash">> ~/.bashrc

RUN mkdir -p /ros_ws/src/isdf_packages/
RUN mkdir -p /custom_libs

#utils========
RUN apt update -y && apt install -y git
RUN apt update -y && apt install -y python3-pip
RUN apt update -y && apt install -y vim
RUN apt update -y && apt install -y python3-catkin-tools
RUN apt update -y && apt install -y wget

#catcin_make==
RUN mkdir -p ~/catkin_ws/src
# WORKDIR ~/catkin_ws/
RUN cd ~/catkin_ws/ && catkin_make
# RUN 



#libs==========
RUN apt update -y && apt install -y libeigen3-dev
RUN apt update -y && apt install -y libgl1-mesa-dev
RUN apt update -y && apt install -y libepoxy-dev

WORKDIR /custom_libs
RUN git clone --recursive https://github.com/stevenlovegrove/Pangolin.git && \
    cd Pangolin && mkdir build && cd build/ && cmake .. && make && make install

RUN apt update -y && apt install -y libopencv-dev python3-opencv
RUN pip install numpy==1.24.4

WORKDIR /custom_libs
RUN mkdir ORB_SLAM3
COPY ./lib/ORB_SLAM3 /custom_libs/ORB_SLAM3

WORKDIR /custom_libs/ORB_SLAM3
RUN cd ~/../custom_libs/ORB_SLAM3
RUN chmod +x build.sh
RUN ./build.sh

RUN apt update -y && apt install -y ros-$ROS_DISTRO-realsense2-camera

WORKDIR /catkin_ws/src/
RUN mkdir iSDF
COPY ./lib/iSDF /catkin_ws/src/iSDF

WORKDIR /catkin_ws/src/iSDF/ORB_SLAM3_ros/config
RUN tar -xf ORBvoc.txt.tar.gz
RUN apt update -y
RUN cd /catkin_ws/src/iSDF/ORB_SLAM3_ros/config && tar -xf ORBvoc.txt.tar.gz

WORKDIR /catkin_ws
RUN catkin_make

WORKDIR /catkin_ws
RUN source devel/setup.bash

RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN echo "export PATH=$PATH:/root/miniconda3/bin">> ~/.bashrc

WORKDIR /catkin_ws/src/iSDF
RUN conda env create -f environment.yml
RUN echo "source activate base">> ~/.bashrc
RUN echo "conda activate isdf">> ~/.bashrc

RUN cd && pip3 install torch torchvision
RUN pip install -e .
RUN apt update -y


# sudo apt update && sudo apt upgrade -y
# apt upgrade && apt install software-properties-common
# sudo add-apt-repository ppa:graphics-drivers/ppa -y
# sudo apt update

# sudo apt install nvidia-driver-550




