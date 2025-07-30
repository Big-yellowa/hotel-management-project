from flask import Blueprint, request, jsonify
from app import db
from app.models.user import User
import re

auth_bp = Blueprint('auth', __name__)

# 注册接口
@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # 验证数据
    if not all(k in data for k in ('phone', 'password', 'username')):
        return jsonify({'code': 400, 'message': '请填写完整信息'})
    
    # 验证手机号格式
    if not re.match(r'^1[3-9]\d{9}$', data['phone']):
        return jsonify({'code': 400, 'message': '手机号格式不正确'})
    
    # 验证用户名是否已存在
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'code': 400, 'message': '用户名已存在'})
    
    # 验证手机号是否已注册
    if User.query.filter_by(phone=data['phone']).first():
        return jsonify({'code': 400, 'message': '手机号已注册'})
    
    # 创建新用户
    user = User()
    user.username = data['username']
    user.phone = data['phone']
    user.set_password(data['password'])  # 加密密码
    
    try:
        db.session.add(user)
        db.session.commit()
        return jsonify({
            'code': 200,
            'message': '注册成功',
            'data': {
                'user_id': user.user_id,
                'username': user.username,
                'nickname': user.nickname
            }
        })
    except Exception as e:
        db.session.rollback()
        return jsonify({'code': 500, 'message': f'注册失败: {str(e)}'})

# 登录接口
@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    
    # 验证数据
    if not all(k in data for k in ('username', 'password')):
        return jsonify({'code': 400, 'message': '请填写账号和密码'})
    
    # 查询用户
    user = User.query.filter_by(username=data['username']).first()
    
    # 验证用户
    if not user:
        return jsonify({'code': 401, 'message': '用户名或密码错误'})
    
    # 验证密码
    if not user.check_password(data['password']):
        return jsonify({'code': 401, 'message': '用户名或密码错误'})
    
    # 验证账号状态
    if user.status != 1:
        return jsonify({'code': 403, 'message': '账号已被封禁'})
    
    return jsonify({
        'code': 200,
        'message': '登录成功',
        'data': {
            'user_id': user.user_id,
            'username': user.username,
            'nickname': user.nickname,
            'avatar_url': user.avatar_url
        }
    })
