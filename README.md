# LBJMediaBrowser

[English Readme](./README_en.md)

`LBJMediaBrowser` 是一个在 SwiftUI 框架下实现的图片视频浏览器。

- [特性](#特性)
- [示例](#示例)
- [安装](#安装)
- [使用](#使用)
    - [创建媒体对象](#创建媒体对象)
    - [网格模式](#网格模式)
    - [分页模式](#分页模式)
- [第三方依赖](#第三方依赖)
- [存在问题](#存在问题)
- [请求添加新功能](#请求添加新功能)

## 特性

- 支持的图片类型：`UIImage`、`PHAsset` 和 `URL`。
- 支持的视频类型：`PHAsset` 和 `URL`。
- 网格模式浏览。
- 分页模式浏览。
- 可自定义不同加载阶段显示的内容。

### 示例

![preview](./preview.gif)

[示例代码](https://github.com/Lebron1992/LBJMediaBrowserExamples)

## 安装

使用 Swift Package Manager 安装：

1. 复制库的路径。

```
https://github.com/Lebron1992/LBJMediaBrowser
```

2. 在 Xcode 中打开菜单 `File / Add Packages`。
3. 把路径粘贴到搜索框，根据提示把库添加到项目中。

## 使用

### 创建媒体对象

`LBJMediaBrowser` 为每一种图片和视频都定义了对应的类型。它们都是继承自 `Media` 的 `class` 类型，方便用于自定义自己的类型。

**图片**

- `MediaUIImage`：`UIImage` 类型的图片。
- `MediaURLImage`：`URL` 类型的图片。
- `MediaPHAssetImage`：`PHAsset` 类型的图片。

**视频**

- `MediaURLVideo`：`URL` 类型的视频。
- `MediaPHAssetVideo`：`PHAsset` 类型的视频。

直接调用对应的初始化函数即可创建对象：

```swift
// MediaUIImage
let uiImage = UIImage(named: "image_name")
let mediaUIImage = MediaUIImage(uiImage: $uiImage)

// MediaURLImage
let imageUrl = URL(string: "https://www.example.com/test.png")!
let urlImage = MediaURLImage(imageUrl: imageUrl)

// MediaPHAssetImage
let phAsset = ... // 从 Photo Library 中获取
let assetImage = MediaPHAssetImage(asset: phAsset)

// MediaURLVideo
let videoUrl = URL(string: "https://www.example.com/test.mp4")!
let urlVideo = MediaURLVideo(videoUrl: videoUrl, previewImageUrl: nil)

// MediaPHAssetVideo
let phAsset = ... // 从 Photo Library 中获取
let assetVideo = MediaPHAssetVideo(asset: phAsset)
```

还可以通过继承对应的类型，来定义自己的媒体类型，例如：

```swift
import LBJMediaBrowser

final class MyMediaUIImage: MediaUIImage {
  let caption: String

  init(uiImage: UIImage, caption: String) {
    self.caption = caption
    super.init(uiImage: uiImage)
  }
}
```

### 网格模式

`LBJMediaBrowser` 定义了 `LBJGridMediaBrowser` 类型，用于以网格模式浏览媒体。例如：

```swift
let medias = [uiImage, urlImage, assetImage, urlVideo, assetVideo]
LBJGridMediaBrowser(medias: medias)
```

**自定义四个加载阶段的显示内容**

`LBJGridMediaBrowser` 是一个泛型，它的定义如下：

```swift
public struct LBJGridMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {
  public init(
    medias: [Media],
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) { }
}
```

其中的泛型类型分别代表媒体的四个加载阶段的显示内容：

-  `placeholder`: 媒体未加载时显示的内容，闭包的参数是 `Media` 类型，可以根据这个参数为图片和视频分别定义显示内容。
-  `progress`: 媒体正在加载时显示的内容，闭包的参数是 `Float` 类型，表示下载进度。此闭包只对图片有效。
-  `failure`: 媒体加载失败时显示的内容，闭包的参数是 `Error` 类型，
-  `content`: 媒体加载成功时显示的内容，闭包的参数是 `MediaLoadedResult` 类型，可以根据这个参数为图片和视频分别定义显示内容。

**设置媒体的大小**

通过调用 `minItemSize` 方法设置媒体的大小，默认是 `80`。

```swift
LBJGridMediaBrowser(medias: medias)
  .minItemSize(100)
```

**设置媒体之间的间隔**

通过调用 `itemSpacing` 方法设置媒体之间的间隔，默认是 `2`。

```swift
LBJGridMediaBrowser(medias: medias)
  .itemSpacing(4)
```

**设置点击媒体时是否跳转到分页模式浏览**

通过调用 `itemSpacing` 方法设置点击媒体时是否跳转到分页模式浏览，默认是 `true`。

```swift
LBJGridMediaBrowser(medias: medias)
  .browseInPagingOnTapItem(true)
```

**设置在分页模式浏览时是否自动播放视频**

通过调用 `autoPlayVideoInPaging` 方法设置在分页模式浏览时是否自动播放视频，默认是 `false`。

```swift
LBJGridMediaBrowser(medias: medias)
  .autoPlayVideoInPaging(false)
```

### 分页模式

`LBJMediaBrowser` 定义了 `LBJPagingMediaBrowser` 类型，用于以分页模式浏览媒体。例如：

```swift
let browser = LBJPagingBrowser(medias: medias)
LBJPagingMediaBrowser(browser: browser)
```

**自定义四个加载阶段的显示内容**

`LBJPagingMediaBrowser` 是一个泛型，它的定义如下：

```swift
public struct LBJPagingMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (Media) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (_ error: Error, _ retry: @escaping () -> Void) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) { }
}
```

其中的泛型类型分别代表媒体的四个加载阶段的显示内容：

-  `placeholder`: 媒体未加载时显示的内容，闭包的参数是 `Media` 类型，可以根据这个参数为图片和视频分别定义显示内容。
-  `progress`: 媒体正在加载时显示的内容，闭包的参数是 `Float` 类型，表示下载进度。此闭包只对图片有效。
-  `failure`: 媒体加载失败时显示的内容，闭包的第一个参数是 `Error` 类型，第二参数是 `retry` 闭包，可以调用 `retry()` 重新加载媒体。
-  `content`: 媒体加载成功时显示的内容，闭包的参数是 `MediaLoadedResult` 类型，可以根据这个参数为图片和视频分别定义显示内容。

```swift
struct MyPagingMediaErrorView: View {
  let error: Error

  @EnvironmentObject
  private var mediaLoader: MediaLoader

  var body: some View {
    VStack {
      Image(systemName: "multiply")
        .foregroundColor(.white)
        .font(.system(size: 50))

      Text(error.localizedDescription)
        .foregroundColor(.white)

      Button {
        mediaLoader.startLoadingMedia()
      } label: {
        Text("Retry")
          .foregroundColor(.black)
          .frame(size: .init(width: 100, height: 40))
          .background(Color.white)
          .cornerRadius(20)
      }
    }
    .background(Color.black)
  }
}
```

**设置当前页数**

当 `LBJPagingMediaBrowser` 显示时，默认显示第一页。在初始化 `LBJPagingBrowser` 时，可以指定当前页数：

```swift
let browser = LBJPagingBrowser(medias: medias, currentPage: 10)
```

还可以通过调用 `setCurrentPage` 方法来手动改变当前页数：

```swift
browser.setCurrentPage(10, animated: false)
```

`animated` 默认是 `true`。

**设置是否自动播放视频**

通过设置 `LBJPagingBrowser` 的属性 `autoPlayVideo` 来设置是否自动播放视频， 默认是 `false`。

```swift
let browser: LBJPagingBrowser = {
  let browser = LBJPagingBrowser(medias: viewModel.medias)
  browser.autoPlayVideo = true
  return browser
}()
```

**设置点击媒体时执行的操作**

通过调用 `onTapMedia` 方法设置点击媒体时执行的操作。

```swift
LBJPagingMediaBrowser(browser: browser)
  .onTapMedia { media in
    // ...
  }
```

## 第三方依赖

### [AlamofireImage](https://github.com/Alamofire/AlamofireImage)

使用 AlamofireImage 下载网络图片。

### [LBJImagePreviewer](https://github.com/Lebron1992/LBJImagePreviewer)

使用 LBJImagePreviewer 展示图片。

## 存在问题

通过调用 `setCurrentPage` 手动设置当前页数有 Bug。

## 请求添加新功能

请使用 GitHub issues。
