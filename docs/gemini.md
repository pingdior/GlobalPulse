# GlobalPulse AI 项目开发指南

## 1. 项目概述
请按照 `prd.md` 中的需求，完成 GlobalPulse（全球脉动）的开发。
- 若你对需求有疑问，请及时与我沟通
- 如有更优的解决方案或技术栈建议，请提出讨论

---

## 2. 技术栈

### 2.1 数据采集层 (The Tentacles)
| 技术 | 用途 |
|------|------|
| Python (Scrapy/Selenium) | 网页爬虫与数据采集 |
| X Enterprise API | Twitter/X 数据获取 |
| Reddit API | Reddit 数据获取 |
| RSS Hub | 媒体订阅源 |
| 代理池 (Proxy Rotation) | 反爬虫规避 |
| OCR 技术 | 图片文字识别 |

### 2.2 智能处理层 (The Brain)
| 技术 | 用途 |
|------|------|
| gpt-4o-mini / DeepSeek | 多语言翻译与文本清洗 |
| LangChain | 自动化报告生成 |
| VADER / Bert | NLP 情感分析 |
| LLM Clustering | 叙事聚类提取 |

### 2.3 应用层 (The Face)
| 技术 | 用途 |
|------|------|
| Flutter | iOS/Android 双端开发 |
| Mapbox GL JS | 地图交互与热力图渲染 |
| TTS (语音合成) | 播客脚本生成 |

---

## 3. AI 开发模型选择

| 任务类型 | 首选模型 | 备选模型 |
|----------|----------|----------|
| 架构与后端开发 | Claude Opus 4.5 (thinking) | Gemini 3 Pro (High) |
| 前端开发 | Gemini 3 Pro (High) | Claude Sonnet 4.5 (thinking) |
| 单元测试 & 功能测试 | Claude Sonnet 4.5 (thinking) | - |
| 疑难问题攻关 | Claude Opus 4.5 (thinking) | - |

> **注意**: 遇到无法解决的问题时，优先切换到 Claude Opus 4.5 (thinking) 模式进行分析。

---

## 4. 项目架构规范

### 4.1 目录结构
```
GlobalPulse/
├── docs/                   # 文档
│   ├── prd.md             # 产品需求文档
│   └── gemini.md          # 开发指南
├── src/
│   ├── data_collection/   # 数据采集层
│   │   ├── crawlers/      # 各平台爬虫
│   │   ├── apis/          # API 接口封装
│   │   └── proxies/       # 代理池管理
│   ├── intelligence/      # 智能处理层
│   │   ├── translation/   # 翻译模块
│   │   ├── sentiment/     # 情感分析
│   │   └── clustering/    # 叙事聚类
│   └── app/               # 应用层 (Flutter)
│       ├── lib/           # 核心代码
│       ├── assets/        # 静态资源
│       └── test/          # 测试文件
├── config/                 # 配置文件
│   ├── .env.example       # 环境变量模板
│   └── proxies.yaml       # 代理池配置
├── tests/                  # 测试目录
│   ├── unit/              # 单元测试
│   ├── integration/       # 集成测试
│   └── reports/           # 测试报告
├── README.md
├── CHANGELOG.md
├── LICENSE.md
├── CODE_OF_CONDUCT.md
└── SECURITY.md
```

### 4.2 配置管理
- **敏感信息**: 所有 API 密钥、代理配置等存放于 `.env` 文件，禁止提交到 Git
- **配置模板**: 提供 `.env.example` 作为配置模板

---

## 5. 开发流程规范

### 5.1 Git 工作流
- **主分支**: `main` (生产环境), `develop` (开发环境)
- **功能分支命名**: `feature/<模块>-<功能描述>`
  - 示例: `feature/crawler-weibo`, `feature/ui-heatmap`
- **修复分支命名**: `fix/<问题描述>`
- **发布分支命名**: `release/v<版本号>`

### 5.2 提交规范 (Conventional Commits)
```
<type>(<scope>): <description>

feat: 新增功能
fix: 修复 Bug
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建/工具变更
```

### 5.3 代码审核流程
1. 创建 Pull Request，填写 PR 模板
2. 至少 1 人 Code Review 通过
3. CI/CD 测试通过
4. 合并到目标分支

---

## 6. GitHub 协作规范

- [ ] 创建 Issue 记录需求和计划
- [ ] 创建 Pull Request 提交代码
- [ ] 维护 `README.md` - 项目说明
- [ ] 维护 `CHANGELOG.md` - 变更记录
- [ ] 添加 `LICENSE.md` - 开源许可证
- [ ] 添加 `CODE_OF_CONDUCT.md` - 行为准则
- [ ] 添加 `SECURITY.md` - 安全政策

---

## 7. 测试策略

### 7.1 测试类型
| 层级 | 测试内容 | 工具/方法 |
|------|----------|-----------|
| 数据采集层 | 爬虫稳定性、API 响应 | Mock 测试、重试机制验证 |
| 智能处理层 | 翻译准确性、情感分析精度 | 人工抽检、基准对比 |
| 应用层 | UI 交互、功能流程 | Flutter 单元测试、集成测试 |

### 7.2 测试报告
每个功能完成后，生成对应测试报告存放于 `tests/reports/` 目录。

---

## 8. 里程碑计划

| 阶段 | 目标 | 交付物 |
|------|------|--------|
| **MVP** | 单一区域数据采集 + 基础展示 | China 区域热点卡片流 |
| **Alpha** | 7 区域完整覆盖 + 情绪分析 | 全球热力图 + 情绪光谱 |
| **Beta** | 跨区域对比 + 报告导出 | 对比分析页 + 多格式导出 |
| **Release** | 性能优化 + 用户反馈迭代 | 正式版本发布 |

---

## 9. API 与数据源管理

### 9.1 数据源覆盖
| 地区 | 主要平台 |
|------|----------|
| 欧美 | X (Twitter), Reddit |
| 中国 | 微博, 小红书 |
| 中东 | Al Jazeera, X |
| 南美 | Instagram, Telegram |
| 东亚 | 本地社交平台 + X |

### 9.2 API 限制与注意事项
- 遵守各平台 API 使用条款和速率限制
- 反爬虫策略：代理池轮换、请求间隔控制
- 数据缓存：避免重复请求，降低 API 成本

---

## 10. 开发原则

1. **功能驱动**: 一个功能一个功能完成
2. **质量优先**: 每个功能完成后进行代码检查、单元测试、功能测试
3. **文档同步**: 代码变更同步更新文档
4. **持续沟通**: 遇到问题及时沟通，不要卡在一个地方太久
