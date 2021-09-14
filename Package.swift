// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "LBJMediaBrowser",
  platforms: [.iOS(.v15)],
  products: [
    .library(
      name: "LBJMediaBrowser",
      targets: ["LBJMediaBrowser"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/Alamofire/AlamofireImage.git",
      .upToNextMajor(from: "4.2.0")
    ),
    .package(
      url: "https://github.com/Lebron1992/LBJImagePreviewer",
      branch: "main"
    )
  ],
  targets: [
    .target(
      name: "LBJMediaBrowser",
      dependencies: ["AlamofireImage", "LBJImagePreviewer"],
      resources: [.process("PreviewContent")]
    ),
    .testTarget(
      name: "LBJMediaBrowserTests",
      dependencies: ["LBJMediaBrowser"]
    )
  ]
)
