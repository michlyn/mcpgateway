#!/bin/bash

# 脚本用于自动启动服务和测试认证头传递
# 使用方式：./test/run-auth-headers-test.sh

# 确保脚本在出错时停止
set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # 无颜色

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}= McpGateway 认证头传递测试启动脚本 =${NC}"
echo -e "${BLUE}========================================${NC}"

# 检查是否已构建
if [ ! -d "dist" ]; then
  echo -e "${YELLOW}项目尚未构建，正在执行构建...${NC}"
  npm run build
  echo -e "${GREEN}构建完成${NC}"
fi

# 清理现有进程
echo -e "${BLUE}清理现有进程...${NC}"
pkill -f "node dist/index.js" || true
sleep 1

# 启动SSE服务 (后台运行)
echo -e "${BLUE}启动SSE服务 (端口8001)...${NC}"
node dist/index.js --stdio "cat" --outputTransport streamable-http --httpPath /sse --port 8001 --healthEndpoint /health --healthEndpoint /status > sse-service.log 2>&1 &
SSE_PID=$!
echo -e "${GREEN}SSE服务已启动，进程ID: $SSE_PID${NC}"

# 等待SSE服务启动
echo -e "${BLUE}等待SSE服务启动...${NC}"
sleep 2

# 启动McpGateway (后台运行)
echo -e "${BLUE}启动McpGateway (端口8000)...${NC}"
node dist/index.js --sse "http://localhost:8001" --outputTransport streamable-http --httpPath /mcp --port 8000 --healthEndpoint /health --healthEndpoint /status > gateway.log 2>&1 &
GATEWAY_PID=$!
echo -e "${GREEN}McpGateway已启动，进程ID: $GATEWAY_PID${NC}"

# 等待Gateway启动
echo -e "${BLUE}等待Gateway启动...${NC}"
sleep 2

# 运行测试
echo -e "${BLUE}运行认证头传递测试...${NC}"
npm run test:auth-headers-pass

echo -e "${GREEN}测试完成${NC}"

# 清理
echo -e "${BLUE}清理进程...${NC}"
kill $SSE_PID $GATEWAY_PID
echo -e "${GREEN}所有进程已清理${NC}"

# 显示日志
echo -e "${BLUE}SSE服务日志 (最后20行)：${NC}"
tail -n 20 sse-service.log

echo -e "${BLUE}Gateway日志 (最后20行)：${NC}"
tail -n 20 gateway.log

echo -e "${GREEN}测试全部完成${NC}" 