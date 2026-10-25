### MXUI - 嵌入式轻量级桌面环境 


#### ✨ 效果演示

https://www.bilibili.com/video/BV1BVpb6iEeJ/?spm_id_from=333.1007.top_right_bar_window_history.content.click&vd_source=3d3cabf8b42300a387104519b0b81ab0
#### 🚀 核心特性

* **现代化交互 UI**：高度还原 iPadOS 的视觉体验，支持 SwipeView 左右滑动分页、底部 Dock 停靠栏以及沉浸式状态栏。
* **App 路由与生命周期管理**：采用 `Loader` 动态加载/卸载页面（如 Setting, Video, File 等），最大限度节省嵌入式板子的内存。
* **多媒体文件扫描**：利用 `FolderListModel` 自动扫描开发板本地（如 `/home/lv/videos`）的 MP4 文件。
* **零 3D 硬件依赖**：专为工控芯片优化，规避了 QML 原生 `<Video>` 等强制依赖 OpenGL 的组件，确保在纯 CPU 软解平台（如 i.MX6ULL）上稳定运行不崩溃。

#### 🛠️ 技术栈与依赖

* **开发语言**：C++17 / QML
* **UI 框架**：Qt 5.15 (Qt Quick / Qt Quick Controls 2)
* **构建工具**：CMake (最低版本 3.5)
* **目标硬件**：正点原子 i.MX6ULL (ARM Cortex-A7) 或同类嵌入式 Linux 开发板
* **根文件系统**：Buildroot (需勾选 `qt5declarative`, `qt5graphicaleffects`, `qt5multimedia` 等基础模块)

#### 

