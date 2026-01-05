# GlobalPulse AI (全球脉动)

> 穿透信息茧房，解码全球情绪

GlobalPulse 是一个面向出海创业者、创作者及研究者的全球舆情分析工具。

## 🚀 快速开始

### 环境要求

- Python 3.11+
- Flutter 3.16+
- Node.js 18+ (可选)

### 后端启动

```bash
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # macOS/Linux
# venv\Scripts\activate  # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量
cp .env.example .env
# 编辑 .env 填入你的 API Keys

# 启动开发服务器
uvicorn app.main:app --reload
```

API 文档访问：http://localhost:8000/docs

### 前端启动

```bash
cd frontend

# 获取依赖
flutter pub get

# 运行应用
flutter run
```

## 📁 项目结构

```
GlobalPulse/
├── backend/          # Python 后端 (FastAPI)
│   ├── app/
│   │   ├── api/      # API 路由
│   │   ├── crawlers/ # 数据采集
│   │   ├── models/   # 数据模型
│   │   └── services/ # 业务服务
│   └── tests/        # 测试
├── frontend/         # Flutter 应用
└── docs/            # 文档
```

## 🔧 API 接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET | `/api/events` | 获取热点事件列表 |
| GET | `/api/events/{id}` | 获取事件详情 |
| POST | `/api/events/{id}/enrich` | LLM 增强事件 |

## 📝 开发文档

- [产品需求文档](docs/prd.md)
- [开发指南](docs/gemini.md)

## 📄 License

MIT License
