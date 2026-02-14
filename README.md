# ComfyUI-Docker-ENV

## 起因

本地部署ComfyUI有如下方式，最终挑选手动安装。

| 方式 | 优点 | 缺点 |
| --- | --- | --- |
| [桌面版](https://docs.comfy.org/zh-CN/installation/desktop/windows) | 独立安装 | 不能挑Python版本； 默认不是最新版ComfyUI|
| [便携版](https://github.com/Comfy-Org/ComfyUI/releases) | 绿色运行 | 不能挑Python版本 |
| [手动安装](https://github.com/Comfy-Org/ComfyUI#nvidia) | 跨平台; 可挑Python版本 | 需要手动安装Python和PyTorch |

**为什么手动安装**

1. ComfyUI有些自定义节点，需要安装Python模块，有些Python模块会限定Python版本。
1. Windows有些算子不支持，需要在Linux上运行。

## 准备Docker环境

### 基础镜像

我尝试的基础镜像有：

| 镜像 | 说明 | 缺陷 |
| --- | --- | --- |
| `pytorch/pytorch:2.10.0-cuda13.0-cudnn9-runtime` | 包含PyTorch 2.10.0和CUDA 13.0 | 安装ComfyUI的依赖时，总是报hash异常，无法解决 |
| `python:3.12` | 包含Python 3.12 | 不包含PyTorch，需要手动安装 |

所以最终选择了`python:3.12`作为基础镜像。

### 镜像原则

1. 基础代码通过绑定挂载的方式，克隆在宿主目录，运行在容器内。这样保持了代码的可维护性。
1. 自定义节点、输入、输出、模型等目录，通过绑定挂载的方式，保存在宿主目录，方便管理。

## 部署ComfyUI

### 克隆ComfyUI代码

在宿主目录下，执行如下命令，克隆ComfyUI代码到`source_code`目录。

```bash
git clone https://github.com/Comfy-Org/ComfyUI.git source_code
```

### 复制ComfyUI启动脚本到`start`目录

在宿主目录下，把本项目的`run.sh`脚本复制到`start`目录。

### 复制extra_model_paths.yaml到`extra_model_paths_config`目录

在宿主目录下，把本项目的`extra_model_paths.yaml`脚本复制到`extra_model_paths_config`目录。

### 以基础镜像构建一个镜像，挂载ComfyUI代码目录，安装ComfyUI依赖

```bash
docker buildx build -f Dockerfile_ComfyUI_Init -t comfyui_image:0.0.1 .
```

### 运行有自动安装依赖的容器

在宿主目录下，执行如下命令，运行有自动安装依赖的容器。

```bash
docker run `
    --name ComfyUI_Container `
    -itd `
    --mount type=bind,source=E:\ComfyUI_runtime\source_code,target=/ComfyUI/source_code `
    comfyui_image:0.0.1
```

### 安装依赖

#### 进入容器

在宿主目录下，执行如下命令，进入容器。

```bash
docker exec -it ComfyUI_Container /bin/bash
```

#### 安装依赖

在容器内，执行如下命令，安装ComfyUI依赖。

```bash
cd /ComfyUI/source_code
python -m venv venv
./venv/bin/python -m pip install --upgrade "pip>=25.2"
./venv/bin/pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu130 --resume-retries 999999
./venv/bin/pip install -r requirements.txt --resume-retries 999999
```

### 提交镜像

```bash
docker commit ComfyUI_Container comfyui_image:0.0.2
```

### 生成最终镜像

```bash
docker buildx build -f Dockerfile_ComfyUI_FUll -t comfyui_image:1.0.0 .
```

### 运行ComfyUI容器

在宿主目录下，执行如下命令，运行ComfyUI容器。

```bash
$host_comfyui_runtime_dir = "E:\ComfyUI_runtime"
$container_comfyui_dir = "/ComfyUI"

docker run `
    --name ComfyUI_Container `
    -itd `
    --gpus all `
    -p 8144:8144 `
    --mount type=bind,source=$host_comfyui_runtime_dir\source_code,target=$container_comfyui_dir/source_code `
    --mount type=bind,source=$host_comfyui_runtime_dir\base_directory,target=$container_comfyui_dir/base_directory `
    --mount type=bind,source=$host_comfyui_runtime_dir\input,target=$container_comfyui_dir/input `
    --mount type=bind,source=$host_comfyui_runtime_dir\output,target=$container_comfyui_dir/output `
    --mount type=bind,source=$host_comfyui_runtime_dir\temp,target=$container_comfyui_dir/temp `
    --mount type=bind,readonly,source=$host_comfyui_runtime_dir\extra_model_paths_config,target=$container_comfyui_dir/extra_model_paths_config `
    --mount type=bind,readonly,source=E:\AI_Sources\models,target=$container_comfyui_dir/models `
    --mount type=bind,source=$host_comfyui_runtime_dir\user,target=$container_comfyui_dir/user `
    --mount type=bind,source=$host_comfyui_runtime_dir\start,target=$container_comfyui_dir/start `
    comfyui_image:1.0.0
```

### 给普通用户授权便于安装依赖

在宿主目录下，执行如下命令，给普通用户授权便于安装依赖。

```bash
docker exec -u 0 -it 1bdca83a8186 chown -R comfyuser_1:comfyuser_group /ComfyUI/source_code/venv
```

1bdca83a8186: 容器ID
comfyuser_1: 普通用户
comfyuser_group: 普通用户组

### 进入ComfyUI容器
在宿主目录下，执行如下命令，进入ComfyUI容器。

```bash
docker exec -it ComfyUI_Container /bin/bash
```

### 启动ComfyUI

在容器内，执行如下命令，启动ComfyUI。
```bash
/ComfyUI/start/run.sh
```

## 维护环境

### 提交镜像

容器做过修改后，需要提交镜像。注意修改镜像标签。

```bash
docker commit ComfyUI_Container comfyui_image:X.Y.Z
```

### 备份镜像

备份镜像到本地文件系统。

```bash
docker save -o comfyui_image_X.Y.Z.tar comfyui_image:X.Y.Z
```