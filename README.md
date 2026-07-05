# RidePower - 骑行数据分析 App

一个功能完整的骑行数据分析应用，支持从多个平台导入数据、分析运动指标、匹配 Strava 赛段，并上传到行者 App。

## 功能特性

### 📥 数据导入
- **顽鹿运动** - 自动同步顽鹿运动账号数据
- **iGPSSport** - 同步 iGPSSport 设备/账号数据
- **FIT 文件** - 手动导入 FIT 格式文件
- **自动识别** - 智能解析 GPS 轨迹和传感器数据

### 📊 数据分析
- **速度分析** - 平均速度、最高速度、速度曲线图
- **功率分析** - 平均功率、最大功率、功率曲线图
- **心率分析** - 平均心率、最大心率、心率曲线图
- **踏频分析** - 平均踏频、最高踏频
- **海拔分析** - 总爬升、总下降、海拔剖面图

### 🏆 Strava 集成
- **赛段匹配** - 自动匹配 GPS 轨迹与 Strava 赛段
- **PR 追踪** - 追踪个人记录 (Personal Records)
- **排名展示** - 显示赛段排名
- **数据同步** - 与 Strava 双向同步

### ☁️ 数据上传
- **行者 App** - 自动/手动上传活动到行者

## 技术架构

- **框架**: Flutter 3.x
- **状态管理**: Riverpod 2.x
- **本地存储**: Hive
- **HTTP**: Dio
- **图表**: fl_chart
- **地图**: flutter_map

## 开始使用

### 前置要求

1. **Flutter SDK 3.24+**
   ```bash
   # 如果还没安装 Flutter，请先安装
   # Windows: https://docs.flutter.dev/get-started/install/windows
   # macOS: https://docs.flutter.dev/get-started/install/macos
   ```

2. **Android Studio** (用于 Android 开发)
   - 安装 Android SDK
   - 配置 Android 模拟器或连接真机

### 安装步骤

1. **克隆项目**
   ```bash
   cd ride_analyzer
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **运行应用**
   ```bash
   # 开发模式
   flutter run
   
   # 发布 APK
   flutter build apk --release
   ```

### 配置第三方服务

#### Strava API

1. 访问 [Strava Developers](https://www.strava.com/settings/api)
2. 创建应用程序，获取 Client ID 和 Client Secret
3. 在 `lib/core/constants/app_constants.dart` 中更新：
   ```dart
   static const String stravaClientId = 'YOUR_STRAVA_CLIENT_ID';
   static const String stravaClientSecret = 'YOUR_STRAVA_CLIENT_SECRET';
   ```

#### 顽鹿运动 / iGPSSport

这些服务可能需要逆向工程或官方 API 访问权限，请确保您有权访问相关数据。

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── app.dart                  # App 配置
├── core/                     # 核心模块
│   ├── constants/           # 常量定义
│   ├── theme/              # 主题配置
│   └── utils/               # 工具函数
├── data/                    # 数据层
│   ├── models/             # 数据模型
│   ├── datasources/        # 数据源
│   └── repositories/        # 数据仓库
├── domain/                  # 领域层
│   └── entities/           # 实体
└── presentation/            # 表现层
    ├── screens/            # 页面
    ├── widgets/            # 组件
    └── providers/          # Riverpod providers
```

## TODO

- [ ] 实现顽鹿运动 API 对接
- [ ] 实现 iGPSSport API 对接
- [ ] 实现行者 App 上传功能
- [ ] 添加数据导出功能 (GPX, TCX)
- [ ] 添加活动分享功能
- [ ] 添加骑行路线规划
- [ ] 添加数据统计和趋势分析
- [ ] 支持 Apple Watch / Wear OS

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！
