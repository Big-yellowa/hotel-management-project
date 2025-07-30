from app import db
import datetime
import hashlib

class User(db.Model):
    __tablename__ = 'user'
    
    user_id = db.Column(db.Integer, primary_key=True, autoincrement=True, comment='唯一标识用户')
    username = db.Column(db.String(50), unique=True, nullable=False, comment='登录用户名')
    password = db.Column(db.String(100), nullable=False, comment='加密后的密码')
    nickname = db.Column(db.String(50), default='游客', comment='显示昵称')
    avatar_url = db.Column(db.String(255), nullable=True, comment='头像图片URL')
    phone = db.Column(db.String(20), unique=True, nullable=False, comment='联系电话')
    register_time = db.Column(db.DateTime, default=datetime.datetime.now, comment='注册时间')
    status = db.Column(db.SmallInteger, default=1, comment='1=正常，0=封禁')
    
    # 密码加密方法
    def set_password(self, password):
        # 使用MD5加密密码
        md5 = hashlib.md5()
        md5.update(password.encode('utf-8'))
        self.password = md5.hexdigest()
        
    # 密码验证方法
    def check_password(self, password):
        md5 = hashlib.md5()
        md5.update(password.encode('utf-8'))
        return self.password == md5.hexdigest()
