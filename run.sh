#!/bin/bash

# 定义公共函数：打印标题
print_title() {
    clear
    echo "########################################"
    echo "    已选择: $1"
    echo "########################################"
}

# 定义公共函数：启动ComfyUI
start_comfyui() {
    # 公共参数
    local COMMON_ARGS="
    --listen
    --port 8144
    --enable-cors-header '*'
    --base-directory /ComfyUI/base_directory
    --input-directory /ComfyUI/input
    --output-directory /ComfyUI/output
    --temp-directory /ComfyUI/temp
    --extra-model-paths-config /ComfyUI/extra_model_paths_config/extra_model_paths.yaml
    --user-directory /ComfyUI/user
    --disable-auto-launch
    --preview-method none
    --enable-manager
    "

    # 1. 打印完整命令
    # %q 会自动处理引号转义
    echo -n "即将执行: "
    printf "%q " python main.py $COMMON_ARGS "$@"
    echo "" # 最后补个换行

    # 2. 真正执行命令
    cd /ComfyUI/source_code
    ./venv/bin/python main.py $COMMON_ARGS "$@"
}

# 1. 定义提示信息
echo "============================"
echo "    ComfyUI 启动助手"
echo "============================"
echo "1. 普通模式"
echo "2. 低资源模式"
echo "3. 极限兜底模式"
echo "4. 退出"
echo "============================"

# 2. 获取用户输入
# -p 表示提示信息，choice 是变量名
read -p "请输入您的选择 [1-4]: " choice

# 3. 根据输入执行命令 (case 语句)
case $choice in
    1)
        print_title "普通模式"
        start_comfyui
        ;;
    2)
        print_title "低资源模式"
        # TODO 未测试参数，只是做示例
        start_comfyui --bf16-unet --bf16-vae
        ;;
    3)
        print_title "极限兜底模式"
        # TODO 未测试参数，只是做示例
        start_comfyui --fp16-unet --fp16-vae
        ;;
    4)
        echo "退出成功！"
        exit 0
        ;;
    *)
        echo "错误：无效的输入，请输入 1-4 之间的数字。"
        exit 1
        ;;
esac