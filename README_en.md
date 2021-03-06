# LBJMediaBrowser

LBJMediaBrowser is a media browser implemented with SwiftUI.

- [Features](#features)
- [Preview](#preview)
- [Installation](#installation)
- [Usage](#usage)
    - [Create Media Object](#create-media-object)
    - [Grid Mode](#grid-mode)
    - [Paging Mode](#paging-mode)
    - [Image Cache](#image-cache)
- [Third Party Dependency](#third-party-dependency)
- [Requesting a Feature](#requesting-a-feature)

## Features

- Supported image types: `UIImage`、`PHAsset`、`URL` and gif.
- Supported video types: `PHAsset` and `URL`.
- Browsing in grid mode.
- Browsing in paging mode.
- Customizable display content for different stages.

## Preview

![preview](./preview.gif)

[Example Code](https://github.com/Lebron1992/LBJMediaBrowserExamples)


## Installation

LBJMediaBrowser can be installed using Swift Package Manager:

1. Copy the package URL: 

```
https://github.com/Lebron1992/LBJMediaBrowser
```

2. Open the menu `File / Add Packages` in Xcode.

3. Paste the URL to the search box and add the library to your project.

## Usage

### Create Media Object

LBJMediaBrowser defines the corresponding type for each type of image and video. They are all `class` type and inherit from `Media`, which are convenient for customizing your own types.

**Image**

- `MediaUIImage`: An image type with a `UIImage` object.
- `MediaURLImage`: An image type with a `URL` object.
- `MediaPHAssetImage`: An image type with a `PHAsset` object whose `mediaType` is `image`.
- `MediaGifImage`：Represents a gif image. It can get gif data from `Bundle` and `Data`。`MediaURLImage` and `MediaPHAssetImage` can automatically recognize the gif images.

**Video**

- `MediaURLVideo`：A video type with a `URL` object.
- `MediaPHAssetVideo`: A video type with a `PHAsset` object whose `mediaType` is `video`.

Create the media object by calling the corresponding initializer:

```swift
// MediaUIImage
let uiImage = UIImage(named: "image_name")
let mediaUIImage = MediaUIImage(uiImage: $uiImage)

// MediaURLImage
let imageUrl = URL(string: "https://www.example.com/test.png")!
let urlImage = MediaURLImage(imageUrl: imageUrl)

// MediaPHAssetImage
let phAsset = ... // Fetch from photo library
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
let phAsset = ... // Fetch from photo library
let assetVideo = MediaPHAssetVideo(asset: phAsset)
```

You can also define your own media type by inheriting the corresponding type, for example:

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

### Grid Mode

LBJMediaBrowser defines a type of 'LBJGridMediaBrowser', which is used to browse media in grid mode. For example:

```swift
let medias = [uiImage, urlImage, assetImage, urlVideo, assetVideo]
let dataSource = LBJGridMediaBrowserDataSource(medias: medias)
LBJGridMediaBrowser(dataSource: dataSource)
```

**Customize the contents**

`LBJGridMediaBrowserDataSource` provides a wealth of closures to custom the contents:

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

The generic types represent the display contents of the four stages:

- `placeholderProvider`: The content displayed when the media is not loaded. The type of the parameter is `Media`. The display content can be defined for image and video respectively according to this parameter.
- `progressProvider`: The content displayed when the media is loading. The type of the parameter is `Float`, indicating the download progress. This closure is only valid for images.
- `failureProvider`: The content displayed when media loading fails. The type of the parameter is `Error`.
- `contentProvider`: The content displayed when the media is loaded successfully. The type of the parameter is `MediaLoadedResult`. The display content can be defined for image and video respectively according to this parameter.
- `sectionHeaderProvider`: The content displayed for the section header. The type of the parameter is `GridSection`.
- `pagingMediaBrowserProvider`: A closure to custom the paging media browser on tap item. The `[Media]` array is all the medias in the browser, The `Int` is the index of the tapped item.

For example:

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

**Set the item size**

Set the item size by calling `minItemSize`, `(80, 80)` by default:

```swift
LBJGridMediaBrowser(dataSource: dataSource)
  .minItemSize(.init(width: 100, height: 200))
```

**Set the item spacing**

Set the item spacing by calling `itemSpacing`, `2` by default:

```swift
NavigationView {
  LBJGridMediaBrowser(dataSource: dataSource)
    .browseInPagingOnTapItem(true)
}
```

**Set wheather browse in paging mode on tap item**

Set wheather browse in paging mode on tap item by calling `browseInPagingOnTapItem`, `true` by default:

```swift
NavigationView {
  LBJGridMediaBrowser(dataSource: dataSource)
    .browseInPagingOnTapItem(true)
}
```

### Paging Mode

LBJMediaBrowser defines a type of 'LBJPagingMediaBrowser', which is used to browse media in paging mode. For example:

```swift
let browser = LBJPagingBrowser(medias: medias)
LBJPagingMediaBrowser(browser: browser)
```

**Customize the content for the four stages**

`LBJPagingMediaBrowserDataSource` provides a wealth of closures to custom the contents:

```swift
public init(
  medias: [Media],
  placeholderProvider: ((Media) -> AnyView)? = nil,
  progressProvider: ((Float) -> AnyView)? = nil,
  failureProvider: ((_ error: Error, _ retry: @escaping () -> Void) -> AnyView)? = nil,
  contentProvider: ((MediaLoadedResult) -> AnyView)? = nil
) { }
```

- `placeholderProvider`: The content displayed when the media is not loaded. The type of the parameter is `Media`. The display content can be defined for image and video respectively according to this parameter.
- `progressProvider`: The content displayed when the media is loading. The type of the parameter is `Float`, indicating the download progress. This closure is only valid for images.
- `failureProvider`: The content displayed when media loading fails. The first parameter is `Error` and you could call the second parameter `retry` to reload the media.
- `contentProvider`: The content displayed when the media is loaded successfully. The type of the parameter is `MediaLoadedResult`. The display content can be defined for image and video respectively according to this parameter.

**Set current page**

When the `LBJPagingMediaBrowser` is displayed, the first page is displayed by default. When initializing the `LBJPagingBrowser`, you can specify the current page:

```swift
let browser = LBJPagingBrowser(medias: medias, currentPage: 10)
```

You can also manually change the current page by calling the `setCurrentPage` method:

```swift
browser.setCurrentPage(10, animated: false)
```

`true` by default for the `animated` parameter.

**Set wheather auto play video**

Set whether to automatically play video by setting the property `autoPlayVideo` of `LBJPagingBrowser`, `false` by default.

```swift
let browser: LBJPagingBrowser = {
  let browser = LBJPagingBrowser(medias: medias)
  browser.autoPlayVideo = true
  return browser
}()
```

**Set the action to execute when media tapped**

Set the action to execute when media tapped by calling the `onTapMedia` method.

```swift
LBJPagingMediaBrowser(browser: browser)
  .onTapMedia { media in
    // ...
  }
```

### Image Cache

In order to provide users with a better experience when browsing media again, by default, LBJMediaBrowser will save images on disk, and the default expiration duration is `7` days, with no cache size limit. In addition, images will also be cached in memory. The default maximum memory usage is `100MB`; When memory usage exceeds `100MB`, it will automatically clean up the oldest images according to the cache date, so as to reduce the memory usage to less than `80MB`.

When displaying an image, it will try to find the image from the memory cache. If not found, continue to search from the disk. If not found again, it will load the image from the image source.

If you need to customize the cache rules, you can set them through `EnvironmentValues`. The code is as follows:

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

If you don't need the disk storage, set it to `nil`:

```swift
let cache = ImageCache(diskStorage: nil, memoryStorage: memoryStorage)
```

## Third Party Dependency

### [AlamofireImage](https://github.com/Alamofire/AlamofireImage)

Using AlamofireImage to download URL image.

### [LBJImagePreviewer](https://github.com/Lebron1992/LBJImagePreviewer)

Using LBJImagePreviewer to display image.

## Requesting a Feature

Use GitHub issues to request a feature.
