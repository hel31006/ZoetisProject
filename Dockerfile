# 使用官方的 Python 3.10 完整版镜像作为基础环境
FROM python:3.10

# 在容器内部设置工作目录为 /app
WORKDIR /app

# 新增：安装 ffmpeg 和 ca-certificates 系统依赖
# ffmpeg 用于音频处理, ca-certificates 用于 SSL 连接验证
RUN apt-get update && apt-get install -y ffmpeg ca-certificates

# 设置 Hugging Face 库的缓存目录环境变量
ENV HF_HOME /app/huggingface_cache

# 先复制依赖文件，以便利用 Docker 的构建缓存
COPY requirements.txt requirements.txt

# 安装所有 Python 依赖库
RUN pip install --no-cache-dir -r requirements.txt

# 创建所有应用所需的文件夹并赋予写入权限
RUN mkdir -p /app/uploads /app/models_cache /app/huggingface_cache && \
    chmod -R 777 /app/uploads /app/models_cache /app/huggingface_cache

# 将您项目中的所有其他代码文件复制到工作目录
COPY . .

# 暴露 Gunicorn 将要运行的端口
EXPOSE 7860

# 定义容器启动时要运行的命令
CMD ["gunicorn", "--bind", "0.0.0.0:7860", "--timeout", "600", "app:app"]