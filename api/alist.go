package handler

import (
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"log"
	
	"github.com/alist-org/alist/v3/cmd"
	"github.com/alist-org/alist/v3/pkg/utils"
)

func init() {
	// 获取当前工作目录
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("获取工作目录失败: %v", err)
	}
	
	// 设置 AList 数据目录
	dataDir := filepath.Join(cwd, "data")
	os.Setenv("ALIST_DATA", dataDir)
	
	// 创建数据目录
	if err := os.MkdirAll(dataDir, 0755); err != nil {
		log.Fatalf("创建数据目录失败: %v", err)
	}
	
	// 重写配置文件
	configPath := filepath.Join(cwd, "config/config.json")
	if err := utils.RewriteConfigFromEnv(configPath, os.Getenv); err != nil {
		log.Printf("配置文件重写失败: %v", err)
	}
	
	// 启动 AList
	go startAList()
}

func startAList() {
	// 获取 AList 二进制路径
	cwd, _ := os.Getwd()
	alistPath := filepath.Join(cwd, "alist-binary/alist")
	
	// 设置可执行权限
	if err := os.Chmod(alistPath, 0755); err != nil {
		log.Fatalf("设置可执行权限失败: %v", err)
	}
	
	// 启动 AList
	cmd := exec.Command(alistPath, "server")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	
	if err := cmd.Start(); err != nil {
		log.Fatalf("启动 AList 失败: %v", err)
	}
	
	log.Println("AList 已启动")
}

func Handler(w http.ResponseWriter, r *http.Request) {
	// 等待 AList 启动完成
	// 在实际应用中应添加超时和健康检查
	
	// 转发请求到 AList
	http.Redirect(w, r, "http://localhost:3000", http.StatusTemporaryRedirect)
}