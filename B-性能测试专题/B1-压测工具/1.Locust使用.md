# Locust使用

### 通过pip方式安装

```
$ python -m pip install locustio
```

> 注意，这里安装完之后locust命令并未加入环境变量，在这里/Users/enbowang/Library/Python/2.7/bin/locust，使用时可以使用绝对路径

### 样例代码

```
from locust import HttpLocust, TaskSet, task

#定义具体用户的行为，进行哪些操作，可以理解为操作池
class UserBehavior(TaskSet):
    @task #代表权重占比，这里只有一个任务，如果有两个可以通过task(n)来控制比重
    def index(self):
        self.client.get("/entrytask?name=wangenbo&price=80&discount=0.9")

#对每个用户进行设置，包括行为设置（使用哪个行为池），等待时间设置等        
class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    #最小与最大等待时间，单位ms，在范围内随即等待。定义了一个用户在进行每次操作之间的时间间隔
    min_wait = 1000
    max_wait = 1000
   
```

### web端启动（单机部署，不使用分布式部署）

```
$ /Users/enbowang/Library/Python/2.7/bin/locust -f /Users/enbowang/Documents/entrytask/locust/locusttest.py --host=http://127.0.0.1:8080
```

### 参数解读

> -h: 查看帮助
>
> -H --host: 被测服务器的域名。如这里定义后，脚本中只需要给出uri部分即可；如不给出，需要脚本中指定host
>
> --web-host：locust服务的web界面地址，用于配置 并发量 与 启动量。
>
> --master： 做分布式压测时，标记哪台用做主机。主机只用来做统计，并不用来施压。施压的任务留给slave分机做。
>
> --slave：做分布式压测时，标记哪些用做分机。分机的主要任务是进行施压。
>
> -f：脚本路径。可以写相对路径或是绝对路径。如果是脚本当前目录下，就写相对路径。如果不是，就写绝地路径。
>
> --master-host： 做分布式压测时，指定主机的IP。只用于slave。如果没有指定，默认是本机“127.0.0.1”。
>
> --master-port： 做分布式压测时，指定主机的port。只用于slave。如果没有指定且主机没有修改的话，默认是5557。
>
> --master-bind-host： 做分布式压测时，指定分机IP。只用于master。如果没有指定，默认是所有可用的IP(即所有标记主机IP的slave)
>
> --master-bind-port：做分布式压测时，指定分机port。默认是5557与5558。
>
> --no-web：不带web界面。使用这个参数时，必须指定 -c、-r。
>
> -c： 用户数。
>
> -r： 每秒启动用户数。
>
> -t： 运行时长。在t秒后停止。
>
> -L：打印的日志级别，默认INFO。

PS: 如果参数是以“--”开头，则以=连接实参。例如“--host=http://sample”。如果不是，则以空格连接实参。例如“-H http://sample”

```
locust -f dummy.py --master --no-web -c 10 -r 1 --run-time=10 --expect-slaves=1 \
        --host='http://127.0.0.1' --logfile=locust.log --loglevel=INFO 1>run.log 2>&1
```

