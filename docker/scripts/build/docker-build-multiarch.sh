#!/bin/bash
# Docker多架构镜像构建脚本（使用Docker Buildx）

set -e

# 加载公共函数库
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/common.sh"

# 获取目录路径
DOCKER_DIR=$(get_docker_dir)

# 加载多架构环境变量
load_multiarch_env_vars

# 创建或使用现有的构建器
setup_builder() {
    print_info "设置构建器: $BUILDER_NAME"
    
    # 检查构建器是否已存在
    if docker buildx inspect "$BUILDER_NAME" >/dev/null 2>&1; then
        print_info "构建器 $BUILDER_NAME 已存在"
        docker buildx use "$BUILDER_NAME"
    else
        print_info "创建新的构建器: $BUILDER_NAME"
        docker buildx create --name "$BUILDER_NAME" --driver docker-container --use
    fi
    
    # 启动构建器
    docker buildx inspect --bootstrap
    
    print_success "构建器设置完成"
}

# 构建多架构镜像
build_multiarch() {
    print_info "开始构建多架构镜像..."
    echo ""
    echo "=========================================="
    echo "多架构Docker镜像构建"
    echo "=========================================="
    echo "镜像名称: ${IMAGE_NAME}:${IMAGE_TAG}"
    echo "ROS版本:  ${ROS_DISTRO}"
    echo "用户信息: ${USER_NAME} (UID=${USER_UID}, GID=${USER_GID})"
    echo "目标平台: ${TARGET_PLATFORMS}"
    echo "输出类型: ${BUILD_OUTPUT_TYPE}"
    echo "=========================================="
    echo ""
    
    # 构建参数
    BUILD_ARGS=(
        --build-arg "ROS_DISTRO=${ROS_DISTRO}"
        --build-arg "USER_NAME=${USER_NAME}"
        --build-arg "USER_UID=${USER_UID}"
        --build-arg "USER_GID=${USER_GID}"
        --platform "${TARGET_PLATFORMS}"
        --file "${DOCKER_DIR}/Dockerfile"
        --tag "${IMAGE_NAME}:${IMAGE_TAG}"
    )
    
    # 添加缓存参数
    if [ "$BUILD_CACHE" = "true" ]; then
        BUILD_ARGS+=(--cache-from "type=registry,ref=${IMAGE_NAME}:buildcache" --cache-to "type=registry,ref=${IMAGE_NAME}:buildcache,mode=max")
    fi
    
    # 添加输出参数
    case "$BUILD_OUTPUT_TYPE" in
        registry)
            if [ -z "$REGISTRY" ] || [ -z "$REPO_NAME" ]; then
                print_error "当BUILD_OUTPUT_TYPE=registry时，必须设置REGISTRY和REPO_NAME"
                exit 1
            fi
            FULL_IMAGE_NAME="${REGISTRY}/${REPO_NAME}:${IMAGE_TAG}"
            BUILD_ARGS+=(--tag "${FULL_IMAGE_NAME}" --push)
            print_info "将推送到: ${FULL_IMAGE_NAME}"
            ;;
        local)
            BUILD_ARGS+=(--load)
            print_info "将保存到本地Docker镜像存储"
            ;;
        docker)
            if [ "$(echo "$TARGET_PLATFORMS" | wc -w)" -gt 1 ]; then
                print_error "docker输出类型仅支持单平台构建"
                exit 1
            fi
            BUILD_ARGS+=(--load)
            print_info "将加载到本地Docker"
            ;;
        tar)
            if [ -z "$OUTPUT_PATH" ]; then
                print_error "当BUILD_OUTPUT_TYPE=tar时，必须设置OUTPUT_PATH"
                exit 1
            fi
            mkdir -p "$OUTPUT_PATH"
            BUILD_ARGS+=(--output "type=tar,dest=${OUTPUT_PATH}/${IMAGE_NAME}-${IMAGE_TAG}.tar")
            print_info "将导出到: ${OUTPUT_PATH}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
            ;;
        *)
            print_error "未知的输出类型: $BUILD_OUTPUT_TYPE"
            exit 1
            ;;
    esac
    
    # 添加构建超时参数
    if [ -n "$BUILD_TIMEOUT" ]; then
        BUILD_ARGS+=(--timeout "${BUILD_TIMEOUT}s")
    fi
    
    # 执行构建
    print_info "执行构建命令..."
    if docker buildx build "${BUILD_ARGS[@]}" "$DOCKER_DIR"; then
        print_success "多架构镜像构建完成！"
    else
        print_error "构建失败"
        exit 1
    fi
}

# 创建manifest列表
create_manifest() {
    if [ "$CREATE_MANIFEST" != "true" ]; then
        return
    fi
    
    print_info "创建manifest列表..."
    
    # 为每个平台创建manifest
    for platform in $TARGET_PLATFORMS; do
        # 将平台转换为镜像标签后缀
        platform_suffix=$(echo "$platform" | sed 's/\//_/g')
        manifest_name="${IMAGE_NAME}:${IMAGE_TAG}-${platform_suffix}"
        
        print_info "创建manifest: $manifest_name"
        docker buildx imagetools create \
            --tag "$manifest_name" \
            "${IMAGE_NAME}:${IMAGE_TAG}" || \
            print_warning "创建manifest失败: $manifest_name"
    done
    
    print_success "Manifest列表创建完成"
}

# 显示构建结果
show_results() {
    echo ""
    echo "=========================================="
    echo "构建结果"
    echo "=========================================="
    
    if [ "$BUILD_OUTPUT_TYPE" = "local" ]; then
        echo "本地镜像:"
        docker images | grep "$IMAGE_NAME" || echo "未找到镜像"
    elif [ "$BUILD_OUTPUT_TYPE" = "registry" ]; then
        echo "远程镜像: ${FULL_IMAGE_NAME}"
    elif [ "$BUILD_OUTPUT_TYPE" = "tar" ]; then
        echo "导出文件: ${OUTPUT_PATH}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
        ls -lh "${OUTPUT_PATH}/${IMAGE_NAME}-${IMAGE_TAG}.tar" 2>/dev/null || echo "文件未找到"
    fi
    
    echo "=========================================="
}

# 主函数
main() {
    print_info "开始多架构构建流程..."
    
    # 检查Buildx
    check_buildx
    
    # 设置构建器
    setup_builder
    
    # 构建镜像
    build_multiarch
    
    # 创建manifest
    create_manifest
    
    # 显示结果
    show_results
    
    print_success "所有操作完成！"
}

# 执行主函数
main "$@"
