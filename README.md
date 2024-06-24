# isdf

## Подготовка
1. Распакуйте словарь для ORB-SLAM3:
    ```
    cd lib/iSDF/ORB_SLAM3_ros/config && tar -xf ORBvoc.txt.tar.gz
    ```
2. Соберите Docker-образ:
    ```
    docker compose build
    ```
## Начало работы
1. Запустите контейнер как сервис:
    ```
    docker compose up
    ```
2. Подключитесь в контейнер:
    ```
    docker compose exec isdf bash
    ```
3. Подключите камеру и запустите isdf:
    ```
    roslaunch isdf train.launch show_orbslam_vis:=true
    ```