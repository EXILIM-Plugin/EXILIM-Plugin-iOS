# EXILIM-Plugin-iOS について

EXILIM-Plugin-iOSは、iOS版 Device Connectプラットフォームである [DeviceConnect-iOS](https://github.com/DeviceConnect/DeviceConnect-iOS/) でカシオ計算機製のデジタルカメラである EXILIM シリーズを利用できるようにするためのカシオ計算機公式のプラグインです。

# アーキテクチャ

本プラグインはバイナリ形式のiOS フレームワークとして提供されています(ソースコードは非公開)。

iOSで Device Connectおよびそのプラグインを利用するためには、Webブラウザを内蔵した iOSアプリ(以下ブラウザアプリ)を作成し、そのアプリに本プラグインを組み込む必要があります。
ブラウザアプリとしては [DeviceWebAPIBrowser](https://itunes.apple.com/jp/app/devicewebapibrowser/id994422987?mt=8) が AppStoreに公開されておりますが、iOSは完成されたアプリに後からプラグイン(Framework)を追加することができないため、本プラグインを利用するためにはブラウザアプリをソースコードから再ビルドし、ビルド時にプラグインを含める必要があります。

そこで、本プラグインを利用するために最小限の機能を持ったブラウザアプリのソースコードを以下に公開しています。

- [EXILIM-Plugin-iOS-ControllerApp](https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-ControllerApp)

以下、この EXILIM-Plugin-iOS-ControllerApp を例にして、プラグインの組み込み方法を解説します。


# プラグインの組み込み方法

## 詳細仕様

- 対応カメラ
  - EXILIM FR-100
  - EXILIM FR-200
- 対応 OS
  - iOS 9.0 以上
- 動作確認済み Xcode バージョン
  - Xcode 9.2
- 対応 Swift バージョン
  - Swift 3.2
  - ※ 本プラグインは Swiftで実装されているため、異なるバージョンの Swiftランタイムでは正常に動作しない可能性があります。
  - ※ Swift 4 への対応も予定しています。
- 依存ライブラリ
  - DeviceConnectSDK (2.1)
    - CocoaAsyncSocket (7.6.1)
    - CocoaHTTPServer (2.3.1)
    - CocoaLumberjack (3.3.0)
    - RoutingHTTPServer (1.0.0)
  - ReachabilitySwift (4.1.0)
  - RxAutomaton (0.2.1)
  - RxCocoa (3.6.1)
  - RxSwift (3.6.1)



## CocoaPods

EXILIM-Plugin-iOS-ControllerApp の Podfileは以下のような構造になっています。

```
source 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-PodSpecs.git'
source 'https://github.com/kunichiko/DeviceConnect-PodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '9.0'
swift_version = '3.0'
use_frameworks!

target 'ExilimDeviceController' do
  pod 'DeviceConnectSDK', '= 2.1.3'
  pod 'DeviceConnectHostPlugin'
  pod 'DeviceConnectExilimPlugin'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'

      # https://github.com/robbiehanson/CocoaHTTPServer/issues/171
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'DD_LEGACY_MACROS=1']
    end
  end
end
```

### source (Specファイルの読み込みソース) の追加

本プラグインは、Podfileに以下のように記述することで追加可能です。

```
  pod 'DeviceConnectExilimPlugin'
```

ただし、CocoaPods 本家の PodSpecリポジトリには登録されていないため、Podfileの先頭に以下の記述を追加する必要があります。

```
source 'https://github.com/EXILIM-Plugin/EXILIM-Plugin-iOS-PodSpecs.git'
```

また、依存している DeviceConnectSDK も本家の PodSpecリポジトリには登録されていないため source の追加が必要です。
本家の Specリポジトリは https://github.com/DeviceConnect/DeviceConnect-PodSpecs にありますが、Framework対応にするために Podspecを少し修正する必要があります。
そのため、このリポジリを ForkしてFramework対応の修正を加えた以下のリポジトリを使用してください。

```
source 'https://github.com/kunichiko/DeviceConnect-PodSpecs.git'
```

こちらに登録されている DeviceConnectSDK 2.1.3 が対応済みのバージョンとなります。

### 環境設定

本プラグインは、「iOS 9以上」、「Swift 3」、「フレームワーク使用」を前提としているため、以下を記述しています。

```
platform :ios, '9.0'
swift_version = '3.0'
use_frameworks!
```

### ワークアラウンド

DeviceConnect SDKが依存している CocoaHTTPServerが[ビルドエラーになる問題](https://github.com/robbiehanson/CocoaHTTPServer/issues/171)があるため、各ビルドの `GCC_PREPROCESSOR_DEFINITIONS` 設定に `DD_LEGACY_MACROS=1` を追加しています。

# 制限事項

## Releaseビルド時にラインタイムエラーが発生する

本プラグインの Frameworkモジュールは Debug 設定でビルドされています。そのため、RxSwiftなどの依存ライブラリも同じ Debug 設定でビルドされていないとランタイムエラーになる問題があります。
アプリをビルドする際は Debug ビルドをするようにしてください。 Releaseビルド用の Frameworkは後日提供する予定です。

## 他プラグインとの共存について

上記 EXILIM-Plugin-iOS-ControllerApp の Podspec には Hostプラグインが追加されているため、Hostプラグインの機能と EXILIMプラグインの機能が両方利用可能です。
Hostプラグイン同様、必要なプラグインをPodfileに追加することで、他のプラグインとの同時利用も可能になりますが、弊社では動作確認などは行っておりません。

# ライセンス

本プラグインは [MIT ライセンス](LICENSE.md)のもと、バイナリ形式でのみ配布いたします。
