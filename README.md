# MonkeyTV - 互動式影音軟體
[![](https://i.imgur.com/LKYoCCe.png)](https://apps.apple.com/tw/app/monkeytv/id6467018396)

MonkeyTV 是一款互動式影音軟體，讓您輕鬆享受影音內容，並與其他使用者互動。以下是 MonkeyTV 使用的技術和功能的簡要介紹。

## 功能 

- 播放影音內容
- 瀏覽和搜尋影片
- 即時聊天室
- 彈幕功能
- 儲存片單功能
- 深色模式
- 高性能的UI和UX設計
  
![Simulator Screen Recording - iPhone 14 - 2023-10-27 at 15 22 59](https://github.com/YuKi-Wang1124/MonkeyTV/assets/69345200/1fdc79e5-8d7b-4575-823e-fd166ada360f)           ![Simulator Screen Recording - iPhone 14 - 2023-10-27 at 15 32 12](https://github.com/YuKi-Wang1124/MonkeyTV/assets/69345200/2a12083c-1ef7-460d-baa1-f3590cce2a4f)      
![Simulator Screen Recording - iPhone 14 - 2023-10-27 at 15 36 59](https://github.com/YuKi-Wang1124/MonkeyTV/assets/69345200/69a232ec-8618-45af-8db1-3157ed959234)            ![Simulator Screen Recording - iPhone 14 - 2023-10-27 at 15 39 58](https://github.com/YuKi-Wang1124/MonkeyTV/assets/69345200/9b963c81-ca1e-46f5-ab76-464a8220160e)




## 技術

- 使用 YouTube RESTful API 獲取後端數據
- 自製的快取機制以提高性能
- 使用 Swift 語言開發
- 使用純程式碼 Auto Layout 建立複雜的UI元件
- 使用 DiffableDataSource 來管理 UITableView 和 UICollectionView 的數據
- 使用 CADisplayLink 來實現高頻率更新彈幕動畫
- 使用 UIPanGestureRecognizer 實現滑動方式關閉播放頁面的效果
- 監聽 Firebase 後端數據庫，使用 MVVM 架構實時更新多人聊天室的畫面
- 整合 Sign In With Apple 和 Google SDK ，實現登入和個人化片單雲端資料
- 使用 Access Control 來控制程式碼的存取權限
- 插入 Lottie 動畫效果來提升使用者體驗
- 使用 Core Data 本地端資料記錄使用者歷史的搜尋內容
- 使用 CocoaPods 管理 SwiftLint、 GoogleSignIn、 Firebase、 youtube-ios-player-helper 和 lottie-ios 等套件
- 安裝 Firebase Crashlytics 來紀錄使用者錯誤發生頻率和訊息
- 使用 Unit Test 來測試存入 UserDefaults 紀錄的登入天數的判斷函式是否正確
- 遵守 Git flow 版本控管開發模式

## 安裝

要下載 MonkeyTV，請按照以下步驟執行：
1. 到 Apple Store 上搜尋並下載 MonkeyTV
   

要安裝 MonkeyTV，請按照以下步驟執行：

1. 複製存儲庫到電腦
2. 使用 Xcode 打開項目
3. 編譯和運行應用程序

## 貢獻

如果您想要貢獻或報告問題，請使用GitHub的問題追蹤系統。

## 授權

這個項目使用MIT許可證。
 
