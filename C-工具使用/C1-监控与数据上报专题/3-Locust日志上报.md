# 数据上报|Locust->InfluxDB

```python
import subprocess
import re
import os


def main():
    # 实时读取日志信息
    shell = 'tail -F ../log/run.log'
    p = subprocess.Popen(shell, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    for line in iter(p.stdout.readline, b''):
        line = line.rstrip().decode('utf8')
        #print(line)

        # 正则匹配获取所有的需要参数
        res = re.match(
            r'^\s+(?P<method>http|grpc)\s+(?P<api>[\/\w\?\=\&]+)\s+(?P<reqs>\d+)\s+(?P<fails>[\d\(\.\)\%]+)\s+(?P<Avg>\d+)\s+(?P<Min>\d+)\s+(?P<Max>\d+)\s+(\|)\s+(?P<Median>\d+)\s+(?P<QPS>[\w\.]+)$',
            line)
        if res:
            print("method: %s, api: %s, reqs: %s, fails: %s, Avg: %s, Min: %s, Max: %s, Median: %s, QPS: %s " % (
                res.group('method'), res.group('api'), res.group('reqs'), res.group('fails').split('(')[0],
                res.group('Avg'),
                res.group('Min'), res.group('Max'), res.group('Median'), res.group('QPS')
            ))

            # 设置需要写入influxdb的参数
            method = res.group('method')
            api = res.group('api')
            reqs = res.group('reqs')
            fails = res.group('fails').split('(')[0]
            avg = res.group('Avg')
            min = res.group('Min')
            max = res.group('Max')
            median = res.group('Median')
            qps = res.group('QPS')

            # 往influxdb写入数据
            # 创建数据库 curl -i -XPOST http://localhost:8086/query --data-urlencode "q=CREATE DATABASE testdb"
            # 插入数据
            #                                                                       表名   索引 tag              字段 fields
            # curl -i -XPOST 'http://localhost:8086/write?db=testdb' --data-binary 'locust,method=GET,api=/apis reqs=2099,fails=10,avg=20,min=5,max=83,median=16,qps=95.10'
            database = 'mydb'
            table_name = 'locust_data'
            insert_data = "curl -i -XPOST 'http://localhost:8086/write?db=%s' --data-binary '%s,method=%s,api=%s reqs=%s,fails=%s,avg=%s,min=%s,max=%s,median=%s,qps=%s'" % (
            database, table_name, method, api, reqs, fails, avg, min, max, median, qps)
            os.system(insert_data)


if __name__ == '__main__':
    main()
```