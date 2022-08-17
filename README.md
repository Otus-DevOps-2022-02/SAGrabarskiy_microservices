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

# Выполнено ДЗ № 19

- [Разобрать на практике все компоненты Kubernetes, развернуть их
вручную используя kubeadm] Основное ДЗ
- [Разобрать на практике все компоненты Kubernetes, развернуть их
вручную используя kubeadm] Основное ДЗ
- [Опишите установку кластера k8s с помощью terraform и ansible] Дополнительное ДЗ

## В процессе сделано:

- Пункт 1

Подготовлены три инстанса для разворачивания master & worker nodes.
Особенностью подготовки является использование paker(kubernetes/packer/k8s_master.json, kubernetes/packer/k8s_worker.json) + ansible provisioners(kubernetes/ansible/playbooks/packer_k8s_base.yml,kubernetes/ansible/playbooks/packer_k8s_master.yml), на которых уже предустановлены следующие компоненты, необходимые для настройки кластера k8s:

kubernetes-cni, kubectl, kubeadm, kubelet, apt-transport-https

Команды для билда образов: 
```
packer build --var-file=./packer/variables.json ./packer/k8s_master.json
packer build --var-file=./packer/variables.json ./packer/k8s_worker.json
```

Для поднятия инстансов в директории kubernetes/terraform/prod приведен сценарий main.tf с использованием двух модулей: kubernetes\terraform\modules\master\main.tf, kubernetes\terraform\prod\main.tf 

Количество требуемых worker nodes задается переменной yc_instance_app_count(=2):

```
count  = var.yc_instance_app_count
name   = "reddit-worker-k8s${count.index}"
```
Команды для выполения сценариев terraform:
```
terraform init
terraform apply
```

Далее на мастер ноде выполняем инициализацию кластера:

```
kubeadm init --node-name=kubernetes-sagrab-master --apiserver-advertise-address=0.0.0.0 --apiserver-cert-extra-sans=0.0.0.0,127.0.0.1,localhost,84.201.131.61 --pod-network-cidr=10.244.0.0/16
```

После выполнения указанной команды возвращается команда, которую необходимо выполнить для присоединения к кластеру worker ноды.
```
kubeadm join 192.168.10.21:6443 --token 2yrq89.gwrxmx4lv8i47qdw --discovery-token-ca-cert-hash sha256:c06492e952c675051fc60b118d7f3d8d74b9a630b583d774b26664df1021e136 
```

Копируем конфиг в требуемую директорию пользователя, под которым будет выполняться дальнейшая настройка кластера (в нашем случае ubuntu):

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

Проверяем состояние нод кластера:

```
sudo kubectl get nodes

NAME                       STATUS     ROLES           AGE   VERSION
kubernetes-sagrab-master   NotReady   control-plane   19m   v1.24.3
```

Далее подключаем worker node с помощью команды, которая была сгенерирована после завершения kubeadm, выполнив ее на каждой ноде.
Далее скачиваем последний манифест calico для настройки сетевого взаимодействия нод и запускаем конфигурацию:

```
curl https://projectcalico.docs.tigera.io/manifests/calico.yaml -O
sudo kubectl apply -f calico.yaml
```

Проверяем результат (статус nodes поменялся на ready ):

```
sudo kubectl get nodes

NAME                       STATUS   ROLES    AGE     VERSION
fhmrqacc2eiak1b9bl8o       Ready    <none>          10m  v1.24.3
fhmu71msq5pm1maa89gh       Ready    <none>          10m   v1.24.3
kubernetes-sagrab-master   Ready    control-plane   20m   v1.24.3

```

- Пункт 2

```
scp -i ~/.ssh/yc-user /e/SAGrabarskiy_microservices/kubernetes/reddit/post-deployment.yml

```
Применяем деплоймент:

```
kubectl apply /home/ubuntu/post-deployment.yml

```
Проверяем поды:
```
sudo kubectl get pods

NAME                              READY   STATUS    RESTARTS   AGE
post-deployment-799c77ffb-45pgt   1/1     Running   0          36m

```
Удаляем кластер:

```
sudo kubeadm reset
sudo rm -rf ~/.kube
```

- Пункт 3:

В директории ansible добавлено три плейбука, которые обеспечивают запуск операций, описанных в пунктах 1,2 + добавляет хосты

k8s_dns_hosts.yml - прописывает в hosts хосты master и worker (для указания node-name в join_command (k8s_worker_node))
k8s_master_node.yml, k8s_worker_node.yml - настраивает master и worker ноды в соотвествии с kubernets/ansible/inventory
k8s_deployment.yml - запускает post-deployment

Всe плейбуки включены в k8s_config_nodes.yml

NAME                        STATUS   ROLES           AGE     VERSION
kubernetes-sagrab-master    Ready    control-plane   18m     v1.24.3
kubernetes-sagrab-worker1   Ready    <none>          8m54s   v1.24.3
kubernetes-sagrab-worker2   Ready    <none>          4s      v1.24.3

Далее применяем деплоймент соотвествующего плейбука:

```
ansible-playbook playbooks/k8s_deployment.yml

kubectl get pods
NAME                               READY   STATUS    RESTARTS   AGE
post-deployment-6cbc68f776-998p8   1/1     Running   0          26s
```
