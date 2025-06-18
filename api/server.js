const { exec } = require('child_process');
const path = require('path');

module.exports = async (req, res) => {
  // 设置环境变量
  process.env.PORT = '3000';
  
  // 启动 AList 二进制
  const alistPath = path.join(__dirname, '../alist-binary/alist');
  
  const alist = exec(`${alistPath} --data /tmp`, (error) => {
    if (error) {
      console.error(`执行错误: ${error}`);
      return res.status(500).send('AList 启动失败');
    }
  });
  
  // 等待 1 秒确保 AList 启动
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // 代理请求到 AList
  const proxy = require('http-proxy').createProxyServer();
  proxy.web(req, res, { target: 'http://127.0.0.1:3000' });
  
  // 处理代理错误
  proxy.on('error', (err) => {
    console.error('代理错误:', err);
    res.status(500).send('代理错误');
  });
};