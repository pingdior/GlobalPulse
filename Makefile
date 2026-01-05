.PHONY: setup backend frontend api-test

# 初始化环境（安装依赖）
setup:
	cd backend && rm -rf venv && python3.11 -m venv venv && . venv/bin/activate && pip install -r requirements.txt
	cd frontend && flutter pub get

# 启动后端（如果不想使用后台服务）
backend:
	cd backend && . venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

# 启动前端
frontend:
	cd frontend && flutter run -d chrome --web-port=3000

# 测试 API
api-test:
	curl "http://localhost:8000/api/events?enrich=true&limit=1"
