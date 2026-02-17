# WSL2 环境下的 ComfyUI 运行

## 起因

Docker 对 Windows 的 bind mount 性能较差，特别是挂载大量小文件时。
直接的影响在 ComfyUI 启动时，会导致较长的等待时间去加载自定义节点。

## 部署流程

### 修改WSL2配置

请在 Windows 中创建或编辑文件：%UserProfile%\.wslconfig（即 C:\Users\<你的用户名>\.wslconfig），填入本项目的wslconfig文件内容。

### 安装发行版

在 WSL2 环境下，安装 Ubuntu 发行版。
可以通过 Microsoft Store 安装，也可以通过命令行安装。

```bash
wsl --install -d Ubuntu-24.04 --web-download
```

安装成功后会提示输入用户名和密码。
用户名comfyuser_1
密码******

### 迁移发行版

WSL2 发行版的“系统盘”（虚拟硬盘）默认在C:\Users\<你的用户名>\AppData\Local\Packages\<发行版包名>\LocalState\ext4.vhdx。

如果C盘空间不足，建议将发行版迁移到其他磁盘。

#### 导出发行版

为了后续的快速部署，建议导出当前的发行版为一个新的 tar 文件。

```bash
wsl --export Ubuntu-24.04 Ubuntu-24.04.tar
```

#### 导入发行版

在新的磁盘上导入导出的 tar 文件。

```bash
wsl --import Ubuntu-24.04-ComfyUI E:\ComfyUI-WSL2 Ubuntu-24.04.tar
```

### 进入发行版

```bash
wsl -d Ubuntu-24.04-ComfyUI --user comfyuser_1
```

### 修改wsl.conf文件

```bash
sudo chmod -R 777 /etc/wsl.conf
```

在发行版中，修改/etc/wsl.conf文件为项目的wsl.conf文件。

### 修改fstab文件

```bash
sudo chmod -R 777 /etc/fstab
```

在发行版中，修改/etc/fstab文件为项目的fstab文件。

### 修改pip.conf文件

在发行版中，修改~/.pip/pip.conf文件为项目的pip.conf文件。

### 安装 pip 和 venv

在发行版中，安装 pip 和 venv。

```bash
# 更新软件包列表
sudo apt update

# 安装 pip 和 venv 模块
sudo apt install -y python3-pip python3-venv

```

### 创建项目目录

在发行版中，创建项目目录。

```bash
# 创建项目目录
mkdir -p ~/ComfyUI
mkdir -p ~/ComfyUI/base-directory
mkdir -p ~/ComfyUI/base-directory/custom_nodes
```

### 符号链接宿主目录

在发行版中，创建符号链接，指向宿主目录。

```bash
# 创建符号链接
ln -s /mnt/e/ComfyUI_runtime/input ~/ComfyUI/input
ln -s /mnt/e/ComfyUI_runtime/output ~/ComfyUI/output
ln -s /mnt/e/ComfyUI_runtime/temp ~/ComfyUI/temp
ln -s /mnt/e/ComfyUI_runtime/extra_model_paths_config ~/ComfyUI/extra_model_paths_config
ln -s /mnt/e/AI_Sources/models ~/ComfyUI/models
ln -s /mnt/e/ComfyUI_runtime/user ~/ComfyUI/user
ln -s /mnt/e/ComfyUI_runtime/start ~/ComfyUI/start
```

### 在WSL中克隆ComfyUI代码

在WSL发行版中，执行如下命令，克隆ComfyUI代码到`code`目录。

```bash
git clone https://github.com/Comfy-Org/ComfyUI.git ~/ComfyUI/source_code
```

### 复制ComfyUI启动脚本到`start`目录

在宿主目录下，把本项目的`run_wsl.sh`脚本复制到`start`目录。

### 复制extra_model_paths.yaml到`extra_model_paths_config`目录

在宿主目录下，把本项目的`extra_model_paths.yaml`脚本复制到`extra_model_paths_config`目录。

### 在WSL中安装ComfyUI依赖

```bash
# 创建虚拟环境
python3 -m venv ~/ComfyUI/source_code/venv

# 升级pip
~/ComfyUI/source_code/venv/bin/python -m pip install --upgrade "pip>=25.2"

# 安装ComfyUI依赖
~/ComfyUI/source_code/venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 --resume-retries 999999

~/ComfyUI/source_code/venv/bin/pip install -r ~/ComfyUI/source_code/requirements.txt --resume-retries 999999

~/ComfyUI/source_code/venv/bin/pip install -r ~/ComfyUI/source_code/manager_requirements.txt --resume-retries 999999
```

### 启动ComfyUI

在容器内，执行如下命令，启动ComfyUI。
```bash
~/ComfyUI/start/run_wsl.sh
```

### 备份环境

```bash
wsl --export Ubuntu-24.04-ComfyUI Ubuntu-24.04-ComfyUI.tar
```

### 恢复环境

```bash
wsl --import Ubuntu-24.04-ComfyUI E:\ComfyUI-WSL2 Ubuntu-24.04-ComfyUI.tar
```
