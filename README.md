# SAGrabarskiy_microservices
# Выполнено ДЗ № 11,12

- [Создание docker host] Основное ДЗ
- [Создание своего образа] Основное ДЗ
- [Работа с Docker Hub] Основное ДЗ

## В процессе сделано:

- Пункт 1
  Установлены docker desktop ( https://docs.docker.com/desktop/install), а также docker-machine (https://github.com/docker/machine)
  Далее освоены команды управления docker :

  ``` docker ps (-a), docker images, docker run/start/attach/create, docker rm/rmi, docker kill, docker commit ```
  
  В файле docker-monolith/docker-1.log сохранен вывод команды docker images после упражнений первой части ДЗ

- Пункт 2
  Настроена конфигурация YC для работы с docker-machine - создан инстанс YC + docker-host в YC:
  
  ```
   yc compute instance create \
  --name docker-host \
  --zone ru-central1-a \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1804-lts,size=15 \
  --ssh-key ~/.ssh/yc-user.pub
  ```
  
  ```
  docker-machine create \
  --driver generic \
  --generic-ip-address=51.250.92.188 \
  --generic-ssh-user yc-user \
  --generic-ssh-key ~/.ssh/yc-user \
  docker-host
  ```
  
  Переключение для управления docker на хостовой виртуалке и обратно на локальный выполняется двумя командами:
  
  ```
  eval $(docker-machine env docker-host)
  eval $(docker-machine env --unset)
  ```
  
  С помощью docker-compose создан образ приложения reddit42 (файлы DockerFile, mongod.conf,  start.sh в директории docker-monolith)
  В файле DockerFile bundle ставится из репозитория пакетов ubuntu с помощью apt-get install аналогично другим пакетам без использования gem install (gem install не отработал в контейнере)
  
  ```
  RUN apt-get install -y mongodb-server ruby-full ruby-dev build-essential git bundler
  ```

  На основе полученного образа на порту 9292 поднят контейнер reddit, который запускает приложение reddit42.
  Для получение сообщений логов контейнера были использованы команды
  ```
  docker events& (выполняется перед docker run)
  docker logs reddit <sha256 hash> (передается идентификатор лога, который выводится на экран в момент выполнения docker run)
  docker logs reddit -f(все логи по reddit)
  ```  
  
- Пункт 3
  Полученный в пункте 2 образ заливается в docker hub:
  
  ```
  docker login
  ...
  docker tag reddit:latest sagrabs/otus-reddit:1.0
  docker push sagrabs/otus-reddit:1.0  
  ```
  
  Выкачивание с docker hub и запуск из локального репозитория :
  
  ```
  eval $(docker-machine env --unset)
  docker run --name reddit -d -p 9292:9292 <your-login>/otus-reddit:1.0
  ```
