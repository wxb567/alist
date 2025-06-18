package handler

import (
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"syscall"
	"time"
)

func init() {
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatalf("获取工作目录失败: %v", err)
	}
	
	binaryPath := filepath.Join(cwd, "alist")
	
	if err := os.Chmod(binaryPath, 0755); err != nil {
		log.Printf("警告: 无法设置执行权限: %v", err)
	}

	cmd := exec.Command(binaryPath, "server")
	cmd.Dir = cwd
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true}
	
	if err := cmd.Start(); err != nil {
		log.Fatalf("启动 AList 失败: %v", err)
	}
	
	log.Printf("AList 已启动 (PID: %d)", cmd.Process.Pid)
	
	go func() {
		cmd.Wait()
		log.Println("AList 进程已退出")
	}()

	time.Sleep(2 * time.Second)
}

func Handler(w http.ResponseWriter, r *http.Request) {
	proxyReq, err := http.NewRequest(r.Method, "http://localhost:3000"+r.URL.String(), r.Body)
	if err != nil {
		http.Error(w, "创建代理请求失败", http.StatusInternalServerError)
		return
	}
	
	for name, values := range r.Header {
		for _, value := range values {
			proxyReq.Header.Add(name, value)
		}
	}
	
	client := &http.Client{}
	resp, err := client.Do(proxyReq)
	if err != nil {
		http.Error(w, "连接AList失败: "+err.Error(), http.StatusBadGateway)
		return
	}
	defer resp.Body.Close()
	
	for name, values := range resp.Header {
		for _, value := range values {
			w.Header().Add(name, value)
		}
	}
	
	w.WriteHeader(resp.StatusCode)
	if _, err := io.Copy(w, resp.Body); err != nil {
		log.Printf("复制响应体失败: %v", err)
	}
}