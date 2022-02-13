# LBJMediaBrowser

## [English Readme](./README_en.md)

LBJMediaBrowser 是一个在 SwiftUI 框架下实现的图片视频浏览器。

- [特性](#特性)
- [示例](#示例)
- [安装](#安装)
- [使用](#使用)
    - [创建媒体对象](#创建媒体对象)
    - [网格模式](#网格模式)
    - [分页模式](#分页模式)
    - [图片缓存](#图片缓存)
- [第三方依赖](#第三方依赖)
- [请求添加新功能](#请求添加新功能)

## 特性

- 支持的图片类型：`UIImage`、`PHAsset` 、`URL` 和 Gif 动态图。
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

LBJMediaBrowser 为每一种图片和视频都定义了对应的类型。它们都是继承自 `Media` 的 `class` 类型，方便用于自定义自己的类型。

**图片**

- `MediaUIImage`：`UIImage` 类型的图片。
- `MediaURLImage`：`URL` 类型的图片。
- `MediaPHAssetImage`：`PHAsset` 类型的图片。
- `MediaGifImage`：Gif 动态图，支持从 `Bundle` 和 `Data` 中获取动态图数据。`MediaURLImage` 和 `MediaPHAssetImage` 会自动识别对应类型的动态图。

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

// Gif Image
let gifImage1 = MediaGifImage(source: .bundle(name: "lebron", bundle: .main)
let gifImage2 = MediaGifImage(source: .data(gifData))

let gifUrl = URL(string: "https://www.example.com/test.gif")!
let gifImage3 = MediaURLImage(imageUrl: gifUrl)

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

LBJMediaBrowser 定义了 `LBJGridMediaBrowser` 类型，用于以网格模式浏览媒体。例如：

```swift
let medias = [uiImage, urlImage, assetImage, urlVideo, assetVideo]
let dataSource = LBJGridMediaBrowserDataSource(medias: medias)
LBJGridMediaBrowser(dataSource: dataSource)
```

**自定义显示内容**

`LBJGridMediaBrowserDataSource` 提供了丰富的自定义显示内容的闭包：

```swift
public init(
  sections: [GridSection],
  placeholderProvider: ((Media) -> AnyView)? = nil,
  progressProvider: ((Float) -> AnyView)? = nil,
  failureProvider: ((Error) -> AnyView)? = nil,
  contentProvider: ((MediaLoadedResult) -> AnyView)? = nil,
  sectionHeaderProvider: ((GridSection) -> AnyView)? = nil,
  pagingMediaBrowserProvider: (([Media], Int) -> LBJPagingMediaBrowser)? = nil
) { }
```

- `placeholderProvider`: 媒体未加载时显示的内容，闭包的参数是 `Media` 类型，可以根据这个参数为图片和视频分别定义显示内容。
- `progressProvider`: 媒体正在加载时显示的内容，闭包的参数是 `Float` 类型，表示下载进度。此闭包只对图片有效。
- `failureProvider`: 媒体加载失败时显示的内容，闭包的参数是 `Error` 类型，
- `contentProvider`: 媒体加载成功时显示的内容，闭包的参数是 `MediaLoadedResult` 类型，可以根据这个参数为图片和视频分别定义显示内容。
- `sectionHeaderProvider`: section header 显示的内容，闭包的参数是 `GridSection` 类型，可以根据这个参数为为不同的 section 定义 header 显示内容。
- `pagingMediaBrowserProvider`: 点击跳转的分页浏览器。参数 `[Media]` 是浏览器中的所有媒体组成的数组, 参数 `Int` 是用户点击的媒体在数组中的索引。

例如：

```swift
let uiImageSection = TitledGridSection(title: "UIImages", medias: uiImages)
let urlImageSection = TitledGridSection(title: "URLImages", medias: urlImages)
let dataSource = LBJGridMediaBrowserDataSource(
  sections: [uiImageSection, urlImageSection],
  placeholderProvider: {
    MyPlaceholderView(media: $0)
      .asAnyView()
  },
  progressProvider: {
    MyProgressView(progress: $0)
      .foregroundColor(.white)
      .frame(width: 40, height: 40)
      .asAnyView()
  },
  failureProvider: {
    MyErrorView(error: $0)
      .font(.system(size: 10))
      .asAnyView()
  },
  contentProvider: {
    MyGridContentView(result: $0)
      .asAnyView()
  },
  sectionHeaderProvider: {
    Text($0.title)
      .asAnyView()
  },
  pagingMediaBrowserProvider: { medias, page in
    let dataSource = LBJPagingMediaBrowserDataSource(
      medias: medias,
      placeholderProvider: {
        MyPlaceholderView(media: $0)
          .asAnyView()
      },
      progressProvider: {
        MyProgressView(progress: $0)
          .foregroundColor(.white)
          .frame(width: 100, height: 100)
          .asAnyView()
      },
      failureProvider: { error, retry in
        MyErrorView(error: error, retry: retry)
          .font(.system(size: 16))
          .asAnyView()
      },
      contentProvider: {
        MyPagingContentView(result: $0)
          .asAnyView()
      })
    let browser = LBJPagingBrowser(dataSource: dataSource, currentPage: page)
    browser.autoPlayVideo = true
    return LBJPagingMediaBrowser(browser: browser)
  }
)
```

**设置媒体的大小**

通过调用 `minItemSize` 方法设置媒体的大小，默认是 `(80, 80)`。

```swift
LBJGridMediaBrowser(dataSource: dataSource)
  .minItemSize(.init(width: 100, height: 200))
```

**设置媒体之间的间隔**

通过调用 `itemSpacing` 方法设置媒体之间的间隔，默认是 `2`。

```swift
LBJGridMediaBrowser(dataSource: dataSource)
  .itemSpacing(4)
```

**设置点击媒体时是否跳转到分页模式浏览**

通过调用 `itemSpacing` 方法设置点击媒体时是否跳转到分页模式浏览，默认是 `true`。

```swift
NavigationView {
  LBJGridMediaBrowser(dataSource: dataSource)
    .browseInPagingOnTapItem(true)
}
```

### 分页模式

LBJMediaBrowser 定义了 `LBJPagingMediaBrowser` 类型，用于以分页模式浏览媒体。例如：

```swift
let browser = LBJPagingBrowser(medias: medias)
LBJPagingMediaBrowser(browser: browser)
```

**自定义显示内容**

`LBJPagingMediaBrowserDataSource` 提供了丰富的自定义显示内容的闭包：

```swift
public init(
  medias: [Media],
  placeholderProvider: ((Media) -> AnyView)? = nil,
  progressProvider: ((Float) -> AnyView)? = nil,
  failureProvider: ((_ error: Error, _ retry: @escaping () -> Void) -> AnyView)? = nil,
  contentProvider: ((MediaLoadedResult) -> AnyView)? = nil
) { }
```

其中的泛型类型分别代表媒体的四个加载阶段的显示内容：

- `placeholderProvider`: 媒体未加载时显示的内容，闭包的参数是 `Media` 类型，可以根据这个参数为图片和视频分别定义显示内容。
- `progressProvider`: 媒体正在加载时显示的内容，闭包的参数是 `Float` 类型，表示下载进度。此闭包只对图片有效。
- `failureProvider`: 媒体加载失败时显示的内容，闭包的第一个参数是 `Error` 类型，第二参数是 `retry` 闭包，可以调用 `retry()` 重新加载媒体。
- `contentProvider`: 媒体加载成功时显示的内容，闭包的参数是 `MediaLoadedResult` 类型，可以根据这个参数为图片和视频分别定义显示内容。

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
  let browser = LBJPagingBrowser(medias: medias)
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

### 图片缓存

为了给用户再次浏览媒体时提供更好的体验，默认情况下，LBJMediaBrowser 会把图片保存在磁盘中，并且默认过期时间为 `7` 天，没有缓存的大小限制。另外在使用中也会把图片缓存到内存，默认最大使用内存为 `100MB`；当超过 `100MB` 时，会自动根据缓存的时间自动清理最旧的图片，使内存占用减少到 `80MB` 以下。

在显示图片时，首先从内存缓存中查找图片；如果没找到，则继续从磁盘中查找；如果还是没找到，才会真正去加载图片。

如果需要自定义缓存的规则，可以通过 `EnvironmentValues` 来设置。代码如下：

```swift
let imageCache: ImageCache? = {
  let diskStorage = try? ImageDiskStorage(config: .init(
    name: "ImageCache",
    sizeLimit: 0,
    expiration: .days(7)
  ))
  let memoryStorage = ImageMemoryStorage(
    memoryCapacity: 100_000_000,
    preferredMemoryCapacityAfterPurge: 80_000_000
  )
  let cache = ImageCache(diskStorage: diskStorage, memoryStorage: memoryStorage)
  return cache
}()
let mediaBrowserEnvironment = LBJMediaBrowserEnvironment(imageCache: imageCache)

LBJGridMediaBrowser(dataSource: dataSource)
  .environment(\.mediaBrowserEnvironment, mediaBrowserEnvironment)
```

如果不需要缓存到磁盘，把 `diskStorage` 设置为 `nil`：

```swift
let cache = ImageCache(diskStorage: nil, memoryStorage: memoryStorage)
```

## 第三方依赖

### [AlamofireImage](https://github.com/Alamofire/AlamofireImage)

使用 AlamofireImage 下载网络图片。

### [LBJImagePreviewer](https://github.com/Lebron1992/LBJImagePreviewer)

使用 LBJImagePreviewer 展示图片。

## 请求添加新功能

请使用 GitHub issues。
