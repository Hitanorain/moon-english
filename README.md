# Moon英语

给小朋友的看图听音英语练习，模仿多邻国的闯关形式，难度参照 RAZ 分级（AA → J）。

在线使用：https://hitanorain.github.io/moon-english/

- 页面是单个 `index.html`；图片用 emoji 和代码绘制的场景，音效和背景音乐也由代码合成
- 每个单元一个主题，分 4 个模块：学一学 / 听一听 / 看一看 / 小测验
- 朗读优先播放 `audio/` 里预先生成的高清录音（Azure：内容用 Ava，夸奖用 Jenny），没有录音时改用设备语音，再不行用在线朗读
- 学习进度保存在各自设备的浏览器里

## 更新录音

改了课程内容以后，在这个文件夹里运行：

```
powershell -ExecutionPolicy Bypass -File tools\make-audio.ps1
```

脚本会读取 `index.html` 里所有要朗读的文本，只生成新增的录音，删掉不再需要的，并更新 `audio/manifest.js`。
Azure 密钥放在 `%USERPROFILE%\azure-key.txt`（第一行密钥，第二行区域），不要放进这个仓库。
