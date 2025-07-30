from flask import Blueprint, request, jsonify, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from app import db
from app.models.user import User
from app.config import Config
import os
import uuid

user_bp = Blueprint('user', __name__)

@user_bp.route('/info', methods=['GET'])
@jwt_required()
def get_user_info():
    """获取当前用户信息"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': '用户不存在'}), 404
    
    return jsonify(user.to_dict()), 200

@user_bp.route('/info', methods=['PUT'])
@jwt_required()
def update_user_info():
    """更新用户信息（昵称和头像URL）"""
    user_id = get_jwt_identity()
    user = User.query.get(user_id)
    
    if not user:
        return jsonify({'error': '用户不存在'}), 404
    
    data = request.get_json()
    
    # 更新昵称
    if 'nickname' in data:
        user.nickname = data['nickname']
    
    # 更新头像URL
    if 'avatarUrl' in data:
        user.avatar_url = data['avatarUrl']
    
    db.session.commit()
    
    return jsonify({
        'message': '信息更新成功',
        'user': user.to_dict()
    }), 200

@user_bp.route('/avatar', methods=['POST'])
@jwt_required()
def upload_avatar():
    """上传用户头像"""
    # 检查是否有文件上传
    if 'avatar' not in request.files:
        return jsonify({'error': '未上传文件'}), 400
    
    file = request.files['avatar']
    
    # 检查文件是否有效
    if file.filename == '':
        return jsonify({'error': '未选择文件'}), 400
    
    # 验证文件类型
    if not file or not allowed_file(file.filename):
        return jsonify({'error': '只允许上传图片文件 (jpg, jpeg, png, gif)'}), 400
    
    # 生成唯一的文件名，避免冲突
    filename = str(uuid.uuid4()) + os.path.splitext(file.filename)[1]
    file_path = os.path.join(Config.UPLOAD_FOLDER, filename)
    
    # 保存文件
    file.save(file_path)
    
    # 返回头像的URL
    avatar_url = f'/api/user/avatars/{filename}'
    
    return jsonify({
        'message': '头像上传成功',
        'avatarUrl': avatar_url
    }), 200

@user_bp.route('/avatars/<filename>')
def get_avatar(filename):
    """获取头像图片"""
    return send_from_directory(Config.UPLOAD_FOLDER, filename)

def allowed_file(filename):
    """检查文件是否为允许的图片类型"""
    allowed_extensions = {'png', 'jpg', 'jpeg', 'gif'}
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in allowed_extensions
