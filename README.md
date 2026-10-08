# WO-Management · 工单管理系统

基于 HarmonyOS（ArkTS / ArkUI）的工单管理应用，覆盖工单流转、质量检验、产线数据与多角色协同，面向工厂/生产场景的日常作业管理。

> 说明：仓库根目录另附《认养农业数字化管理与生长数据可视化系统需求文档.md》（毕业设计需求文档，供归档参考）。

## 功能特性

按角色划分工作台与操作权限：

- **管理员（Admin）**：工单管理、用户管理、数据总览、质量概览
- **领导（Leader）**：工单查看与创建、工作台与数据看板
- **检验员（Inspector）**：质检检验、检验记录、缺陷登记、质量报表与趋势
- **操作员（Operator）**：工单任务处理、产线/工作站作业

核心模块：

| 模块 | 说明 |
| --- | --- |
| login | 账号登录 |
| workbench | 多角色工作台 |
| workorder | 工单创建 / 复制 / 详情 / 任务流转 |
| quality | 质检、缺陷、报表、趋势 |
| data | 产线、工作站及多角色数据视图 |
| my | 个人中心与用户管理 |

## 技术栈

- 语言 / 框架：ArkTS（ArkUI）
- 系统：HarmonyOS 6.0.1（API 21）
- 架构：多模块工程（HAR），MVVM（View / ViewModel / Model 分层）
- 构建：hvigor + ohpm

## 目录结构

```
WO-Management/
├── AppScope/            # 应用级配置（bundle、版本、图标）
├── commons/             # 公共能力
│   ├── datastore/       # 数据存储
│   ├── network/         # 网络请求
│   ├── uicomponents/    # 公共 UI 组件
│   └── utils/           # 工具类
├── features/            # 业务功能模块
│   ├── login/           # 登录
│   ├── workbench/       # 工作台
│   ├── workorder/       # 工单管理
│   ├── quality/         # 质量管理
│   ├── data/            # 数据视图
│   └── my/              # 我的 / 用户管理
├── products/            # 产品工程
│   └── phone/           # 手机 / 平板端应用入口
├── build-profile.json5  # 工程构建配置
└── hvigorfile.ts        # hvigor 构建脚本
```

## 环境要求

- DevEco Studio（支持 HarmonyOS API 21）
- HarmonyOS SDK 6.0.1（API 21）
- ohpm 包管理器

## 快速开始

1. 克隆仓库：

```bash
git clone https://github.com/neko661/WO-Management.git
```

2. 使用 DevEco Studio 打开工程根目录，等待依赖同步（ohpm install）。
3. 连接 HarmonyOS 模拟器或真机，点击 Run 运行应用。

## License

个人学习 / 毕业设计项目，开源协议待定。
