# LBJMediaBrowser

`LBJMediaBrowser` is a media browser implemented with SwiftUI.

- [Features](#features)
- [Preview](#preview)
- [Installation](#installation)
- [Usage](#usage)
    - [Create Media Object](#create-media-object)
    - [Grid Mode](#grid-mode)
    - [Paging Mode](#paging-mode)
- [Third Party Dependency](#third-party-dependency)
- [Existing Issues](#existing-issues)
- [Requesting a Feature](#requesting-a-feature)

## Features

- Supported image types: `UIImage`、`PHAsset` and `URL`.
- Supported video types: `PHAsset` and `URL`.
- Browsing in grid mode.
- Browsing in paging mode.
- Customizable display content.

## Preview

![preview](./preview.gif)

[Example Code](https://github.com/Lebron1992/LBJMediaBrowserExamples)


## Installation

`LBJMediaBrowser` can be installed using Swift Package Manager:

1. Copy the package URL: 

```
https://github.com/Lebron1992/LBJMediaBrowser
```

2. Open the menu `File / Add Packages` in Xcode.

3. Paste the URL to the search box and add the library to your project.

## Usage

### Create Media Object

`LBJMediaBrowser` defines the corresponding type for each type of image and video. They are all `class` types, which are convenient for customizing your own types, and implement the `MediaType` protocol.

**Image**

- `MediaUIImage`: An image type with a `UIImage` object.
- `MediaURLImage`: An image type with a `URL` object.
- `MediaPHAssetImage`: An image type with a `PHAsset` object whose `mediaType` is `image`.

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

`LBJMediaBrowser` defines a type of 'LBJGridMediaBrowser', which is used to browse media in grid mode. For example:

```swift
let medias = [uiImage, urlImage, assetImage, urlVideo, assetVideo]
LBJGridMediaBrowser(medias: medias)
```

**Customize the content for the four stages**

`LBJGridMediaBrowser` is a generic type, which is defined as follows:

```swift
public struct LBJGridMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {
  public init(
    medias: [MediaType],
    @ViewBuilder placeholder: @escaping (MediaType) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) { }
}
```

The generic types represent the display contents of the four stages:

-  `placeholder`: The content displayed when the media is not loaded. The type of the parameter is `MediaType`. The display content can be defined for image and video respectively according to this parameter.
-  `progress`: The content displayed when the media is loading. The type of the parameter is `Float`, indicating the download progress. This closure is only valid for images.
-  `failure`: The content displayed when media loading fails. The type of the parameter is `Error`.
-  `content`: The content displayed when the media is loaded successfully. The type of the parameter is `MediaLoadedResult`. The display content can be defined for image and video respectively according to this parameter.

**Set the item size**

Set the item size by calling `minItemSize`, `80` by default:

```swift
LBJGridMediaBrowser(medias: medias)
  .minItemSize(100)
```

**Set the item spacing**

Set the item spacing by calling `itemSpacing`, `2` by default:

```swift
LBJGridMediaBrowser(medias: medias)
  .itemSpacing(4)
```

**Set wheather browse in paging mode on tap item**

Set wheather browse in paging mode on tap item by calling `browseInPagingOnTapItem`, `true` by default:

```swift
LBJGridMediaBrowser(medias: medias)
  .browseInPagingOnTapItem(true)
```

**Set wheather auto play video in paging mode**

Set wheather auto play video in paging mode by calling `autoPlayVideoInPaging`, `false` by default:

```swift
LBJGridMediaBrowser(medias: medias)
  .autoPlayVideoInPaging(false)
```

### Paging Mode

`LBJMediaBrowser` defines a type of 'LBJPagingMediaBrowser', which is used to browse media in paging mode. For example:

```swift
let browser = LBJPagingBrowser(medias: medias)
LBJPagingMediaBrowser(browser: browser)
```

**Customize the content for the four stages**

`LBJPagingMediaBrowser` is a generic type, which is defined as follows:

```swift
public struct LBJPagingMediaBrowser<Placeholder: View, Progress: View, Failure: View, Content: View>: View {
  public init(
    browser: LBJPagingBrowser,
    @ViewBuilder placeholder: @escaping (MediaType) -> Placeholder,
    @ViewBuilder progress: @escaping (Float) -> Progress,
    @ViewBuilder failure: @escaping (Error) -> Failure,
    @ViewBuilder content: @escaping (MediaLoadedResult) -> Content
  ) { }
}
```

The generic types represent the display contents of the four stages:

-  `placeholder`: The content displayed when the media is not loaded. The type of the parameter is `MediaType`. The display content can be defined for image and video respectively according to this parameter.
-  `progress`: The content displayed when the media is loading. The type of the parameter is `Float`, indicating the download progress. This closure is only valid for images.
-  `failure`: The content displayed when media loading fails. The type of the parameter is `Error`.
-  `content`: The content displayed when the media is loaded successfully. The type of the parameter is `MediaLoadedResult`. The display content can be defined for image and video respectively according to this parameter.

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
  let browser = LBJPagingBrowser(medias: viewModel.medias)
  browser.autoPlayVideo = true
  return browser
}()
```

## Third Party Dependency

### [AlamofireImage](https://github.com/Alamofire/AlamofireImage)

Using AlamofireImage to download URL image.

### [LBJImagePreviewer](https://github.com/Lebron1992/LBJImagePreviewer)

Using LBJImagePreviewer to display image.

## Existing Issues

There are bugs when set the current paging manually by calling `setCurrentPage`.

## Requesting a Feature

Use GitHub issues to request a feature.
