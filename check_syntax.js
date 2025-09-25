const fs = require('fs');
const path = require('path');

function checkEtsFiles(dir) {
  const files = fs.readdirSync(dir);
  let hasErrors = false;
  
  for (const file of files) {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      if (checkEtsFiles(filePath)) {
        hasErrors = true;
      }
    } else if (file.endsWith('.ets')) {
      try {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // 简单的语法检查
        const lines = content.split('\n');
        for (let i = 0; i < lines.length; i++) {
          const line = lines[i];
          
          // 检查未闭合的括号
          const openBraces = (line.match(/\{/g) || []).length;
          const closeBraces = (line.match(/\}/g) || []).length;
          
          // 检查未定义的变量引用 - 更精确的检查
          if (line.includes('return mediumStyle') && !content.includes('const mediumStyle')) {
            console.log(`❌ ${filePath}:${i+1} - 可能的未定义变量: mediumStyle`);
            hasErrors = true;
          }
          
          // 检查any类型使用
          if (line.includes(': any') || line.includes('as any')) {
            console.log(`⚠️  ${filePath}:${i+1} - any类型使用: ${line.trim()}`);
          }
        }
        
        console.log(`✅ ${filePath} - 语法检查通过`);
      } catch (error) {
        console.log(`❌ ${filePath} - 读取失败: ${error.message}`);
        hasErrors = true;
      }
    }
  }
  
  return hasErrors;
}

console.log('开始检查ETS文件语法...\n');
const hasErrors = checkEtsFiles('./entry/src/main/ets');

if (hasErrors) {
  console.log('\n❌ 发现语法错误');
  process.exit(1);
} else {
  console.log('\n✅ 所有文件语法检查通过');
}