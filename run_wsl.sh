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
    --base-directory $HOME/ComfyUI/base-directory
    --input-directory $HOME/ComfyUI/input
    --output-directory $HOME/ComfyUI/output
    --temp-directory $HOME/ComfyUI/temp
    --extra-model-paths-config $HOME/ComfyUI/extra_model_paths_config/extra_model_paths.yaml
    --user-directory $HOME/ComfyUI/user
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
    $HOME/ComfyUI/source_code/venv/bin/python $HOME/ComfyUI/source_code/main.py $COMMON_ARGS "$@"
}

while true; do
    echo "============================"
    echo "    ComfyUI 启动助手"
    echo "============================"
    echo "1. 普通模式"
    echo "2. 低资源模式"
    echo "3. 极限兜底模式"
    echo "4. 退出"
    echo "============================"

    read -p "请输入您的选择 [1-4]: " choice

    case $choice in
        1|2|3)
            break
            ;;
        4)
            echo "退出成功！"
            exit 0
            ;;
        *)
            echo "错误：无效的输入，请输入 1-4 之间的数字。"
            echo ""
            ;;
    esac
done

VERBOSE_ARG=""
while true; do
    read -p "是否启用 Verbose? [y/N]: " verbose_choice
    case $verbose_choice in
        [Yy]*)
            VERBOSE_ARG="--verbose"
            break
            ;;
        [Nn]*|"")
            break
            ;;
        *)
            echo "错误：无效的输入，请输入 y 或 n。"
            echo ""
            ;;
    esac
done

case $choice in
    1)
        print_title "普通模式"
        start_comfyui $VERBOSE_ARG
        ;;
    2)
        print_title "低资源模式"
        # TODO 未测试参数，只是做示例
        start_comfyui --bf16-unet --bf16-vae $VERBOSE_ARG
        ;;
    3)
        print_title "极限兜底模式"
        # TODO 未测试参数，只是做示例
        start_comfyui --fp16-unet --fp16-vae $VERBOSE_ARG
        ;;
esac