from nvidia/cuda:12.4.0-devel-ubuntu20.04

SHELL ["/bin/bash", "-ci"]
ENV DEBIAN_FRONTEND noninteractive

ENV TZ=Europe/Moscow
ENV ROS_DISTRO=noetic
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone


#utils========
RUN apt update -y && apt install -y git python3-pip vim wget tmux curl

# Install ROS, see (http://wiki.ros.org/${ROS_DISTRO}/Installation/Ubuntu)
RUN apt-get update \ 
    && sh -c 'echo "deb http://packages.ros.org/ros/ubuntu focal main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - \
    && apt-get update && apt-get install -y ros-${ROS_DISTRO}-desktop-full \
    && echo "source /opt/ros/${ROS_DISTRO}/setup.bash" >> ~/.bashrc\
    && apt-get install -y python3-rosdep \
        python3-rosinstall \
        python3-rosinstall-generator \
        python3-wstool \
        python3-catkin-tools \
        python-lxml \
        build-essential \
    && rosdep init && rosdep update \
    && rm -rf /var/lib/apt/lists/* && apt autoremove && apt clean

RUN mkdir -p /ros_ws/src && cd /ros_ws \ 
    && catkin config --extend /opt/ros/${ROS_DISTRO} \
    && catkin build && echo "source /catkin_ws/devel/setup.bash" >> ~/.bashrc


RUN mkdir -p /custom_libs

#catcin_make==
RUN mkdir -p ~/catkin_ws/src && cd ~/catkin_ws/ && catkin_make


#libs==========
RUN apt update -y && apt install -y libeigen3-dev libgl1-mesa-dev libepoxy-dev

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


WORKDIR /catkin_ws
RUN catkin_make

RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && \
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
    rm -rf ~/miniconda3/miniconda.sh && \
    echo "export PATH=$PATH:/root/miniconda3/bin">> ~/.bashrc

WORKDIR /catkin_ws/src/iSDF
RUN conda env create -f environment.yml
RUN echo "source activate base">> ~/.bashrc
RUN echo "conda activate isdf">> ~/.bashrc

RUN cd && pip3 install torch torchvision
RUN pip install -e .