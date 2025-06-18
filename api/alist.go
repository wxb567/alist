package handler

import (
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
)

var alistProcess *os.Process

func init() {
	// 获取当前工作目录
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("获取工作目录失败: %v", err)
	}
	
	// 设置二进制文件路径
	binaryPath := filepath.Join(cwd, "alist")
	
	// 确保二进制文件有执行权限
	if err := os.Chmod(binaryPath, 0755); err != nil {
		log.Printf("警告: 无法设置执行权限: %v", err)
	}

	// 启动 AList
	cmd := exec.Command(binaryPath, "server")
	cmd.Dir = cwd
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	
	if err := cmd.Start(); err != nil {
		log.Fatalf("启动 AList 失败: %v", err)
	}
	
	alistProcess = cmd.Process
	log.Printf("AList 已启动 (PID: %d)", alistProcess.Pid)
	
	// 确保在程序退出时停止AList
	go func() {
		cmd.Wait()
		log.Println("AList 进程已退出")
	}()
}

func Handler(w http.ResponseWriter, r *http.Request) {
	// 创建反向代理到本地AList服务
	proxy := &http.Client{}
	alistURL := "http://localhost:3000" + r.URL.Path
	
	// 创建新请求
	proxyReq, err := http.NewRequest(r.Method, alistURL, r.Body)
	if err != nil {
		http.Error(w, "创建代理请求失败", http.StatusInternalServerError)
		return
	}
	
	// 复制原始请求头
	for name, values := range r.Header {
		for _, value := range values {
			proxyReq.Header.Add(name, value)
		}
	}
	
	// 发送请求到AList
	resp, err := proxy.Do(proxyReq)
	if err != nil {
		http.Error(w, "连接AList失败: "+err.Error(), http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	
	// 复制响应头
	for name, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(name, value)
		}
	}
	
	// 复制状态码和响应体
	w.WriteHeader(resp.StatusCode)
	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("复制响应体失败: %v", err)
	}
}