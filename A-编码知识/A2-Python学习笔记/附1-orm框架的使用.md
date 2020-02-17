# orm框架 sqlalchemy

## python SQLAlchemy自动生成models文件‌

1.安装SQLAcodegen  

```
pip install sqlacodegen
```

2.执行

```
sqlacodegen mysql://root:123456@127.0.0.1:3306/test > models.py
#会在当前目录下生成models.py
```

3.如果是python3  会报错 No module named 'MySQLdb'

这个时候安装pymysql。然后在sqlacodegen 的__init__.py文件里加上

```python
import pymysql
pymysql.install_as_MySQLdb()
#再次执行，成功
```

## orm引擎使用

demo程序如下

```python
from sqlalchemy.orm import sessionmaker
from sqlalchemy import create_engine
from ITEAlib.db_models import MerchantInfoTab


class MysqlEngine(object):
    def __init__(self,ip,port,user,passwd,db,tunnel_ip=""):
        self.db_ip = ip
        self.db_port = port
        self.db_user = user
        self.db_pwd = passwd
        self.db_db = db
        self.tunnel_ip = tunnel_ip
    def create(self):
        # 创建引擎
        self.engine = create_engine(
            "mysql+pymysql://%s:%s@%s:%s/%s?charset=utf8"%(self.db_user,self.db_pwd,self.db_ip,self.db_port,self.db_db),
            max_overflow=0,  # 超过连接池大小外最多创建的连接
            pool_size=5,  # 连接池大小
            pool_timeout=30,  # 池中没有线程最多等待的时间，否则报错
            pool_recycle=-1  # 多久之后对线程池中的线程进行一次连接的回收（重置）
        )


        # 根据引擎创建session工厂
        self.SessionFactory = sessionmaker(bind=self.engine)
        self.session = self.SessionFactory()
        return self.session


    def close(self):
        self.session.close()
        self.engine.dispose()
        self.dbcn.tunnel_stop()


if __name__ == "__main__":
    e = MysqlEngine(ip="127.0.0.1", port=1234, user="xxx", passwd="xxx", db="airpay_merchant_info_id_db",tunnel_ip="192.168.0.1")
    session = e.create()


    result = session.query(UsersInfoTab).all()
    for row in result:
        print(row.uid, row.name)


    result = session.query(MerchantInfoTab).filter(UsersInfoTab.uid = xxx).first()
    for row in result:
        print(row.id,row.name)


    e.close()
```







‌