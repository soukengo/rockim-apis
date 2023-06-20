# PROTOC变量
PROTOC_VAR = -I.  -I${GOPATH}/src -I./third_party

# 客户端 proto目录
API_PROTO_DIR="./rockim/api/client"
# 共享的 proto 目录
SHARED_PROTO_DIR="./rockim/shared"
# 三方的 proto 目录
THIRD_PROTO_DIR="./third_party"

# 客户端proto 文件
CLIENT_PROTO_FILE=$(shell find "$(API_PROTO_DIR)/" -name '*.proto')
# 共享的 proto 文件
SHARED_PROTO_FILE=$(shell find "$(SHARED_PROTO_DIR)/" -name '*.proto')

# 目标目录
DIST_DIR=$(shell pwd)/dist
# CSHARP代码目录
CSHARP_DIST=$(DIST_DIR)/csharp


# 临时目录
BUILD_TMP_DIR="./tmp"
BUILD_TMP_ROCKIM_DIR="./tmp/rockim"
BUILD_TMP_ROCKIM_API_DIR="./tmp/rockim/api"


clearClientTmp:
	@echo "clear tmp dir start"
	@rm -rf $(BUILD_TMP_DIR)
	@echo "clear tmp dir end"

buildClientTmp:
	@echo "build tmp dir start"
	@mkdir -p "$(BUILD_TMP_DIR)"
	@mkdir -p "$(BUILD_TMP_ROCKIM_DIR)"
	@mkdir -p "$(BUILD_TMP_ROCKIM_API_DIR)"
	@cp -r $(API_PROTO_DIR) $(BUILD_TMP_ROCKIM_API_DIR)
	@cp -r $(SHARED_PROTO_DIR) $(BUILD_TMP_ROCKIM_DIR)
	@cp -r $(THIRD_PROTO_DIR) $(BUILD_TMP_DIR)
	@find $(BUILD_TMP_DIR) -name '*.proto'  | xargs sed -i "" "/api\/annotations.proto/d"
	@find $(BUILD_TMP_DIR) -name '*.proto'  | xargs sed -i "" "/option (google.api.http)/,+3d"

	@find $(BUILD_TMP_DIR) -name '*.proto'  | xargs sed -i "" "/validate.proto/d"
	@find $(BUILD_TMP_DIR) -name '*.proto'  | xargs sed -i "" -E "s/\[\(validate.rules(.*)\];/;/g"
	@echo "build tmp dir end"

protoc-csharp:clearClientTmp buildClientTmp
	@echo "generate csharp api start"
	@mkdir -p "${CSHARP_DIST}"
	@cd $(BUILD_TMP_DIR) && protoc ${PROTOC_VAR} --csharp_out=${CSHARP_DIST} --csharp_opt=file_extension=.cs,base_namespace= $(CLIENT_PROTO_FILE)
	@cd $(BUILD_TMP_DIR) && protoc ${PROTOC_VAR} --csharp_out=${CSHARP_DIST} --csharp_opt=file_extension=.cs,base_namespace=  $(SHARED_PROTO_FILE)
	@echo "generate csharp api end"
	@rm -rf $(BUILD_TMP_DIR)
protoc-csharp-grpc:clearClientTmp buildClientTmp
	@echo "generate csharp api start"
	@mkdir -p "${CSHARP_DIST}"
	@cd $(BUILD_TMP_DIR) && protoc ${PROTOC_VAR}   --grpc_out=${CSHARP_DIST} --grpc_opt=no_server --plugin=protoc-gen-grpc=/usr/local/protobuf/bin/grpc_csharp_plugin $(CLIENT_PROTO_FILE)
	@echo "generate csharp api end"
	@rm -rf $(BUILD_TMP_DIR)
