# CloudApp
🙎‍♂️🙍‍♀️ A cloud storage application built with Swift 5 and UIKit where the user can register and enjoy cloud storage functionality like uploading or downloading files.

# Замечание!! На симуляторе почему то не всегда появляется папка с приложением в Files. На реальном устройстве все работает хорошо.

# Test user login & password
testuser@mail.ru 123123

# 📲 About App: 
- 📐 MVVM architecrure pattern
- 🚀 Using RxSwift
- 👨🏿‍🦯 Full programmatically UI (no storyboard) 
- 📡 Saving your files on Firebase Cloud Storage.
- 🎫 Create folders, upload from file manager or photos, download, rename and delete files.
- ❤️  Choose between 2 layouts: Grid / List
- 🔮 Filter files and folders by searching in the top search bar.
- 🪄 Download, rename, do whatever you want with files by tapping on file cell.

# ToDo
- Сделать чтобы лейбл с количеством файлов в папке показывал их количество

## Requirements
* 🛠 Xcode 
* ☕️ Cocoapods: 
  - pod 'RxSwift'
  - pod 'SnapKit'
  - pod 'RxRelay'
  - pod 'RxCocoa'
  - pod 'Firebase/Auth'
  - pod 'Firebase/Storage'

# How to install? 🤔
1. ️ Clone this repository
`git clone https://github.com/zabarik21/CloudApp.git`
2. 💽 Install required dependencies
`pod install`
3. 🍾 Open `.xcworkspace` file
4. 🔨 Build and Run 🏃

<table>
  <tr>
    <td>Main screen with grid layout</td>
    <td>Main screen with list layout</td>
  </tr>
  <tr>
    <td><img src="https://i.ibb.co/M29MSdD/mainscreen.png"></td>
    <td><img src="https://i.ibb.co/1rhZDBB/list.png"></td>
  </tr>
  <tr>
    <td>Add folder and files from this view</td>
    <td>Files view (when you tap on folder)</td>
  </tr>
  <tr>
    <td><img src="https://i.ibb.co/dQTjvr9/myview.png"></td>
    <td><img src="https://i.ibb.co/9N4NJhK/Simulator-Screen-Shot-i-Phone-X-2022-08-17-at-13-14-02.png"></td>
  </tr>
 </table>
