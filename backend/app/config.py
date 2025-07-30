import os

class Config:
    # 数据库配置
    SQLALCHEMY_DATABASE_URI = 'mysql+pymysql://root:123456@localhost/Hotel'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # 密钥配置
    SECRET_KEY = os.environ.get('SECRET_KEY') or '123456'
