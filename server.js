const express = require('express')
const serveStatic = require('serve-static')
const { spawn } = require('child_process')

const app = express()

// 启动Alist服务
const alist = spawn('./alist', [], {
  stdio: 'inherit',
  shell: true
})

// 静态文件服务
app.use(serveStatic(__dirname + '/public'))

// 代理API请求
app.all('/api/*', (req, res) => {
  proxy.web(req, res, { target: 'http://localhost:5244' })
})

// 启动Express
const PORT = process.env.PORT || 3000
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`)
})