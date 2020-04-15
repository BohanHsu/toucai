# 脚本有风险，后果需自付 😂
# Disclam: This script has no guarantee of anything!

# 使用方法
## Amazon
用Safari打开Amazon, 加购物车 😀
Checkout，如果可以选外送的时间，那您不需要用到这个脚本。
如果没有可选的外送时间，那Amazon会停留在选时间的页面上，[就像这个页面](https://github.com/BohanHsu/toucai/blob/master/doc/amazon_page.png)。
这时，请保持Safari在选外送时间的页面上，您可以用这个脚本来刷新Safair的页面，直到有可选的外送时间。
当有可选的外送时间时，脚本会自动终止，并且用Mac的系统通知提示您三次。
系统通知会有提示音，请将电脑的音量打开。

## 脚本
打开 Terminal
Run `osascript toucai.scpt`

# 多个购物车
如果您需要同时刷Whole Foods 和 Amazon Fresh，您需要用Safari的Privacy Window打开两个窗口。在两个页面中都点到选外送时间的页面，再启动脚本。此时脚本会同时刷新所有的Safair窗口，并在找到第一个可选外送时间时停止。
注：要用多个窗口（Window），我没有测试过Tab。

# Troubleshooting
如果运行脚本时遇到这个错误，
````
toucai.scpt:353:412: execution error: Safari got an error: You must enable the 'Allow JavaScript from Apple Events' option in Safari's Develop menu to use 'do JavaScript'. (8)
````
可以按照[此连接](https://osxdaily.com/2011/11/03/enable-the-develop-menu-in-safari/)调出Develop Menu，再选择允许Javascript。

